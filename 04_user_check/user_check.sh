#Create a script called user_check.sh that checks if users exist on the system and displays their last login information.
#Display user's home directory and shell

#!/bin/bash

if [ -z "$1" ]; then
    echo "Please enter a username and re-run the script."
    exit 1
fi

USER="$1"

if grep -q "^$USER:" /etc/passwd; then
    echo "User $USER exists"

    LAST_LOGIN=$(last -n 1 "$USER")
    if [ -n "$LAST_LOGIN" ]; then    
        echo "$LAST_LOGIN"
    else    
        echo "User has no login history"
    fi

    USER_INFO=$(grep "^$USER:" /etc/passwd | awk -F: '{print "Home Directory : " $6 "\nShell: " $7}')
    echo "$USER_INFO"

else
    echo "User $USER does not exist into the system"
fi

# ./systeminfo.sh trump (Script can be executed in this way)
#-z is used to check whether string is empty
#-q quiet mode(no output just sets the exit code)
#"^$USER:" ensures it matches only at the start of the line, followed by a colon
#last -n 1 "$USER" → shows only the most recent login entry.
#the option -F sets the field separator on : (trump:x:1001:1001:Donald Trump:/home/trump:/bin/bash). As each field is seperated by colon.
#Default field seperator it will consider tabs/spaces