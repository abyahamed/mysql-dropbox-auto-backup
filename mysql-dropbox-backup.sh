#!/bin/bash

################################################################
# Configuration section                                        #
#                                                              #
# Enter your MySQL connection details in the config file shown #
# below, choose an encryption password and specify which       #
# databases should not be backed up                            #
################################################################

# This Script Path (without forward slash at end) ex: /home/airportparkings/mysql-dropbox-auto-backup
# If using all from root folder set path to ./mysql-dropbox-auto-backup
# path=/home/airportparkings/mysql-dropbox-auto-backup
# path=./mysql-dropbox-auto-backup
path=$PWD

# MySQL config file
config=$path/mysql-dropbox-backup.cnf

# List of databases to ignore (space separated)
db_ignore=(Database information_schema mysql performance_schema)

# Should we backup the MySQL "user" table?
backup_mysql_user_table=false

################################
# End of configuration section #
#                              #
# Nothing to edit below here   #
################################

# Get a list of databases
db_arr=$(echo "show databases;" | mysql --defaults-extra-file=$config)

# Get the current date. Used for file names etc...
current_date=$(date +"%Y-%m-%d")
# current_date=$(date +'%d-%m-%Y--%H:%M:%S')

# Get the date 7 days ago. Used to delete the redundant backup file.
old_date=$(date +"%Y-%m-%d" --date="7 days ago")

# Create a temporary backup directory to hold the SQL files, which will be deleted later
mkdir $current_date

# Backup each database (omitting any in the ignore list)
for dbname in ${db_arr}
do
    for i in "${db_ignore[@]}"
    do
        if ! [[ ${db_ignore[*]} =~ "$dbname" ]] ; then
            sqlfile=$current_date"/"$dbname".sql"
            echo "Dumping $dbname to $sqlfile"
            mysqldump --defaults-extra-file=$config $dbname > $sqlfile
            break
        fi
    done
done

# And finally, if configured, backup the "users" table from the "mysql" database that is omitted by default
if [[ "$backup_mysql_user_table" == true ]]; then
    sqlfile=$current_date"/mysql_users_table.sql"
    echo "Dumping MySql users table to $sqlfile"
    mysqldump --defaults-extra-file=$config mysql user > $sqlfile
fi

# Tar, compress the dumped SQL files
echo "Compressing dumped SQL files..."
tar cz $current_date > $current_date.tar.gz

# Remove the backups directory
echo "Removing dumped SQL files..."
rm -rf $current_date/

# Upload the backup tarball to Dropbox
echo "Uploading backup tarball to Dropbox..."
$path/dropbox_uploader.sh upload $current_date.tar.gz $current_date.tar.gz

# Delete the old backup
echo "Deleting old Dropbox backup..."
$path/dropbox_uploader.sh delete $old_date.tar.gz

# Delete the local copy of the backup tarball that we just created
echo "Deleting local backup tarball..."
rm -f $current_date.tar.gz

echo "Finished"
