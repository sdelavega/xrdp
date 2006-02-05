#!/bin/sh
# xrdp control script
# Written : 1-13-2006 - Mark Balliet - posicat@pobox.com

XRDP=xrdp
SESMAN=sesman
STARTWM=startwm.sh
XRDP_DIR=/usr/local/xrdp/
LOG=/dev/null

cd $XRDP_DIR

test -x $XRDP || (echo "$XRDP is not executable" ; exit 0)
test -x $SESMAN || (echo "$SESMAN is not executable" ; exit 0)
test -x $STARTWM || (echo "$STARTWM is not executable" ; exit 0)

xrdp_start () {
  echo -n "Starting : xrdp and sesman . . "
  ./$XRDP >> $LOG
  ./$SESMAN >> $LOG
  echo "."
  sleep 1
  return 0
}

xrdp_stop () {
  echo -n "Stopping : xrdp and sesman . . "
  ./$SESMAN --kill >> $LOG
  ./$XRDP --kill >> $LOG
  echo "."
}

check_up () {
  xrdpup=`ps u --noheading -C $XRDP`
  sesup=`ps u --noheading -C $SESMAN`

  # Cleanup : If sesman isn't running, but the pid exists, erase it.
  if [ "$sesup" == "" ]
  then
     if [ -e /var/run/sesman.pid ] ; then rm /var/run/sesman.pid ; fi
  fi
}

case "$1" in
  start)
     check_up
     if [ "$xrdpup" != "" ]
     then
        echo "Xrdp is already loaded"
        exit 1
     fi
     if [ "$sesup" != "" ]
     then
        echo "sesman is already loaded"
        exit 1
     fi
     xrdp_start
     ;;
  stop)
     check_up
     if [ "$xrdpup" == "" ]
     then
        echo "xrdp is not loaded."
     fi
     if [ "$sesup" == "" ]
     then
        echo "sesman is not loaded."
     fi
     xrdp_stop
     ;;
  force-reload|restart)
     check_up
     echo "Restarting Xrdp ..."
     xrdp_stop
     while [ "$xrdpup" != "" ]; do
        check_up
        sleep 1
     done
     xrdp_start
     ;;
  *)
     echo "Usage: xrdp_daemon {start|stop|restart|force-reload}"
     exit 1
esac

exit 0