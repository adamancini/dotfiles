#!/usr/bin/env bash

function usage() {
    cat <<EOF
USAGE i3-xephyr start|stop|restart|run
start Start nested i3 in xephyr
stop Stop xephyr
restart reload i3 in xephyr
run run command in nested i3
EOF
  exit 0
}

i3_pid() {
  pgrep -n "i3";
}

xephyr_pid() {
  pgrep -f xephyr_$D;
}

errorout() { echo "error: $*" >&2; exit 1; }

D=1
SIZE="1366x840"
I3=`which i3`
XEPHYR=`which Xephyr`
I3_OPTIONS=""
XEPHYR_OPTIONS=""

test -x $I3 || {echo "i3 executable not found."}
test -x $XEPHYR || {echo "Xephyr executable not found."}

start() {
  # check for free DISPLAYS
  for ((i=0;;i++)); do
    if [[ ! -f "/tmp/.X${i}-lock" ]]; then
      D=$i;
      break;
      fi;
  done

  "$XEPHYR" :$D -name xephyr_$D -ac -br -noreset -screen "$SIZE" $XEPHYR_OPTIONS >/dev/null 2>&1 &
  sleep 1
  DISPLAY=:$D.0 "$I3" &
  sleep 1

  echo "Display: $D, i3 PID: $(i3_pid), Xephyr PID: $(xephyr_pid)"
}

stop() {
  if [[ "$1" == all ]]; then
    echo "Stopping all instances of Xephyr"
    kill $(pgrep Xephyr) >/dev/null 2>&1
  elif [[ $(xephyr_pid) ]]; then
    echo "Stopping Xephyr for display $D"
    kill $(xephyr_pid)
  else
    echo "Xephyr is not running or you did not specify the correct display with -D"
    exit 0
  fi
}

restart() {
  # TODO: (maybe use /tmp/.X{i}-lock files) Find a way to uniquely identify an awesome instance
  # (without storing the PID in a file). Until then all instances spawned by this script are restarted...
  echo -n "Restarting i3... "
  for i in $(pgrep -f "i3"); do
    kill -s SIGHUP $i;
  done
}

parse_options() {
  while [[ -n "$1" ]]; do
    case "$1" in
      start)          input=start;;
      stop)           input=stop;;
      restart)        input=restart;;
      -B|--binary)    shift; I3="$1";;
      -C|--config)    shift; RC_FILE="$1";;
      -D|--display)   shift; D="$1"
              [[ ! "$D" =~ ^[0-9] ]] && errorout "$D is not a valid display number";;
      -S|--size)      shift; SIZE="$1";;
      -a|--aopt)      shift; I3_OPTIONS+="$1";;
      -x|--xopts)     shift; XEPHYR_OPTIONS="$@";;
      -h|--help)      usage;;
      *)              args+=("$1");;
    esac
    shift
  done
}

main() {
  case "$input" in
    start)    start "${args[@]}";;
    stop)     stop "${args[@]}";;
    *)        echo "Option missing or not recognized";;
  esac
}
#}}}

parse_options "$@"
main

