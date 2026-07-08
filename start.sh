#!/bin/bash

# 1. Download and extract local rclone binary (No root/sudo needed)
echo "Installing local Rclone..."
curl -O https://downloads.rclone.org/v1.66.0/rclone-v1.66.0-linux-amd64.zip
unzip -j rclone-v1.66.0-linux-amd64.zip "*/rclone"
rm rclone-v1.66.0-linux-amd64.zip
chmod +x ./rclone

# 2. Pull down your latest database snapshot from your Google Drive
echo "Checking Google Drive for backups..."
./rclone sync gdrive:BillingBackup /opt/render/project/src/data || echo "No backup found. Starting fresh."

# 3. Start your billing application
echo "Launching Billing Core..."
node server.js &

# 4. Background Loop: Sync your data to Google Drive every 5 minutes while you work
while true; do
  sleep 300
  echo "Automated Sync: Uploading snapshot to Google Drive..."
  ./rclone sync /opt/render/project/src/data gdrive:BillingBackup
done
