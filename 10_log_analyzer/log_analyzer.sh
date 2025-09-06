
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
