#!/bin/sh
#
# Postgresql backup script
#
# Author
#  |
#  +-- speedboy (speedboy_420 at hotmail dot com)
#  +-- spiderr (spiderr at bitweaver dot org)
#
# Last modified
#  |
#  +-- 16-10-2001
#  +-- 16-12-2007
#
# Version
#  |
#  +-- 1.1.2
#
# Description
#  |
#  +-- A bourne shell script that automates the backup, vacuum and
#      analyze of databases running on a postgresql server.
#
# Tested on
#  |
#  +-- Postgresql
#  |    |
#  |    +-- 8.1.9
#  |    +-- 7.1.3
#  |    +-- 7.1.2
#  |    +-- 7.1
#  |    +-- 7.0
#  |
#  +-- Operating systems
#  |    |
#  |    +-- CentOS 5 (RHEL 5)
#  |    +-- Linux Redhat 6.2
#  |    +-- Linux Mandrake 7.2
#  |    +-- FreeBSD 4.3
#  |    +-- Cygwin (omit the column ":" because NT doesn't quite digest it)
#  |
#  +-- Shells:
#       |
#       +-- sh
#       +-- bash
#       +-- ksh
#
# Requirements
#  |
#  +-- grep, awk, sed, echo, bzip2, chmod, touch, mkdir, date, psql,
#      test, expr, dirname, find, tail, du, pg_dump, vacuum_db
#
# Installation
#  |
#  +-- Set the path and shell you wish to use for this script on the
#  |   first line of this file. Keep in mind this script has only been
#  |   tested on the shells above in the "Tested on" section.
#  |
#  +-- Set the configuration variables below in the configuration
#  |   section to appropriate values.
#  |
#  +-- Remove the line at the end of the configuration section so that
#  |   the script will run.
#  |
#  +-- Now save the script and perform the following command:
#  |
#  |   chmod +x ./pg_backup.sh
#  |
#  +-- Now run the configuration test:
#  |
#  |   ./pg_backup.sh configtest
#  |
#  |   This will test the configuration details.
#  |
#  +-- Once you have done that add similiar entries given as examples
#      below to the crontab (`crontab -e`) without the the _first_ #
#      characters.
#
#      # Run a backup of the remote database host 'foodb', likely on a private network
#      00 03 * * * export PGHOST=foodb; export PGBACKUPDIR=/bak/backups ; nice /server/postgres/pg_backup.sh b 2  >> /var/log/pgsql/pg_backup.log 2>&1
#      # Run a backup of the local database host 'foodb' to a custom backup directory
#      00 04 * * * export PGBACKUPDIR=/bak/backups ; nice /usr/bin/pg_backup b 2  >> /var/log/pgsql/pg_backup.log 2>&1
#
# Restoration
#  |
#  +-- Restoration can be performed by using psql or pg_restore.
#  |   Here are two examples:
#  |
#  |   a) If the backup is plain text:
#  |
#  |   Firstly bunzip2 your backup file (if it was bzip2ped).
#  |
#  |   nunzip2 backup_file.bz2
#  |   psql -U postgres database < backup_file
#  |
#  |   b) If the backup is not plain text:
#  |
#  |   Firstly bunzip2 your backup file (if it was bzip2ed).
#  |
#  |   bunzip2 backup_file
#  |   pg_restore -d database -F {c|t} backup_file
#  |
#  |   Note: {c|t} is the format the database was backed up as.
#  |
#  |   pg_restore -d database -F t backup_file_tar
#  |
#  +-- Refer to the following url for more pg_restore help:
#
#      http://www.postgresql.org/idocs/index.php?app-pgrestore.html
#
# To Do List
#              1. db_connectivity() is BROKEN, if the script can not create a
#                 connection to postmaster it should die and write to the logfile
#                 that it could not connect.
#              2. make configtest check for every required binary
#
########################################################################
#                          Start configuration                         #
########################################################################
#
##################
# Authentication #
##################
#
# Postgresql hostname to connect to.
if [ $PGHOST ]; then
        PARAM_PGHOST="-h $PGHOST"
else
        PGHOST="localhost"
fi

# Postgresql username to perform backups under.
if [ -z $PGUSER ]; then
        PGUSER="hermannn"
fi

# Postgresql password for the Postgresql username (if required).
postgresql_password="odootest"

##################
# Locations      #
##################
#
# Restoration database name
if [ -z $PGDATABASE ]; then
	PGDATABASE="hermannn"
fi
#
# Location to get backup file.
if [ -z $PGBACKUPDIR ]; then
        PGBACKUPDIR="/root/backups/2018-07/pg_db-localhost-hermannn-backup-2018-07-02-1759.bz2"
fi

# Location to place the restoration.sh logfile.
if [ -z $PGLOGDIR ]; then
        PGLOGDIR="/var/log/odoo/restoration.log"
fi

# Location of the psql binaries.
if [ -z $PGBINDIR ]; then
        PGBINDIR="/usr/bin"
fi


##################
# Execution	 #
##################
#
# Unzip backup file
extract_path=`bunzip2 $PGBACKUPDIR`

#$extract_path=${PGBACKUPDIR%.bz2*}

restoration_date_format="%Y-%m-%d"

# Execute restoration command.
execution=`pg_restore -U $PGUSER -F t -d $PGDATABASE ${PGBACKUPDIR%.bz2*}`
$execution
finish_time=`date +$restoration_date_format`
echo "Restoration completed with success at : $finish_time" >> $PGLOGDIR

