#Write a shell script to Parse log files for specific patterns and generate reports
#Key features to implement
# 1.Pattern Matching - Search for specific patterns in log files
# 2.Counting Occurrences - Count how many times specific events occurred
# 3. Top error codes, Filter ips, Filter logs based on timestamp
#!/bin/bash

LOG_FILE="$1"
#User enters a log file name while executing the script(Ex: /log_analyzer.sh /var/log/auth.log)

if [ -z "$LOG_FILE" ]; then         
    echo "Enter a log file name"
elif [ ! -f "$LOG_FILE" ]; then 
    echo "Log file does not exist"
fi
#-z checks if the argument is empty
#-f checks if file exists and is a regular file. ! negates the result so the status code changes to 1 from 0

search_pattern(){
    read -p "Enter the pattern to search" pattern
    echo "Searching for $pattern in the log file"
    grep --color=always "$pattern" "$LOG_FILE" || echo "No matches found"
}
#--color=always : highlights the matched pattern in colored text.
# || echo "No matches found" : if previous command fails(i.e exit code =1) grep doesnot find anything then it would print no matches found

count_occurences(){
    read -p "Enter the pattern to count" pattern
    count=$(grep -c  "$pattern" "$LOG_FILE")
    echo "Found $count occurences in $LOG_FILE"
}
# -c prints the count of that specific pattern

filter_by_time(){
    read -p "Enter the timestamp based on filetype(ex: 06/Sept/2025 or '2025-09-06 10:' )" timestamp
    echo "Filtering log for $timestamp"
    grep "$timestamp" "$LOG_FILE" || echo "No logs found for given timestamp"
}

top_ips(){
    echo "Top 10 IP addresses:"
    awk '{print $1}' "LOG_FILE" | sort -nr | uniq -c | head -10
}
#sort -nr : sort numerically in reverse order(highest count first)
#uniq -c : collects duplicates and adds a count of occurence
#head 10 : shows only the top 10 ips

top_errors(){
    echo "Top Error codes:"
    awk '{print $9}' "LOG_FILE" | grep '^[0-9]' | sort | uniq -c | sort -nr | head -10
}
#awk '{print $9}': prints the 9th column, which in Apache/Nginx access logs is the HTTP status code (e.g., 200, 404, 500).
#grep '^[0-9]' : filters only lines starting with a number (ignores blanks or weird lines).

report_summary(){
    echo "=========Log Summary=========="
    echo "Total no lines in the log file: $(wc -l < "$LOG_FILE")"
    echo "Errors (4xx/5xx): $(grep -E ' 4[0-9][0-9] | 5[0-9][0-9] ' "$LOG_FILE" | wc -l)"
    echo "Unique IPs: $(awk '{print $1}' "$LOG_FILE" | sort -u | wc -l)"
    echo "-------------------------"
    top_ips
    echo "-------------------------"
    top_errors
    echo "-------------------------"
}
#grep -E : extended regex
#grep -E ' 4[0-9][0-9] | 5[0-9][0-9] : matches status codes like 404, 403, 500, 502 inside the logs.
#wc -l : counts how many such lines exist(ex : Errors (4xx/5xx): 259)
#sort -u : sorts uniquely

while true; do
    echo "Log Analyzer menu"
    echo "1)Search for a pattern"
    echo "2)Count Occurences"
    echo "3)Filter by date/time"
    echo "4)Top 10 IPs"
    echo "5)Top error codes"
    echo "6)Report summary"
    echo "7)Exit"

    read -p "Choose the no:" choice

    case $choice in 
        1) search_pattern ;;
        2) count_occurences ;;
        3) filter_by_time ;;
        4) top_ips ;;
        5) top_errors ;;
        6) report_summary ;;
        7) echo "Exiting"; exit 0 ;;
        *) echo "Invalid option" ;;
    esac
done
