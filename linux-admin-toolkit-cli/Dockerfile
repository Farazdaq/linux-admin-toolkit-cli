# ------------------------------
#  Base Image
# ------------------------------
# Using Ubuntu 20.04 as the base system
FROM ubuntu:20.04

# Avoid interactive prompts when installing packages
ENV DEBIAN_FRONTEND=noninteractive

# ------------------------------
# 🔧 Install Required Packages
# ------------------------------
# Install core utilities and CLI tools your scripts depend on
RUN apt-get update && apt-get install -y \
    bash \
    git \
    curl \
    dialog \
    whiptail \
    jq \
    iputils-ping \
    traceroute \
    dnsutils \
    net-tools \
    docker.io \
    lynis \
    chkrootkit \
    auditd \
    systemd \
    sudo \
    nano \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------
#  Set Working Directory
# ------------------------------
WORKDIR /opt/linux-admin-toolkit

# ------------------------------
#  Copy Project Files Into Container
# ------------------------------
COPY . .

# ------------------------------
#  Make Scripts Executable
# ------------------------------
RUN chmod +x setup.sh tui.sh modules/*.sh

# ------------------------------
#  Run Setup Script (optional, comment if not needed at build time)
# ------------------------------
# RUN ./setup.sh

# ------------------------------
#  Set Default Command (Entry Point)
# ------------------------------
# Start an interactive shell (or change to `./tui.sh` to auto-launch the menu)
ENTRYPOINT ["bash"]
