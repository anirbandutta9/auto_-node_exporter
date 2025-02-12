#!/bin/bash
set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root."
  exit 1
fi

# Variables
NODE_EXPORTER_VERSION="1.8.2"
TARBALL="node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
DOWNLOAD_URL="https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/${TARBALL}"
INSTALL_DIR="/root"
TARGET_DIR="${INSTALL_DIR}/node_exporter"
SERVICE_FILE="/etc/systemd/system/node_exporter.service"

echo "Downloading Node Exporter v${NODE_EXPORTER_VERSION}..."
cd ${INSTALL_DIR}
wget ${DOWNLOAD_URL}

echo "Extracting the tarball..."
tar -xzf ${TARBALL}

echo "Renaming extracted folder to 'node_exporter'..."
mv node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64 node_exporter

echo "Creating systemd service file at ${SERVICE_FILE}..."
cat << 'EOF' > ${SERVICE_FILE}
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/root/node_exporter/node_exporter

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd daemon..."
systemctl daemon-reload

echo "Enabling node_exporter service..."
systemctl enable node_exporter.service

echo "Starting node_exporter service..."
systemctl start node_exporter.service

echo "Node Exporter installation and setup complete."
