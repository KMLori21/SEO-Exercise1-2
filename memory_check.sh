#!/bin/bash

while getopts ":c:w:e:" opt; do
  case $opt in
    c)
      CRITICAL_THRESHOLD=$OPTARG
      ;;
    w)
      WARNING_THRESHOLD=$OPTARG
      ;;
    e)
      EMAIL=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [ -z "$CRITICAL_THRESHOLD" ] || [ -z "$WARNING_THRESHOLD" ] || [ -z "$EMAIL" ]; then
  echo "Usage: $0 -c <critical_threshold> -w <warning_threshold> -e <email>"
  exit 1
fi

if [ "$CRITICAL_THRESHOLD" -le "$WARNING_THRESHOLD" ]; then
  echo "Critical threshold must be greater than the warning threshold."
  exit 1
fi

TOTAL_MEMORY=$(free | awk '/Mem:/ {print $2}')
MEMORY_USAGE=$(free | awk '/Mem:/ {printf "%.0f", $3 / $2 * 100}')

if [ "$MEMORY_USAGE" -ge "$CRITICAL_THRESHOLD" ]; then
  echo "CRITICAL: Memory usage is $MEMORY_USAGE%."
  SUBJECT="Memory check - critical"
  TOP_PROCESSES=$(ps aux --sort=-%mem | awk 'NR<=11 {print $0}')
  echo -e "Top 10 processes using a lot of memory:\n$TOP_PROCESSES"
  exit 2
elif [ "$MEMORY_USAGE" -ge "$WARNING_THRESHOLD" ]; then
  echo "WARNING: Memory usage is $MEMORY_USAGE%."
  exit 1
else
  echo "OK: Memory usage is $MEMORY_USAGE%."
  exit 0
fi