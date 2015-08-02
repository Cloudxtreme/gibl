#!/bin/bash
#
# Copyright (c) 2015 Peter Reuterås <peter@reuteras.net>
#
# Common functions
#

# Common variables
DATE=$(date +%Y-%m-%d)
YEAR=$(date +%Y)

# Function: conf
# Description: Load config file.
function conf(){
  if [ -f $CONF ]; then
    . $CONF
  else
    echo "Config file $CONF not found."
    exit 1
  fi
}

# Function: eexit
# Description: Exit on error with message.
# Arguments
# - Text to echo on error
#
function eexit(){
  echo $1
  exit 1
}

# Function: header
# Description: Print header for lists
# Arguments:
# - SITENAME
# - LIST
# - DATE
# - YEAR
# - NAME
# - BASEURL
#
function header(){
	echo "; $1 DROP list $2 $3 - (c) $4 $5"
	echo "; $6/$2.txt"
	echo "; Last-Modified: $(date)"
}

# Function: run_file_and_get_data
# Description: Get data for one list from one script
# Arguments:
# - LIST
# - REMDIR
# - USER
# - SCRIPT
# - SERVERS
function run_file_and_get_data(){
  LIST=$1
  REMDIR=$2
  USER=$3
  SCRIPT=$4
  SERVERS=$5

  for SERVER in $SERVERS; do
    ssh $USER@$SERVER mkdir -p $REMDIR
    scp -q collect.conf common.sh $SCRIPT $USER@$SERVER:$REMDIR/
    ssh $USER@$SERVER "cd ./$REMDIR && chmod +x $SCRIPT"
    ssh $USER@$SERVER "cd ./$REMDIR && ./$SCRIPT" >> output/tmp.txt
  done
  cat output/tmp.txt | \
    sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n >> output/$LIST.txt
  rm output/tmp.txt
}
