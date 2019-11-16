# mysql-dropbox-auto-backup

Dump MySQL databases, compress them and upload to [Dropbox]. Backups are kept for 7 days.

## Overview

`mysql-dropbox-aut-backup` is a simple shell script that will use `mysqldump` to dump all of your MySQL databases, omitting any that you specify, add them to a compressed tarball, and upload them to [Dropbox]. By defauly it will also dump the MySQL `user` table unless you tell the script not to in `mysql-drop-backup.sh`. The script makes use of the [Dropbox-Uploader] project by [Andrea Fabrizi] and [mysql-dropbox-backup] project by [Barnaby Knowles] Run it as a daily cron job to keep 7 days of backups. On each run it will try to delete the backup taken 7 days ago.

## Requirements

* cURL
* A [Dropbox] account

Most Linux systems will come with cURL and OpenSSL installed. [Dropbox] gives away 2GB of storage for free.

## Installation

First, clone the repository using git (recommended):
  
  git clone https://github.com/wcaaan/mysql-dropbox-auto-backup.git

Place your script directly in home directory.

## Configuration

Edit `mysql-dropbox-backup.cf` to add your MySQL connection details.

Edit the top section of `mysql-dropbox-backup.sh` if you wish to change MySQL config file location. By default it is set to the current directoy. edit the list of ignored databases if you wish. You can also choose whether to dump the MySQL `user` table or not.

Edit the path if necessary, by default it is set to the current directory.

## Usage

The first thing you should do is give the execution permission to the `dropbox_uploader.sh` script and run it:

```bash
 $chmod +x dropbox_uploader.sh
 $./dropbox_uploader.sh
```

The first time you run `dropbox_uploader.sh`, you'll be guided through a wizard in order to configure access to your Dropbox. This configuration will be stored in `~/.dropbox_uploader`. Once the dropbox is configured simply run 

```
./mysql-dropbox-backup.sh
```


Ideally this script should be run as a daily cron job. After uploading the present backup, it will attempt to delete the backup from 7 days previous, so that only one week of backups are retained. The script is quite verbose and will output which databases were backed up and the names of any files generated etc.

## Restoring a Backup

Simply download the desired file from your dropbox, extract it and the SQL files will be available to restore within the resulting directory.

## CronJob / Crontab

Note: In below mentioned cronjob command you will see the output is logged into output.log file, when using this package on hosting sometime ./ in mysql-dropbox-backup.sh

* **GUI:** If using cpanel cronjob, set yout cronjob time settings and add following in the command

```
/home/you_user/mysql-dropbox-auto-backup/mysql-dropbox-backup.sh&>/home/you_user/mysql-dropbox-auto-backup/output.log
```

* **CLI:** If using cli run this command 
```
crontab -e 
```
Add the following command at the end of page and set your crontab execution time as you wish.
```
0 11,15,19,23 * * * /home/you_user/mysql-dropbox-auto-backup/mysql-dropbox-backup.sh&>/home/you_user/mysql-dropbox-auto-backup/output.log
```

   [Dropbox]: <https://www.dropbox.com>
   [Dropbox-Uploader]: <https://github.com/andreafabrizi/Dropbox-Uploader>
   [Andrea Fabrizi]: <https://github.com/andreafabrizi>
   [mysql-dropbox-backup]: <https://github.com/barns101/mysql-dropbox-backup>
   [Barnaby Knowles]: <https://github.com/barns101>