#!/bin/bash
#
# Copyright (c) 2015 Peter Reuterås <peter@reuteras.net>
#
# Common functions
#

# Common variables
DATE=$(/usr/bin/date +%Y-%m-%d)
YEAR=$(/usr/bin/date +%Y)

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
	echo "; Last-Modified: $(/usr/bin/date)"
}
