#reate a bash script that can automatically backup databases (MySQL/PostgreSQL)
# Compress the backups, and manage old backups according to a retention policy to prevent disk space issues. 
#Compress backup files to save disk space 
#Delete old backups automatically
#!/bin/bash
#Executing the script ./db_backup_script.sh mysql mydb GROOT Groot@11

BACKUP_DIR="/var/backup/databases"
RETENTION_DAYS=7
DATE=$(date +'%Y-%m-%d %H-%M-%S')

DB_TYPE="$1" #Database type either mysql/postgress
DB_NAME="$2"
DB_USER="$3" #username
DB_PASSWORD="$4"  #password

mkdir -p "$BACKUP_DIR"
#Ensures that backup directory exists

#it's used to display progress messages on screen while the script runs
log_msg(){
    echo "$(date '+%Y-%m-%d %H:%M:%S')- $1"
}

backup_mysql(){
    export MYSQL_PASSWORD="$DB_PASSWORD"
    FILE="$BACKUP_DIR/$DB_NAME_$DATE.sql.gz"
    log_msg "Starting mysql backup for $DB_NAME"
    mysqldump -u "$DB_USER" "$DB_NAME" | gzip > "$FILE"

    if [ $? -eq 0 ]; then   
        log_msg "MYSQL Backup is successful : $FILE"
    else    
        log_msg "MYSQL Backup failed"
        exit 1
    fi
}
#export command Sets the environment variable MYSQL_PWD so mysqldump can use it without prompting for a password.his is more secure than writing the password directly in the command
#mysqldump : exports the database structure & data as SQL commands
#password comes from MYSQL_PASSWORD
#pg_dump and mysqldump both create backup in .sql format

backup_postgres(){
    export POSTGRESS_PASSWORD="$DB_PASSWORD"
    FILE="$BACKUP_DIR/$DB_NAME_$DATE.sql.gz"
    log_msg "Starting postgress backup for $DB_NAME"
    pg_dump -U "$DB_USER" -d "$DB_NAME" | gzip > "$FILE"

    if [ $? -eq 0 ]; then   
        log_msg "Postgress Backup is successful : $FILE"
    else    
        log_msg "Postgress Backup failed"
        exit 1
    fi
}
#PostgreSQL tools (like pg_dump) don’t accept the password directly on the command line for security reasons.
#pg_dump will automatically read the password from PGPASSWORD instead of prompting the user
#pg_dump exports (dumps) the entire database into a text file or archive.
#The dump file contains all the SQL statements needed to recreate the database (tables, schema, data, constraints, etc.).


cleanup_backups(){
    find "$BACKUP_DIR" -type f -mtime +"$RETENTION_DAYS" -name "*.gz" -exec rm {} \;
    log_msg "Old backup cleanup complete."

}
#-type f only look for files
#-mtime : modified time is more than 7 days ago
#\; ends the exec command

if [[ "$DB_TYPE" == "mysql" ]]; then   
    backup_mysql
elif [[ "$DB_TYPE" == "postgres" ]]; then
    backup_postgres
else    
    echo "Enter the database type as mysql or postgress"
fi


cleanup_backups