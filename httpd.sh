#!/bin/bash
#
# Copyright (c) 2015 Peter Reuterås <peter@reuteras.net>
#
# Script to collect bad actors from apache httpd logs.
#

CONF="collect.conf"

. common.sh
conf

if [[ $TOOLPATH && ${TOOLPATH-x} ]]; then
	PATH=$PATH:$TOOLPATH
else
	PATH=/usr/sbin:/usr/bin:/sbin:/bin
fi

[[ ! ($GOODURLS && ${GOODURLS-x}) ]] && eexit "GOODURLS not set in $CONF."
[[ ! ($BADURLS && ${BADURLS-x}) ]] && eexit "BADURLS not set in $CONF."

if [[ ! ($FILES && ${FILES-x}) ]]; then
  if [ -d "/var/log/apache2" ]; then
    DIR="/var/log/apache2"
  else
    DIR="/var/log/httpd"
  fi
  FILES=$(find $DIR -name "access*log*" -mtime -17 -type f | xargs)
fi

zcat -f $FILES | \
	grep "\" 404 " | \
  egrep -v "(GET|HEAD|POST) ($GOODURLS)" | \
  egrep "($BADURLS)" | \
  cut -f1 -d\  | \
	egrep -v $IGNORE | \
	sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n | \
	uniq
