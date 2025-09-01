#Create a script called service_check.sh that checks the status of a service provided by command line argument 
#Also provide options to restart failed service

#!/bin/bash

if [ -z "$1" ]; then    
    echo "Provide the servicename as an argument"
    exit 1
fi
 
SERVICE_NAME="$1"

if systemctl is-active --quiet "$SERVICE_NAME"; then   
    echo "Service is up and running fine"

else
    echo "Do you want to restart $SERVICE_NAME (y/n): "
    read choice
    
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        sudo systemctl restart "$SERVICE_NAME"
        if systemctl is-active --quiet "$SERVICE_NAME"; then   
            echo "Service has been restarted and it is now running fine"
        else    
            echo "Failed to restart the service"
            exit 1
        fi
    else
        echo "Skipping the service restart"
    fi
fi

#systemctl is-active this command will provide output as active/inactive
# --quiet supresses the output, so anything wont be printed and instead it relies on the exit code
# exit code - 0 (service is active/running)
# exit code - non-zero (service is inactive/failed/not running)
