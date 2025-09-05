#Create a bash script that continuously monitors system resources and alerts you when usage exceeds defined thresholds

#!/bin/bash

CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80
LOG_FILE="$HOME/resource_monitoring.log"
EMAIL="demo11@gmail.com"

log_alert(){
    MESSAGE="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $MESSAGE" | tee -a "$LOG_FILE"
    echo "$MESSAGE" | mail -s "RESOURCE USAGE EXCEED ALERT" "$EMAIL"
}
#This function will output ex:2025-09-03 17:45:12 - DISK USAGE has exceeded threshold 90%
#tee -a sends this message to the terminal as well appends into the LOG_FILE

while true; do
    DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
#df / = shows disk usage of the root (/) filesystem
#NR==2 : process only the second line 
#{print $5} : print the 5th column, which is disk usage percentage (Use%)
#sed removes the % sign

    MEMORY_USAGE=$(free | awk '/Mem:/ {printf("%.0f"), $3/$2*100}')
#free shows system memory usage with second row being memory usage. We can see total, used, free shared,etc columns
#column2 is total memory, column 3 is used memory
# /Mem:/ : filter the line that starts with Mem:
#$3/$2*100 = percentage of memory used.
#"%.0f" = floating point with 0 decimal places : rounds it to an integer

    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
    CPU_USAGE=${CPU_USAGE%.*} #rounds it to integer
#-b : batch mode (so it outputs plain text, not interactive)
#-n1 : run only one iteration.
#if we dont use b-batch mode then top starts in interactive mode which is not script friendly. grep and awk won't work correctly.because output is being constantly refreshed
#if we dont use n1 top will keep running in a loop. script will never proceed past top
# Sample output of top:
#%Cpu(s):  2.5 us,  1.0 sy,  0.0 ni, 96.2 id,  0.1 wa,  0.0 hi,  0.2 si,  0.0 st
#grep picks the line CPU usage
#$8 corresponds to idle CPU column. Substracting it from 100 gives CPU usage

    if [ "$DISK_USAGE" -ge "$DISK_THRESHOLD" ]; then    
        log_alert "DISK USAGE has exceeded threshold: $DISK_USAGE%" 
    fi

    if [ "$MEMORY_USAGE" -ge "$MEMORY_THRESHOLD" ]; then    
        log_alert "MEMORY USAGE has exceeded threshold: $MEMORY_USAGE%" 
    fi

    if [ "$CPU_USAGE" -ge "$CPU_THRESHOLD" ]; then    
        log_alert "CPU USAGE has exceeded threshold: $CPU_USAGE%" 
    fi
    
    sleep 10
done