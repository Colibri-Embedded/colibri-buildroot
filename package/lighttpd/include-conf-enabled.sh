#!/bin/bash

if [ "x$1" == "x" ]; then
	CONF_DIR="/etc/lighttpd"
else
	CONF_DIR=$1
fi

CONF_ENABLED="${CONF_DIR}/conf-enabled"

for file in ${CONF_ENABLED}/*.conf; do
	if [ -e "$file" ] ; then
		echo "include \"$file\""
	fi
done
