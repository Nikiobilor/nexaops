#!/usr/bin/env bash
set -e

# NexaOps log file check
# Checks if app.log exists. Creates it if not.

LOG_FILE="app.log"

if [ -f "$LOG_FILE" ]; then
	echo "File exists : $LOG_FILE"
else
	touch "$LOG_FILE"
	echo "FIle created: $LOG_FILE"
fi
