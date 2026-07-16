#!/usr/bin/env bash
set -euo pipefail

STATSFILE="${SYSTEM_STATSFILE:-/tmp/system_stats.log}"

usage() {
  cat <<EOF
System Monitoring Dashboard

Usage:
  $0 -c
  $0 -d
  $0 -q --start 'YYYY-MM-DD HH:MM:SS' --end 'YYYY-MM-DD HH:MM:SS'
  $0 --help

Environment:
  SYSTEM_STATSFILE  CSV log path (default: /tmp/system_stats.log)

CSV format:
  Timestamp,CPU%,Memory%
EOF
}

get_cpu_usage() {
  top -bn1 | awk -F'[, ]+' '
    /^%Cpu/ {
      for (i = 1; i <= NF; i++) {
        if ($i == "id") {
          idle = $(i - 1)
          printf "%.1f\n", 100 - idle
          exit
        }
      }
    }
  '
}

get_mem_usage() {
  free | awk '/^Mem:/ { printf "%.1f\n", ($3 / $2) * 100; exit }'
}

bar() {
  local pct="$1"
  local width="${2:-20}"
  local p_int filled empty

  p_int=$(printf '%.0f' "$pct" 2>/dev/null || echo 0)
  (( p_int < 0 )) && p_int=0
  (( p_int > 100 )) && p_int=100

  filled=$((p_int * width / 100))
  empty=$((width - filled))

  printf '[%s%s]' \
    "$(printf '%*s' "$filled" '' | tr ' ' '#')" \
    "$(printf '%*s' "$empty" '' | tr ' ' ' ')"
}

collect_once() {
  local timestamp cpu memory stats_dir

  stats_dir=$(dirname "$STATSFILE")
  if [[ ! -d "$stats_dir" ]]; then
    echo "ERROR: Log directory does not exist: $stats_dir" >&2
    return 1
  fi

  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  cpu=$(get_cpu_usage)
  memory=$(get_mem_usage)

  if [[ -z "$cpu" || -z "$memory" ]]; then
    echo "ERROR: Unable to collect system statistics." >&2
    return 1
  fi

  printf '%s,%.2f,%.2f\n' "$timestamp" "$cpu" "$memory" >> "$STATSFILE"
  echo "Appended to $STATSFILE: $timestamp,$cpu,$memory"
}

display_loop() {
  while true; do
    local cpu memory

    cpu=$(get_cpu_usage)
    memory=$(get_mem_usage)

    if [[ -z "$cpu" || -z "$memory" ]]; then
      echo "ERROR: Unable to collect system statistics." >&2
      return 1
    fi

    clear
    echo "System Monitor Dashboard"
    echo "========================"
    printf 'CPU Usage:    %5.1f%% %s\n' "$cpu" "$(bar "$cpu")"
    printf 'Memory Usage: %5.1f%% %s\n' "$memory" "$(bar "$memory")"
    echo "========================"
    echo "Press Ctrl+C to exit"
    sleep 5
  done
}

query_stats() {
  local start="$1"
  local end="$2"

  if [[ ! -f "$STATSFILE" ]]; then
    echo "ERROR: Log file not found: $STATSFILE" >&2
    return 1
  fi

  echo "Timestamp,CPU%,Memory%"
  awk -F',' -v start="$start" -v end="$end" '
    $1 >= start && $1 <= end {
      printf "%s,%.2f,%.2f\n", $1, $2, $3
    }
  ' "$STATSFILE"
}

MODE=""
START=""
END=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|-d|-q)
      if [[ -n "$MODE" ]]; then
        echo "ERROR: Choose only one operating mode (-c, -d, or -q)." >&2
        usage >&2
        exit 1
      fi
      MODE="$1"
      ;;
    --start)
      shift
      if [[ $# -eq 0 ]]; then
        echo "ERROR: --start requires a timestamp." >&2
        exit 1
      fi
      START="$1"
      ;;
    --end)
      shift
      if [[ $# -eq 0 ]]; then
        echo "ERROR: --end requires a timestamp." >&2
        exit 1
      fi
      END="$1"
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unknown parameter: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if [[ -z "$MODE" ]]; then
  usage >&2
  exit 1
fi

case "$MODE" in
  -c)
    collect_once
    ;;
  -d)
    display_loop
    ;;
  -q)
    if [[ -z "$START" || -z "$END" ]]; then
      echo "ERROR: Query mode requires both --start and --end timestamps." >&2
      usage >&2
      exit 1
    fi
    query_stats "$START" "$END"
    ;;
esac
