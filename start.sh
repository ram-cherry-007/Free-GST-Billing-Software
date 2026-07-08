#!/bin/bash

# 1. Download and extract local rclone binary
echo "Installing local Rclone..."
curl -O https://downloads.rclone.org/v1.66.0/rclone-v1.66.0-linux-amd64.zip
unzip -j rclone-v1.66.0-linux-amd64.zip "*/rclone"
rm rclone-v1.66.0-linux-amd64.zip
chmod +x ./rclone

# 2. Ensure the Google Drive backup directory exists before syncing
echo "Initializing backup paths..."
./rclone mkdir gdrive:BillingBackup || echo "Could not initialize remote directory."

# 3. Pull existing backup if available (using copy instead of sync to prevent empty directory errors)
echo "Checking Google Drive for existing data..."
mkdir -p /opt/render/project/src/data
./rclone copy gdrive:BillingBackup /opt/render/project/src/data || echo "No previous backup found. Starting fresh."

# 4. Force the application to use Render's dynamic port assignment
echo "$PORT" > /opt/render/project/src/data/port.txt

# 5. Launch the Billing application
echo "Launching Billing Core on port $PORT..."
node server.js &

# 6. Background backup sync loop (Uploads data every 5 minutes)
while true; do
  sleep 300
  echo "Automated Sync: Uploading snapshot to Google Drive..."
  ./rclone sync /opt/render/project/src/data gdrive:BillingBackup
done
