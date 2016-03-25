#!/bin/bash
#
# Copyright (c) 2015 Peter Reuterås <peter@reuteras.net>
#
# Script to collect bad actors from postfix logs.
#

# shellcheck disable=SC2034
CONF="collect.conf"

# shellcheck disable=SC1091
. common.sh
conf

if [[ $TOOLPATH && ${TOOLPATH-x} ]]; then
	PATH=$PATH:$TOOLPATH
else
	PATH=/usr/sbin:/usr/bin:/sbin:/bin
fi

if [[ ! ($PFIXFILES && ${PFIXFILES-x}) ]]; then
	PFIXFILES=($(find /var/log/ -name "mail*" -mtime -17 -type f -print0 | xargs -0))
fi

zcat -f "${PFIXFILES[@]}" | \
    grep "NOQUEUE: reject: RCPT from" | \
    sed -e "s/.*RCPT.*\[//" | \
    sed -e "s/\].*//" | \
    egrep -v "$IGNORE" | \
    sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n | \
    uniq
