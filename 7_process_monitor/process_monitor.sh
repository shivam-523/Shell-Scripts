#!/bin/bash

# Configuration
CONFIG_FILE="processes.conf"
LOG_FILE="/var/log/process_monitor.log"
SLEEP_INTERVAL=30   # seconds between checks
ALERT_EMAIL="admin@example.com"

# Function: log messages
log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function: send email alert (requires mailx or mailutils installed)
send_alert() {
    local subject="$1"
    local body="$2"
    echo "$body" | mail -s "$subject" "$ALERT_EMAIL"
}

# Function: check CPU/memory usage
check_resources() {
    local pname="$1"
    ps -C "$pname" -o %cpu,%mem --no-headers 2>/dev/null
}

# Function: monitor process
monitor_process() {
    local pname="$1"
    local restart_cmd="$2"

    if pgrep -x "$pname" >/dev/null 2>&1; then
        # Process is running → log CPU/memory usage
        usage=$(check_resources "$pname")
        log_msg "✅ $pname is running. [CPU|MEM: $usage]"
    else
        # Process not running → restart
        log_msg "❌ $pname is not running!"
        send_alert "Process $pname down" "$pname is down. Attempting restart..."

        eval "$restart_cmd"
        sleep 2

        if pgrep -x "$pname" >/dev/null 2>&1; then
            log_msg "🔄 $pname restarted successfully."
            send_alert "Process $pname restarted" "$pname was down but restarted successfully."
        else
            log_msg "⚠️ Failed to restart $pname."
            send_alert "Process $pname restart failed" "Restart of $pname failed. Manual intervention required!"
        fi
    fi
}

# Function: daemon mode
run_daemon() {
    log_msg "🚀 Starting process monitor in daemon mode..."
    while true; do
        while IFS="|" read -r pname restart_cmd; do
            [[ -z "$pname" || "$pname" =~ ^# ]] && continue
            monitor_process "$pname" "$restart_cmd"
        done < "$CONFIG_FILE"
        sleep "$SLEEP_INTERVAL"
    done
}

# Start monitoring
run_daemon
