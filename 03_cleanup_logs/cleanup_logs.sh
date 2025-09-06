#Create a script called cleanup_logs.sh that cleans old log files based on age and/or size criteria. 
#What You Need to Implement: 
#Find old log files (older than 7 days) 
#Size-based cleanup (files larger than 100MB) 
#Show before/after disk space usage 
#Count files processed and space freed

#!/bin/bash

DAYS=7
TARGET_DIR="/var/log"
SIZE=100M

SPACE_BEFORE=$(du -sk "$TARGET_DIR" | awk '{print $1}')
#du -sk shows the disk usage summary in kilobytes
#awk prints the first column which shows the size of directory

FILES=$(find "$TARGET_DIR" -type f -mtime +$DAYS -size +$SIZE)
#Find and store the files older than 7 days and larger than 100MB in FILES Variable

if [ -z "$FILES" ]; then
    echo "No files found satisfying the criteria"
    exit 0
fi
#-z checks if the string is empty

FILE_COUNT=$(echo "$FILES" | wc -l)
#Count the files

echo "$FILES" | xargs rm -f
#xargs acts like a bridge which converts output of one command into argument for another command

SPACE_AFTER=$(du -sk "$TARGET_DIR"  | awk '{print $1}')
SPACE_FREED=$((SPACE_BEFORE - SPACE_AFTER))

echo "Current size of log directory is: $SPACE_BEFORE KB"
echo "Files Deleted : $FILE_COUNT"
echo "Size of log directory after cleanup $SPACE_AFTER KB"
echo "Space Freed : $SPACE_FREED KB "

