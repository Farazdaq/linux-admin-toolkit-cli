# Performs Backup
#!/bin/bash

# Load .env configuration
set -o allexport
source .env
set +o allexport

LOG_FILE="logs/actions.log"
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$BACKUP_DEST_DIR"

# Date & Time Stamp
now=$(date +"%Y-%m-%d_%H-%M-%S")
report="Backup Report - $now\n"
total_start=$(date +%s)

# Check CPU Load
cpu_load=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
report+="🖥️  CPU Load: $cpu_load% (Threshold: $CPU_THRESHOLD%)\n"

if (( $(echo "$cpu_load > $CPU_THRESHOLD" | bc -l) )); then
    report+="CPU Load too high! Skipping backup.\n"
    echo -e "$report"
    echo -e "$report" >> "$LOG_FILE"
    exit 1
fi

# Spinner
spin() {
    sp='/-\|'
    printf "⏳ "
    while kill -0 "$1" 2>/dev/null; do
        printf "\b${sp:i++%${#sp}:1}"
        sleep 0.1
    done
    printf "\b Done!\n"
}

# Backup Files
if [[ "$BACKUP_MODE" == "files" || "$BACKUP_MODE" == "both" ]]; then
    IFS=',' read -ra DIRS <<< "$BACKUP_SOURCE_DIRS"
    files_backup_name="$BACKUP_DEST_DIR/backup_files_${now}.tar.gz"
    echo "📦 Backing up files to $files_backup_name ..."
    tar -czf "$files_backup_name" "${DIRS[@]}" &
    pid=$!
    spin $pid
    files_size=$(du -sh "$files_backup_name" | cut -f1)
    report+="✅ Files backup created: $files_backup_name (Size: $files_size)\n"
fi

# Backup Database
if [[ "$BACKUP_MODE" == "database" || "$BACKUP_MODE" == "both" ]]; then
    db_backup_name="$BACKUP_DEST_DIR/backup_db_${now}.gz"
    echo "🗃️  Backing up database from $DATABASE_PATH to $db_backup_name ..."
    gzip -c "$DATABASE_PATH" > "$db_backup_name" &
    pid=$!
    spin $pid
    db_size=$(du -sh "$db_backup_name" | cut -f1)
    report+="✅ Database backup created: $db_backup_name (Size: $db_size)\n"
fi

# Clean old backups
if [[ "$BACKUP_RETENTION_DAYS" -gt 0 ]]; then
    echo "🧹 Cleaning backups older than $BACKUP_RETENTION_DAYS days in $BACKUP_DEST_DIR ..."
    find "$BACKUP_DEST_DIR" -type f -name "*.gz" -mtime +$BACKUP_RETENTION_DAYS -exec rm -v {} \; >> "$LOG_FILE"
    report+="🧹 Old backups older than $BACKUP_RETENTION_DAYS days have been removed.\n"
fi

# Final Report
total_end=$(date +%s)
duration=$((total_end - total_start))
report+="⏱️  Backup duration: ${duration}s\n"

echo -e "\n📄 Final Report:\n"
echo -e "$report"
echo -e "$report" >> "$LOG_FILE"
