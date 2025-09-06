#Create a script called process_monitor.sh that monitors specific processes and can automatically restart them if they're down. 
#What You Need to Implement: Monitor multiple processes from a configuration file Check if processes are running by PID or name 
#Automatic restart capability for failed processes
#Email/log alerts when processes fail Process resource monitoring (CPU, memory usage) 
#Daemon mode - run continuously in background Requirements: Read process list from processes.conf file 
#Send alerts when processes fail or are restarted

#Example configuration file: process.conf
# Format: process_name|restart_command
#nginx|sudo systemctl restart nginx
#sshd|sudo systemctl restart sshd
#myapp|/usr/local/bin/myapp --start


#!/bin/bash
# Configuration
CONFIG_FILE="processes.conf"
LOG_FILE="/var/log/process_monitor.log"
SLEEP_INTERVAL=60   # seconds between checks
ALERT_EMAIL="admin@example.com"

# Function: log messages
log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}
#This function will output ex:2025-09-03 17:45:12 - Process nginx is running
#tee -a sends this message to the terminal as well appends into the LOG_FILE

# Function: send email alert
send_alert() {
    SUBJECT="Process Alert: $1"   # First argument : process name
    MESSAGE="$2"                  # Second argument : detailed message
    echo "$MESSAGE" | mail -s "$SUBJECT"  "$ALERT_EMAIL"
}
#Subject: Process Alert: nginx
#Body: Process nginx was down. Restarting...
#Sent to: admin@example.com

# Function: check CPU/memory usage
check_resources() {
    PROCESS="$1"
    PID=$(pgrep -x "$PROCESS" | head -n 1)

    if [ -n "$PID" ]; then
        CPU=$(ps -p "$PID" -o %cpu=)
        MEM=$(ps -p "$PID" -o %mem=)
        log_msg "Resource usage for $PROCESS (PID $PID): CPU=${CPU}% MEM=${MEM}%"
    fi
}
#$1 = the first argument passed to the function (process name, e.g., nginx).
#pgrep -x "$PROCESS" finds the PID of the process with exact name match.
#process grep, -x finds the exact substring(eg: ssh, sshd it will only look for ssh)
#head -n 1 : if multiple processes match, just take the first PID
#-n checks if the PID string is not empty.
#ps -p "$PID" : Tells ps to only show info for the process with that PID.
# -o %cpu= (-o is output format, %cpu shows the cpu percentage, = removes the header line i.e "CPU") 
#Example Output: 2025-09-03 17:40:12 - Resource usage for nginx (PID 1234): CPU=0.5% MEM=1.2%

# Function: monitor process
monitor_process() {
    PROCESS="$1"
    RESTART_CMD="$2"
    if pgrep -x "$PROCESS" > /dev/null; then
        log_msg "Process $PROCESS is running"
        check_resources
        
    else
        log_msg "Process $PROCESS is NOT running, attempting restart..."
        send_alert "$PROCESS" "Process $PROCESS was down. Restarting..."
        
        eval "$RESTART_CMD" 2>/dev/null

        if pgrep -x "$PROCESS" > /dev/null; then
            log_msg "Process $PROCESS restarted successfully"
            send_alert "$PROCESS" "Process $PROCESS restarted successfully"
        else
            log_msg "Failed to restart process $PROCESS"
            send_alert "$PROCESS" "Failed to restart process $PROCESS"
        fi
    fi
}
#pgrep -x "$PROCESS" > /dev/null :Checks if the process is running, > /dev/null discards the output, Exit code 0 : process found, 1 :not found.


monitor_processes() {
    while IFS="|" read -r PROCESS CMD; do
        [[ -z "$PROCESS" || "$PROCESS" =~ ^# ]] && continue  # skip empty/comment lines
        monitor_process "$PROCESS" "$CMD"
    done < "$CONFIG_FILE"
}
#IFS="|"  Internal Field Separator is set to | (since config file uses process_name|restart_command format).
#read -r : -r tells read not to treat backslashes specially ,it reads the raw input as-is.
#PROCESS : left part (process name, e.g., nginx)
#CMD : right part (restart command, e.g., sudo systemctl restart nginx)
#-z "$PROCESS" || "$PROCESS" =~ ^# : Skip lines that are either EMPTY or lines which are commented using #
#done is kind of closing brace for while loop
# < "$CONFIG_FILE" : instead of reading from keyboard (stdin), read lines from the file $CONFIG_FILE (processes.conf).

# Function: daemon mode
run_daemon() {
    log_msg "Starting process monitor in daemon mode..."
    while true
        do
            monitor_processes
            sleep "$SLEEP_INTERVAL"
    done
}

#Infinite loop: alls the function that checks all processes listed in processes.conf (using pgrep, restarting if needed, logging status, etc.).
#Pauses for 60 seconds before checking again.

#If you want to run in daemon mode, you’d normally start the script like this: ./process_monitor.sh --daemon
#or else it will run the monitor_processes function

if [[ "$1" == "--daemon" ]]
    then
        run_daemon
else
    monitor_processes
fi