#!/bin/bash

# quit if we're called for the loopback
if [ "$IFACE" = lo ]; then
	echo "iface is loopback"
	exit 0
fi

if [ x"$IF_DNSMASQ_RANGE" == "x" ]; then
	echo "no dnsmasq range"
	exit 0
fi

DNSMASQ_PIDFILE="/run/dnsmasq_$IFACE.pid"
DNSMASQ_RANGE="$IF_DNSMASQ_RANGE,$IF_NETMASK,12h"

do_start()
{
	dnsmasq -x $DNSMASQ_PIDFILE -F $DNSMASQ_RANGE -i $IFACE -I lo
}

do_stop()
{
	if [ -f $DNSMASQ_PIDFILE ]; then
		kill $(cat $DNSMASQ_PIDFILE)
		rm -f $DNSMASQ_PIDFILE
	fi
}

case $MODE in
	start)
		case $PHASE in
			pre-up)
				;;
			post-up)
				do_start
				;;
			*)
				;;
		esac
		;;
	stop)
		case $PHASE in
			pre-down)
				do_stop
				;;
			post-down)
				;;
			*)
				;;
		esac
		;;
	*)
		echo "Unknown mode \"$MODE\""
		;;
esac
