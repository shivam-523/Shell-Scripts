#Create a script called backup.sh that backs up important directories with proper error checking and timestamped filenames.
#What You Need to Implement: 
#Check if source directory exists before backing up 
#Create backup directory if it doesn't exist 
#Add timestamp to backup filename
#Compress the backup using tar
#Display success/error messages
#!/bin/bash

SOURCE_DIR="$HOME/Documents/data"
BACKUP_DIR="$HOME/backups"
#$HOME is a standard environment variable in Linux/Unix systems.It stores the absolute path of your login user’s home directory.

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.tar.gz"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Source Directory $SOURCE_DIR does not exist"
    exit 1
fi

if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    if [ $? -ne 0 ];
        echo "Failed to create backup directory"
        exit 1
    fi
fi
# $? stores the exit code
# ne is not equal to 


echo "Creating backup"
tar -czf "$BACKUP_FILE" -C "$SOURCE_DIR" .

# -C "$SOURCE_DIR" mean change into the source directory before archiving (so the archive doesn’t contain full paths, just relative structure)
#  . means all files in that directory

if [ $? -eq 0 ]; then
    echo "Backupfile created at $BACKUP_FILE"
else
    echo "Backup failed"
    exit 1
fi
