#!/bin/bash

# quit if we're called for the loopback
if [ "$IFACE" == lo ]; then
	echo "iface is loopback"
	exit 0
fi

if [ "$IFACE" == "--all" ]; then
	exit 0
fi

if [ x"$IF_HOSTAPD" == "x" ]; then
	echo "no hostapd conf"
	exit 0
fi

HOSTAPD_PIDFILE="/run/hostapd_$IFACE.pid"

do_start()
{
	hostapd -B -P $HOSTAPD_PIDFILE $IF_HOSTAPD
}

do_stop()
{
	if [ -f $HOSTAPD_PIDFILE ]; then
		kill $(cat $HOSTAPD_PIDFILE)
		rm -f $HOSTAPD_PIDFILE
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
