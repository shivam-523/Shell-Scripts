#Create a bash script that can backup, restore, and compare configuration files 
# essential for system administrators who need to track changes and recover from misconfigurations. 
#Common config files: /etc/ssh/sshd_config, /etc/nginx/nginx.conf, ~/.bashrc, etc.

#!/bin/bash

BACKUP_DIR="$HOME/backup_configurationfiles"

CONFIG_FILES=("/etc/ssh/sshd_config" "/etc/nginx/nginx.conf" "$HOME/.bashrc")

#CONFIG_FILES=(..) creates a bash array which is allowing to store multiple configuration files
#Accessing an array element: echo "${CONFIG_FILES[0]}"

mkdir -p "$BACKUP_DIR"

backup() {
    echo "Backing up Configuration files"
    for file in "${CONFIG_FILES[@]}" ;  do
        if [ -f "$file" ]
            cp "$file" "$BACKUP_DIR/" 
            echo "Backed up $file"
        else    
            echo "File not found"
        fi
    done
}
#  for file in "${CONFIG_FILES[@]}"; - Loops through each elemetn in CONFIG_FILES array
#  @ expands to all elements of the array

restore(){
    echo "Restoring Configuration files"
    for file in "${CONFIG_FILES[@]}" 
        do 
            backup_file="$BACKUP_DIR/$(basename "$file")"
            if [ -f "$backup_file" ]
                then    
                    cp "$backup_file" "$file"
                    echo "Restored $file"
            else    
                echo "Backup not found"
            fi
    done
}
#basename "$file" extracts just the filename from a path.
#ex : /etc/nginx/nginx.conf : nginx.conf.

compare() {
    echo "Comparing configuration files..."
    for file in "${CONFIG_FILES[@]}"; do
        backup_file="$BACKUP_DIR/$(basename "$file")"
        if [ -f "$file" ] && [ -f "$backup_file" ]; then
            if diff -u "$backup_file" "$file" > /dev/null; then
                echo "No differences in $file"
            else
                echo "Differences found in $file"
                diff -u "$backup_file" "$file"
            fi
        else
            echo "Missing file or backup for: $file"
        fi
    done
}
#diff -u (unified diff) between the backup file and the current file. This shows line-by-line differences (like in Git).
#If diff does not difference it gives exit code 0 and there are no differences found
#If diff finds difference then it gives exit code 1

while true  
    do  
        echo -e "\n===========Config manager===================="
        echo "1. Backup Configiuration files"
        echo "2. Restore Configuration files"
        echo "3. Compare Configuration files"
        echo "4. Exit"
        read -p "Choose an option between 1-4: " choice

        case "$choice" in
            1) backup ;;
            2) restore ;;
            3) compare ;;
            4) echo "Exiting"; exit 0 ;;
            *) echo "Invalid option. Try again";;
        esac
done

#-e lets /n create a new line before the menu
# case is like switch block in C. ;; is used as break inside switch block
# *) is used like default in switch block
