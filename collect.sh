#!/bin/bash
# Copyright (c) 2015 Peter Reuterås <peter@reuteras.net>
#
# Main script to run and collect block lists.
#

CONF="collect.conf"

. common.sh
conf

# Setup output directory
if [ ! -d output ]; then
  mkdir output
else
  rm -f output/*
fi

# Handle bro
if [[ $BRO == "yes" ]]; then
  # Check bro part of CONF
  [[ ! ($BROUSER && ${BROUSER-x}) ]] &&	eexit "BROUSER not set."
  [[ ! ($BROSERVER && ${BROSERVER-x}) ]] && eexit "BROSERVER not set."
  [[ ! ($REMDIR && ${REMDIR-x}) ]] && eexit "REMDIR not set in $CONF."

  # Connect to bro server and get data.
  ssh $BROUSER@$BROSERVER mkdir -p $REMDIR
  scp -q collect.conf bro_conn_data.sh common.sh $BROUSER@$BROSERVER:$REMDIR/
  ssh $BROUSER@$BROSERVER "cd ./$REMDIR && chmod +x bro_conn_data.sh"
  ssh $BROUSER@$BROSERVER "cd ./$REMDIR && ./bro_conn_data.sh"
  scp -q $BROUSER@$BROSERVER:$REMDIR/output/* output/
  ssh $BROUSER@$BROSERVER "cd ./$REMDIR && rm -f output/*"
fi

if [[ $HTTPD == "yes" ]]; then
  # Check bro part of CONF
  [[ ! ($HTTPUSER && ${HTTPUSER-x}) ]] &&	eexit "HTTPUSER not set."
  [[ ! ($HTTPSERVER && ${HTTPSERVER-x}) ]] && eexit "HTTPSERVER not set."
  [[ ! ($REMDIR && ${REMDIR-x}) ]] && eexit "REMDIR not set in $CONF."

  # Connect to http server and get data.
  LIST="httpd"
  header $SITENAME $LIST $DATE $YEAR "$NAME" $BASEURL > output/$LIST.txt
  for SERVER in $HTTPSERVER; do
    ssh $HTTPUSER@$SERVER mkdir -p $REMDIR
    scp -q collect.conf httpd.sh common.sh $HTTPUSER@$SERVER:$REMDIR/
    ssh $HTTPUSER@$SERVER "cd ./$REMDIR && chmod +x httpd.sh"
    ssh $HTTPUSER@$SERVER "cd ./$REMDIR && ./httpd.sh" >> output/tmp.txt
  done
  cat output/tmp.txt | \
    sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n >> output/$LIST.txt
  rm output/tmp.txt
fi
