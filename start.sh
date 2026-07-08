#!/bin/bash

# 1. Download and extract local rclone binary
echo "Installing local Rclone..."
curl -O https://downloads.rclone.org/v1.66.0/rclone-v1.66.0-linux-amd64.zip
unzip -j rclone-v1.66.0-linux-amd64.zip "*/rclone"
rm rclone-v1.66.0-linux-amd64.zip
chmod +x ./rclone

# 2. Check for Google Drive backups
echo "Checking Google Drive for backups..."
./rclone sync gdrive:BillingBackup /opt/render/project/src/data || echo "No backup found. Starting fresh."

# 3. Create/Overwrite the port file so the app is forced to use Render's dynamic port
mkdir -p /opt/render/project/src/data
echo "$PORT" > /opt/render/project/src/data/port.txt

# 4. Launch the Billing application on Render's assigned port
echo "Launching Billing Core on port $PORT..."
node server.js &

# 5. Background backup sync loop
while true; do
  sleep 300
  echo "Automated Sync: Uploading snapshot to Google Drive..."
  ./rclone sync /opt/render/project/src/data gdrive:BillingBackup
done
