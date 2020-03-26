#!/bin/bash

###################################
###### THIS SCRIPT SHOULD BE ######
####### SCHEDULED ON CRON #########
###################################

###################################
## THIS SCRIPT DOWNLOADS A MYSQL ##
## DUMP FROM A REMOTE SERVER AND ##
##        RUNS IT LOCALLY        ##
###################################

mkdir /var/www/mysqldump
cd /var/www/mysqldump

touch mysqldump.log

IP="REMOTE_SERVER_IP"

DBUSER="USER"
DBPASS="PASSWORD"
CONN="-u$DBUSER -p$DBPASS"
IPCONN="$IP -u$DBUSER -p$DBPASS"

function logAction() {
    CURDATE=$(date "+%d-%m-%Y %H:%M:%S")
    LOG="| MySQL DUMP | $CURDATE | "
    echo "$LOG $1" >> mysqldump.log
}

function dumpDB() {
    logAction "Started dumping $1 database..."
    mysqldump -h $IPCONN $1 > $1.sql
    logAction "Finished dumping $1 database"
}

function fixDump() {
    logAction "Fixing dump $1..."
    sed -i -e 's/ROW_FORMAT=FIXED//g' $1.sql
    logAction "Dump $1 fixed"
}

function dropDatabase() {
    logAction "Dropping database $1..."
    echo "DROP DATABASE $1;" | mysql -N $CONN
    logAction "Dropped database $1"
}

function createDatabase() {
    logAction "Creating database $1..."
    echo "CREATE DATABASE $1;" | mysql -N $CONN
    logAction "Created database $1"
}

function runDump() {
    logAction "Running dump $1..."
    mysql $CONN $1 < $1.sql
    logAction "Finished running dump $1"
}

function removeDump() {  
    logAction "Removing $1 dump file.."
    rm $1.sql
    logAction "Removed $1 dump file.."
}

dumpDB "DATABASE_NAME"

fixDump "DATABASE_NAME"

dropDatabase "DATABASE_NAME"

createDatabase "DATABASE_NAME"

runDump "DATABASE_NAME"

removeDump "DATABASE_NAME"

logAction "Script finished!"
