#!/bin/bash

echo "Biginning of backup delete"

if [ -z $back_time ]; then
	read -p "Type backup to keep: " back_days
fi

date_format="%d-%m-%Y"
today_date=`date +$date_format`

#calcul of back up date : do difference between today and back_time days
back_date=`date --date="$back_days days ago" +"$date_format"`

echo "The date today is $today_date"
echo "$today_date to $back_date is $back_days"

#delete backup
#this cmd execute with minutes criteria
#for days criteria use -ctime int the -mmin place

#find /backup_directory/* -type d -mmin +period -exec rm -r {} \;
find /home/hermannn/Documents/* -type d -mmin +"$back_days" -exec rm -r {} \;

mkdir "$back_date"
echo "Folder created with success"
