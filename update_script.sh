#!/bin/bash

# Set noninteractive mode to prevent prompts during the script execution
export DEBIAN_FRONTEND=noninteractive

# Define log files with absolute paths
LOG_DIR="/var/log/apt"
UPDATE_LOG="$LOG_DIR/update.log"
UPGRADE_SIMULATION_LOG="$LOG_DIR/upgrade-simulation.log"
UPGRADE_LOG="$LOG_DIR/upgrade.log"

# Ensure the log directory exists
mkdir -p "$LOG_DIR"

# Function to log messages with timestamps
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$UPDATE_LOG"
}

# Function to handle errors
handle_error() {
    log_message "Error encountered: $1"
    exit 1
}

# Update package lists
log_message "Starting apt-get update..."
if ! /usr/bin/apt-get update >> "$UPDATE_LOG" 2>&1; then
    handle_error "apt-get update failed."
fi
log_message "apt-get update completed successfully."

# Simulate an upgrade to see what would be upgraded and log it
log_message "Simulating apt-get upgrade..."
if ! /usr/bin/apt-get -s upgrade > "$UPGRADE_SIMULATION_LOG" 2>&1; then
    handle_error "apt-get upgrade simulation failed."
fi
log_message "apt-get upgrade simulation completed successfully."

# Perform the upgrade and log the output
log_message "Starting apt-get upgrade..."
if ! /usr/bin/apt-get upgrade -y >> "$UPGRADE_LOG" 2>&1; then
    handle_error "apt-get upgrade failed."
fi
log_message "apt-get upgrade completed successfully."

log_message "System update process completed."

