#!/bin/sh
#
# @(#) src/util/init/strerr.sh
# Copyright (c) 2008-2015  Monavacon Limited <http://www.monavacon.com/>
# Copyright (c) 2001-2008  OpenSS7 Corporation <http://www.openss7.com/>
# Copyright (c) 1997-2001  Brian F. G. Bidulock <bidulock@openss7.org>
# All Rights Reserved.
#
# Distributed by OpenSS7 Corporation.  See the bottom of this script for copying
# permissions.
#
# These are arguments to update-rc.d ala chkconfig and lsb.  They are recognized
# by openss7 install_initd and remove_initd scripts.  Each line specifies
# arguments to add and remove links after the the name argument:
#
# strerr:	start and stop strerr facility
# update-rc.d:	start 35 S . stop 35 0 6 .
# lockfile:	/var/lock/subsys/strerr
# config:	/etc/default/strerr
# processname:	strerr
# pidfile:	/var/run/strerr.pid
# probe:	true
# hide:		false
# license:	AGPL
# description:	This STREAMS init script is part of Linux Fast-STREAMS.  It is \
#		responsible for starting and stopping the STREAMS error \
#		logger.  The STREAMS error logger should only be run under \
#		exceptional circumstances and this init script not activated \
#		automatically.
#
# LSB init script conventions
#
### BEGIN INIT INFO
# Provides: strerr
# Required-Start: streams
# Required-Stop: streams
# Should-Start: $syslog
# Should-Stop: $syslog
# Default-Start: S
# Default-Stop:
# X-UnitedLinux-Default-Enabled: yes
# Short-Description: start and stop strerr
# License: AGPL
# Description:	This STREAMS init script is part of Linux Fast-STREAMS.  It is
#	responsible for starting and stopping the STREAMS error logger.  The
#	STREAMS error logger should only be run under exceptional circumstances
#	and this init script is not activated in any run level by default.
### END INIT INFO

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Source init script functions library.
init_mode="standalone"
  if [ -r /etc/init.d/functions   ] ; then . /etc/init.d/functions   ; init_mode="chkconfig" ;
elif [ -r /etc/rc.status          ] ; then . /etc/rc.status          ; init_mode="insserv"   ;
elif [ -r /lib/lsb/init-functions ] ; then . /lib/lsb/init-functions ; init_mode="lsb"       ;
elif [ -r /sbin/start-stop-daemon ] ; then                             init_mode="debian"    ;
fi

case "$init_mode" in
    (chkconfig)
	# RedHat's LSB support is not so good, use native functions first.
	daemon_start () {
	    local force= nicelevel= base=
	    while [ "$1" != "${1##[-+]}" ] ; do
		case $1 in
		    (-f) force="--force" ; shift 1 ;;
		    (-n) nicelevel="$2"  ; shift 2 ;;
		esac
	    done
	    base=`echo $1 | sed -e 's,.*/,,'`
	    echo -en "Starting daemon $base: "
	    daemon $force $nicelevel "$@"
	    RETVAL=$?
	    echo ""
	    return $RETVAL
	}
	daemon_stop () {
	    local base=
	    base=`echo $1 | sed -e 's,.*/,,'`; shift 1
	    echo -en "Stopping daemon $base: "
	    killproc $base "$@"
	    RETVAL=$?
	    echo ""
	    return $RETVAL
	}
	daemon_reload () {
	    local base=
	    base=`echo $1 | sed -e 's,.*/,,'`; shift 1
	    echo -en "Reloading daemon $base: "
	    killproc $base -HUP
	    RETVAL=$?
	    echo ""
	    return $RETVAL
	}
	;;
    (insserv)
	# SuSE's LSB support is not so good, use native functions first.
	daemon_start () {
	    local force= nicelevel= base=
	    while [ "$1" != "${1##[-+]}" ] ; do
		case $1 in
		    (-f) force="-f" ; shift 1 ;;
		    (-n) nicelevel="-n $2"  ; shift 2 ;;
		esac
	    done
	    base=`echo $1 | sed -e 's,.*/,,'`
	    echo -en "Starting daemon $base: "
	    startproc $force $nicelevel "$@"
	    RETVAL=$?
	    [ $RETVAL -eq 0 ] || rc_failed $RETVAL
	    rc_status -v
	    return $RETVAL
	}
	daemon_stop () {
	    local base=
	    base=`echo $1 | sed -e 's,.*/,,'`; shift 1
	    echo -en "Stopping daemon $base: "
	    killproc $base "$@"
	    RETVAL=$?
	    [ $RETVAL -eq 0 ] || rc_failed $RETVAL
	    rc_status -v
	    return $RETVAL
	}
	daemon_reload () {
	    local base=
	    base=`echo $1 | sed -e 's,.*/,,'`; shift 1
	    echo -en "Reloading daemon $base: "
	    killproc $base -HUP
	    RETVAL=$?
	    [ $RETVAL -eq 0 ] || rc_failed $RETVAL
	    rc_status -v
	    return $RETVAL
	}
	action () {
	    echo -en "$1"
	    shift 1
	    ${1+"$@"} >/dev/null
	    RETVAL=$?
	    [ $RETVAL -eq 0 ] || rc_failed $RETVAL
	    rc_status -v
	    return $RETVAL
	}
	;;
    (lsb)
	daemon_start () {
	    local force= nicelevel= base=
	    while [ "$1" != "${1##[-+]}" ] ; do
		case $1 in
		    (-f) force="-f" ; shift 1 ;;
		    (-n) nicelevel="-n $2"  ; shift 2 ;;
		esac
	    done
	    base=`echo $1 | sed -e 's,.*/,,'`
	    echo -en "Starting daemon $base: "
	    start_daemon $force $nicelevel "$@"
	    RETVAL=$?
	    [ $RETVAL -eq 0 ] && log_success_msg || log_failure_msg
	    return $RETVAL
	}
	daemon_stop () {
	    local base=
	    base=`echo $1 | sed -e 's,.*/,,'`; shift 1
	    echo -en "Stopping daemon $base: "
	    killproc $base "$@"
	    RETVAL=$?
	    [ $RETVAL -eq 0 ] && log_success_msg || log_failure_msg
	    return $RETVAL
	}
	daemon_reload () {
	    local base=
	    base=`echo $1 | sed -e 's,.*/,,'`; shift 1
	    echo -en "Reloading daemon $base: "
	    killproc $base -HUP
	    RETVAL=$?
	    [ $RETVAL -eq 0 ] && log_success_msg || log_failure_msg
	    return $RETVAL
	}
	action () {
	    echo -en "$1"
	    shift 1
	    ${1+"$@"} >/dev/null
	    RETVAL=$?
	    [ $RETVAL -eq 0 ] && log_success_msg || log_failure_msg
	    return $RETVAL
	}
	;;
    (debian)
	# a resonably modern debian system will have LSB support
	daemon_start () {
	    local force= nicelevel= base=
	    while [ "$1" != "${1##[+-]}" ] ; do
		case $1 in
		    (-f) force="" ; shift 1 ;;
		    (-n) nicelevel="-N $2"  ; shift 2 ;;
		esac
	    done
	    base=`echo $1 | sed -e 's,.*/,,'`
	    echo -en "Starting daemon $base: "
	    start-stop-daemon --start $force $nicelevel --quiet \
		--pidfile $pidfile --exec $execfile -- "$@"
	    RETVAL=$?
	    [ $RETVAL -eq 0 ] || echo "(failed)"; echo "."
	    return $RETVAL
	}
	daemon_stop () {
	    local base=
	    base=`echo $1 | sed -e 's,.*/,,'`; shift 1
	    echo -en "Stopping daemon $base: "
	    start-stop-daemon --stop --quiet --retry=1 --oknodo \
		--pidfile $pidfile --exec $execfile
	    RETVAL=$?
	      if [ $RETVAL -eq   0 ] ; then echo "."
	    elif [ $RETVAL -eq 255 ] ; then echo "(warning)."
	    else                            echo "failed!"
	    fi
	    return $RETVAL
	}
	daemon_reload () {
	    local base=
	    base=`echo $1 | sed -e 's,.*/,,'`; shift 1
	    echo -en "Reloading daemon $base: "
	    killproc $base -HUP
	    RETVAL=$?
	    [ $RETVAL -eq 0 ] || echo "(failed)"; echo "."
	    return $RETVAL
	}
	action () {
	    echo -en "$1"
	    shift 1
	    eval "\${1+\"\$@\"} $redir"
	    RETVAL=$?
	    [ $RETVAL -eq 0 ] || echo "(failed)"; echo "."
	    return $RETVAL
	}
	;;
    (standalone|*)
	if [ -x /sbin/pidof ] ; then
	    pidofproc () {
		/sbin/pidof $@
	    }
	elif [ -x /sbin/pidofproc ] ; then
	    pidofproc () {
		/sbin/pidofproc $@
	    }
	else
	    pidofproc () {
		[ -r $pidfile ] && cat $pidfile
	    }
	fi
	if [ -x /sbin/start-stop-daemon ] ; then
	    killproc () {
		local base execfile
		base=$1
		execfile=$2
		shift 2
		start-stop-daemon --stop --quiet --retry=1 --oknodo \
		    --pidfile $pidfile \
		    --exec $execfile
	    }
	elif [ -x /sbin/killproc ] ; then
	    killproc () {
		/sbin/killproc $@
	    }
	elif [ -x /usr/bin/killall ] ; then
	    killproc () {
		/usr/bin/killall $@
	    }
	else
	    killproc () {
		[ -r $pidfile ] && kill "$2" `cat $pidfile`
	    }
	fi
	daemon_start () {
	    local force= nicecmd= base=
	    while [ "$1" != "${1##[-+]}" ] ; do
		case $1 in
		    (-f) force="--force"       ; shift 1 ;;
		    (-n) nicecmd="nice -n $2"  ; shift 2 ;;
		esac
	    done
	    base=`echo $1 | sed -e 's,.*/,,'`
	    echo -en "Starting daemon $base: "
	    eval "( $nicecmd \"\$@\" >/dev/null 2>&1 </dev/null & )"
	    RETVAL=$?
	    [ $RETVAL -eq 0 ] && echo -en "\t...SUCCESS" || echo -en "\t....FAILED"
	    return $RETVAL
	}
	daemon_stop () {
	    local base=
	    base=`echo $1 | sed -e 's,.*/,,'`; shift 1
	    echo -en "Stopping daemon $base: "
	    if pidofproc $base >/dev/null 2>&1 ; then
		RETVAL=0
	    else
		killproc $base "$@"
		RETVAL=$?
	    fi
	    [ $RETVAL -eq 0 ] && log_success_msg || log_failure_msg
	    return $RETVAL
	}
	daemon_reload () {
	    local base=
	    base=`echo $1 | sed -e 's,.*/,,'`; shift 1
	    echo -en "Reloading daemon $base: "
	    killproc $base -HUP
	    RETVAL=$?
	    [ $RETVAL -eq 0 ] && echo -en "\t...SUCCESS" || echo -en "\t....FAILED"
	    return $RETVAL
	}
	action () {
	    echo -en "$1"
	    shift 1
	    ${1+"$@"} >/dev/null
	    RETVAL=$?
	    [ $RETVAL -eq 0 ] && echo -e "\t...SUCCESS" || echo -e "\t....FAILED"
	    return $?
	}
	;;
esac

name='strerr'
script='strerr.sh'
ucname="STRERR"
lockfile="/var/lock/subsys/$name"
config="/etc/sysconfig/$name /etc/default/$name"
processname="$name"
pidfile="/var/run/$processname.pid"
execfile="/usr/sbin/$processname"
desc="the STREAMS error logger"

[ -x $execfile -o "$1" = "stop" ] || exit 5

# Specify defaults

STRERROPTIONS=
STRERR_MAILUID=
STRERR_DIRECTORY="/var/log/streams"
STRERR_BASENAME="error"
STRERR_OUTFILE=
STRERR_ERRFILE=
STRERR_LOGDEVICE="/dev/streams/clone/log"
STRERR_OPTIONS=

# Source redhat and/or debian config file
for file in $config ; do
    [ -f $file ] && . $file
done

RETVAL=0

umask 077

case ":$VERBOSE" in
    :no|:NO|:false|:FALSE|:0|:)
	redir='>/dev/null 2>&1'
	;;
    *)
	redir=
	;;
esac

build_options () {
    # Build up the options string
    STRERR_OPTIONS="-p $pidfile"
    [ -n "$STRERROPTIONS" ] && \
	STRERR_OPTIONS="${STRERR_OPTIONS}${STRERR_OPTIONS:+ }${STRERROPTIONS}"
    [ -n "$STRERR_MAILUID" ] && \
	STRERR_OPTIONS="${STRERR_OPTIONS}${STRERR_OPTIONS:+ }-a ${STRERR_MAILUID}"
    [ -n "$STRERR_DIRECTORY" ] && \
	STRERR_OPTIONS="${STRERR_OPTIONS}${STRERR_OPTIONS:+ }-d ${STRERR_DIRECTORY}"
    [ -n "$STRERR_BASENAME" ] && \
	STRERR_OPTIONS="${STRERR_OPTIONS}${STRERR_OPTIONS:+ }-b ${STRERR_BASENAME}"
    [ -n "$STRERR_OUTFILE" ] && \
	STRERR_OPTIONS="${STRERR_OPTIONS}${STRERR_OPTIONS:+ }-o ${STRERR_OUTFILE}"
    [ -n "$STRERR_ERRFILE" ] && \
	STRERR_OPTIONS="${STRERR_OPTIONS}${STRERR_OPTIONS:+ }-e ${STRERR_ERRFILE}"
    [ -n "$STRERR_LOGDEVICE" ] && \
	STRERR_OPTIONS="${STRERR_OPTIONS}${STRERR_OPTIONS:+ }-l ${STRERR_LOGDEVICE}"
}

start () {
    [ -d "$STRERR_DIRECTORY" -o -z "$STRERR_DIRECTORY" ] || \
	action $"Creating $STRERR_DIRECTORY: " \
	    mkdir -p -- "$STRERR_DIRECTORY" \
	    || RETVAL=$?
    build_options
    daemon_start $execfile $STRERR_OPTIONS \
	|| RETVAL=$?
    [ $RETVAL -eq 0 ] && touch $lockfile
    return $RETVAL
}

stop () {
    if [ -r $pidfile ]; then
	daemon_stop $execfile || RETVAL=$?
    else
	RETVAL=0
    fi
    [ $RETVAL -eq 0 ] && rm -f -- $lockfile
    return $RETVAL
}

restart () {
    stop  || RETVAL=$?
    start || RETVAL=$?
    return $RETVAL
}

reload () {
    daemon_reload $execfile || RETVAL=$?
    return $RETVAL
}

show () {
    echo "$script: show: not yet implemented." >&2
    RETVAL=1
    return $RETVAL
}

usage () {
    echo "Usage: $script (start|stop|status|restart|try-restart|condrestart|force-reload|reload|probe|show)" >&2
    RETVAL=1
    return $RETVAL
}

case "$1" in
    (start|stop|reload|restart|show)
	$1 || RETVAL=$?
	;;
    (force-reload)
	reload || RETVAL=$?
	;;
    (status)
	$1 $name || RETVAL=$?
	;;
    (try-restart|condrestart)
	[ -f $lockfile ] && restart || RETVAL=$?
	;;
    (probe)
	if pidofproc $processname >/dev/null 2>&1 ; then
	    # running
	    if [ "`pidofproc $processname`" -eq "`cat $pidfile`" ] ; then
		# running with the right pid
		if [ ! -f $lockfile ] ; then
		    # running but subsystem unlocked, need to reload
		    echo 'reload'
		else
		    # subsystem locked
		    for file in $config ; do
			if [ -f $file -a $file -nt $lockfile ] ; then
			    # configuration file updated, need to reload
			    echo 'reload'
			    break
			fi
		    done
		fi
	    else
		# running, but with the wrong pid, need to restart
		echo 'restart'
	    fi
	else
	    # not running
	    if [ ! -f $lockfile ] ; then
		# subsystem unlocked, need to start
		echo 'start'
	    else
		# dead but subsystem locked, need to restart
		echo 'restart'
	    fi
	fi
	# do not need to do anything
	RETVAL=$?
	;;
    (*)
	usage || RETVAL=$?
	;;
esac

[ "${0##*/}" = "$script" ] && exit $RETVAL

# =============================================================================
# 
# @(#) src/util/init/strerr.sh
#
# -----------------------------------------------------------------------------
#
# Copyright (c) 2008-2015  Monavacon Limited <http://www.monavacon.com/>
# Copyright (c) 2001-2008  OpenSS7 Corporation <http://www.openss7.com/>
# Copyright (c) 1997-2001  Brian F. G. Bidulock <bidulock@openss7.org>
#
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation; version 3 of the License.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program.  If not, see <http://www.gnu.org/licenses/>, or write to
# the Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# -----------------------------------------------------------------------------
#
# U.S. GOVERNMENT RESTRICTED RIGHTS.  If you are licensing this Software on
# behalf of the U.S. Government ("Government"), the following provisions apply
# to you.  If the Software is supplied by the Department of Defense ("DoD"), it
# is classified as "Commercial Computer Software" under paragraph 252.227-7014
# of the DoD Supplement to the Federal Acquisition Regulations ("DFARS") (or any
# successor regulations) and the Government is acquiring only the license rights
# granted herein (the license rights customarily provided to non-Government
# users).  If the Software is supplied to any unit or agency of the Government
# other than DoD, it is classified as "Restricted Computer Software" and the
# Government's rights in the Software are defined in paragraph 52.227-19 of the
# Federal Acquisition Regulations ("FAR") (or any successor regulations) or, in
# the cases of NASA, in paragraph 18.52.227-86 of the NASA Supplement to the FAR
# (or any successor regulations).
#
# -----------------------------------------------------------------------------
#
# Commercial licensing and support of this software is available from OpenSS7
# Corporation at a fee.  See http://www.openss7.com/
#
# =============================================================================

# vim: ft=sh sw=4 tw=80
