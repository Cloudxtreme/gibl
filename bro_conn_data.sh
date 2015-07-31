#!/bin/bash
#
# Copyright (c) 2015 Peter Reuterås <peter@reuteras.net>
#
# Script to collect bad actors from bro.org data.
#

CONF="bro.conf"

. common.sh
conf

if [[ $TOOLPATH && ${TOOLPATH-x} ]]; then
	PATH=$PATH:$TOOLPATH
else
	PATH=/usr/sbin:/usr/bin:/sbin:/bin:/opt/bro/bin
fi

if [[ ! ($MYNET && ${MYNET-x}) ]]; then
	echo "MYNET not set in $CONF."
	exit 1
fi

if [[ ! ($FILES && ${FILES-x}) ]]; then
	FILES=$(find /nsm/bro/logs/ -name "conn.*" -mtime -14 -type f -print | xargs)
fi

if [[ ! ($NAME && ${NAME-x}) ]]; then
	NAME="No Name"
fi

if [[ ! ($BASEURL && ${BASEURL-x}) ]]; then
	BASEURL="http://127.0.0.1"
fi

if [[ ! ($SITENAME && ${SITENAME-x}) ]]; then
	SITENAME="Site name"
fi

IP172_1="172\.16\.|172\.17\.|172\.18\.|172\.19\.|172\.20\.|172\.21\."
IP172_2="172\.22\.|172\.23\.|172\.24\.|172\.25\.|172\.26\.|172\.27\."
IP172_3="172\.28\.|172\.29\.|172\.30\.|172\.31\."
LOCAL="0\.0\.0\.0|10\.|127\.|$IP172_1|$IP172_2|$IP172_3|192\.168|255\.255\.255\.255"

IGNORE="$LOCAL|$MYNET"

TMPDIR=$(/bin/mktemp -d)

function cleanup(){
	rm -rf $TMPDIR
	exit 0
}
trap cleanup ERR

function search(){
	zcat $FILES | bro-cut id.orig_h id.resp_p | \
		egrep -v "^($IGNORE)" | \
		grep -v ":" | \
		egrep $2 $'\t'"($1)"'$' | \
		awk '{print $1}' | \
		sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n | uniq
}

# Generate list of database searches
# - 1433:	MSSQL
# - 1434:	MSSQL
# - 1521:	Oracle DB
# - 3306:	MySQL
# - 5432:	PostgreSQL
LIST="database"
header $SITENAME $LIST $DATE $YEAR "$NAME" $BASEURL > $TMPDIR/$LIST.txt
search "1433|1434|1521|3306|5432" "" >> $TMPDIR/$LIST.txt

# Generate list of misc searches
# - 631:	Internet Printing Protocol
# - 1099: 	Java RMI Registry
# - 4899:	RAdmin Port
# - 5555:	RPlay audio service
# - 10000:	webmin
# - 10082:	amanda backup services
LIST="misc"
header $SITENAME $LIST $DATE $YEAR "$NAME" $BASEURL > $TMPDIR/$LIST.txt
search "631|1099|4899|5555|10000|10082" "" >> $TMPDIR/$LIST.txt

# Generate list of ssh and telnet searches
# - 22:		SSH
# - 23:		Telnet
# - 992:	Telnet over SSL
LIST="shell"
header $SITENAME $LIST $DATE $YEAR "$NAME" $BASEURL > $TMPDIR/$LIST.txt
search "22|23|992" "" >> $TMPDIR/$LIST.txt

# All except open ports
# - 25:		SMTP
# - 80:		HTTP
# - 443:	HTTPS
LIST="closed"
header $SITENAME $LIST $DATE $YEAR "$NAME" $BASEURL > $TMPDIR/$LIST.txt
search "25|80|443|7000|7001|7002|7003|7004|7005|7007" "-v" >> $TMPDIR/$LIST.txt

# Collect data.
if [ ! -d output ]; then
	mkdir output
fi
rm -f output/*
cp $TMPDIR/* output
rm -rf $TMPDIR

exit 0
