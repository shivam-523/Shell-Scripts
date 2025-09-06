#Create a script called system_info.sh that displays comprehensive system information in a clean, organized format. 
#What You Need to Display: 
#Hostname - Name of the system Uptime - How long the system has been running
#Memory Usage - Total, used, and available memory
#Disk Usage - Space usage for root filesystem 
#Current Users - Who is currently logged in

#!/bin/bash

echo "System Information Report"

echo "Hostname:"
hostname

echo "Uptime:"
uptime -p
#-p means pretty format. It provides a human-friendly string

echo -e "\n Memory usage:"
#-e option tells echo to enable interpretation of escape sequences.Otherwise it would not recognise \n

free -h | awk 'NR==1{print "Total\tUsed\tFree\tAvailable"} NR==2{print $2"\t"$3"\t"$4"\t"$7}'
#NR means New record. NR==1 basically means first line of the output

echo -e "\n Disk usage for root filesystem:"
df -h / | awk 'NR==1 || NR==2 {print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6}'
# Here || means OR. so we print same columns for both row1 and row2

echo -e "Currently logged in users"
who