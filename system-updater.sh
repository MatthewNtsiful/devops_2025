#!/bin/bash

# System Update and Upgrade Automation Script
# Purpose: Automate package updates with detailed logging and error handling
# Author: Matthew Odoom Ntsiful
# Date: $(date +%Y-%m-%d)

### Configuration Section ###
#############################

# Set non-interactive mode to prevent prompts
export DEBIAN_FRONTEND=noninteractive

# Define logging parameters
LOG_DIR="/var/log/apt"                          # Central log directory
UPDATE_LOG="$LOG_DIR/update.log"                # Package list update log
UPGRADE_SIMULATION_LOG="$LOG_DIR/upgrade-simulation.log"  # Dry-run output
UPGRADE_LOG="$LOG_DIR/upgrade.log"              # Actual upgrade log
TIMESTAMP=$(date +%Y%m%d-%H%M%S)                # Timestamp for log entries

### Function Definitions ###
############################

# Log messages with timestamp to both console and update log
log_message() {
    local message="$1"
    echo "[$TIMESTAMP] $message" | tee -a "$UPDATE_LOG"
}

# Handle errors and exit script
handle_error() {
    local error_msg="$1"
    log_message "ERROR: $error_msg"
    log_message "Check detailed logs in $LOG_DIR"
    exit 1
}

### Main Script Execution ###
#############################

# Create log directory structure
mkdir -p "$LOG_DIR" || handle_error "Failed to create log directory"

log_message "Starting system update process..."

### Phase 1: Update Package Lists ###
#####################################
log_message "Phase 1/3: Updating package lists..."

if ! apt-get update >> "$UPDATE_LOG" 2>&1; then
    handle_error "Package list update failed. Check $UPDATE_LOG"
fi
log_message "Package lists updated successfully"

### Phase 2: Upgrade Simulation ###
####################################
log_message "Phase 2/3: Simulating system upgrade..."

# Dry-run to see what would be upgraded
if ! apt-get -s upgrade > "$UPGRADE_SIMULATION_LOG" 2>&1; then
    handle_error "Upgrade simulation failed. Check $UPGRADE_SIMULATION_LOG"
fi
log_message "Upgrade simulation completed. Preview saved to $UPGRADE_SIMULATION_LOG"

### Phase 3: Perform Actual Upgrade ###
########################################
log_message "Phase 3/3: Performing system upgrade..."

if ! apt-get upgrade -y >> "$UPGRADE_LOG" 2>&1; then
    handle_error "System upgrade failed. Check $UPGRADE_LOG"
fi
log_message "System upgrade completed successfully"

### Final Summary ###
#####################
log_message "Update process completed successfully"
log_message "All logs available in $LOG_DIR:"
ls -lh "$LOG_DIR" | tee -a "$UPDATE_LOG"

exit 0
