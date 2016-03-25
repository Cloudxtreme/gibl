#!/bin/bash
# Copyright (c) 2015 Peter Reuterås <peter@reuteras.net>
#
# Main script to run and collect block lists.
#

CONF="collect.conf"

# shellcheck disable=SC1091
. common.sh
conf

# Setup output directory
if [ ! -d output ]; then
  mkdir output
else
  rm -f output/*
fi

# Common things to check for in config.
[[ ! ($REMDIR && ${REMDIR-x}) ]] && eexit "REMDIR not set in $CONF."
[[ ! ($IGNORE && ${IGNORE-x}) ]] && eexit "IGNORE not set in $CONF."

# Validate Bro config.
if [[ $BRO == "yes" ]]; then
    # Check bro part of CONF
    [[ ! ($BROUSER && ${BROUSER-x}) ]] &&	eexit "BROUSER not set."
    [[ ! ($BROSERVER && ${BROSERVER-x}) ]] && eexit "BROSERVER not set."
fi

# Validate apache httpd config.
if [[ $HTTPD == "yes" ]]; then
    # Check bro part of CONF
    [[ ! ($HTTPUSER && ${HTTPUSER-x}) ]] &&	eexit "HTTPUSER not set."
    [[ ! ($HTTPSERVER && ${HTTPSERVER-x}) ]] && eexit "HTTPSERVER not set."
fi

# Validate postfix config.
if [[ $POSTFIX == "yes" ]]; then
    # Check bro part of CONF
    [[ ! ($PFIXUSER && ${PFIXUSER-x}) ]] &&	eexit "PFIXUSER not set."
    [[ ! ($PFIXSERVER && ${PFIXSERVER-x}) ]] && eexit "PFIXSERVER not set."
fi

# Get bro data.
if [[ $BRO == "yes" ]]; then
    # Connect to bro server and get data.
    # shellcheck disable=SC2029
    ssh "$BROUSER"@"$BROSERVER" mkdir -p "$REMDIR"
    scp -q collect.conf bro_conn_data.sh common.sh "$BROUSER"@"$BROSERVER":"$REMDIR"/
    ssh "$BROUSER"@"$BROSERVER" cd ./"$REMDIR" && chmod +x bro_conn_data.sh
    ssh "$BROUSER"@"$BROSERVER" cd ./"$REMDIR" && ./bro_conn_data.sh
    scp -q "$BROUSER"@"$BROSERVER":"$REMDIR"/output/* output/
    # shellcheck disable=SC2029
    ssh "$BROUSER"@"$BROSERVER" "cd ./$REMDIR && rm -f output/*"
fi

# Connect to http servers and get data.
if [[ $HTTPD == "yes" ]]; then
    LIST="httpd"
    header "$SITENAME" "$LIST" "$DATE" "$YEAR" "$NAME" "$BASEURL" > "output/$LIST.txt"
    run_file_and_get_data "$LIST" "$REMDIR" "$HTTPUSER" "$LIST.sh" "$HTTPSERVER"
fi

# Connect to postfix servers and get data.
if [[ $POSTFIX == "yes" ]]; then
    LIST="postfix"
    header "$SITENAME" "$LIST" "$DATE" "$YEAR" "$NAME" "$BASEURL" > "output/$LIST.txt"
    run_file_and_get_data "$LIST" "$REMDIR" "$PFIXUSER" "$LIST.sh" "$PFIXSERVER"
fi
