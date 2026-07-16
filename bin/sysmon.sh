#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${SYSMON_LOG_FILE:-/tmp/sysmon.csv}"
REFRESH_SECONDS="${SYSMON_REFRESH_SECONDS:-5}"

usage() {
  cat <<'EOF'
Usage:
  sysmon.sh collect
  sysmon.sh watch
  sysmon.sh query --start 'YYYY-MM-DD HH:MM:SS' --end 'YYYY-MM-DD HH:MM:SS'
  sysmon.sh help

Environment:
  SYSMON_LOG_FILE         CSV log path (default: /tmp/sysmon.csv)
  SYSMON_REFRESH_SECONDS  Refresh interval for watch mode (default: 5)

CSV format:
  timestamp,cpu_percent,memory_percent
EOF
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

require_commands() {
  local missing=0
  local cmd
  for cmd in "$@"; do
    if ! command_exists "$cmd"; then
      printf 'ERROR: required command not found: %s\n' "$cmd" >&2
      missing=1
    fi
  done
  if [[ "$missing" -ne 0 ]]; then
    exit 1
  fi
}

get_cpu_usage() {
  top -bn1 | awk -F'[, ]+' '
    /^%Cpu|^%Cpu\(s\):/ {
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

get_memory_usage() {
  free | awk '/^Mem:/ { printf "%.1f\n", ($3 / $2) * 100; exit }'
}

bar() {
  local pct="$1"
  local width="${2:-20}"
  local rounded filled empty

  rounded=$(awk -v v="$pct" 'BEGIN { printf "%d", v + 0.5 }' 2>/dev/null || printf '0')
  (( rounded < 0 )) && rounded=0
  (( rounded > 100 )) && rounded=100

  filled=$(( rounded * width / 100 ))
  empty=$(( width - filled ))

  printf '[%s%s]' \
    "$(printf '%*s' "$filled" '' | tr ' ' '#')" \
    "$(printf '%*s' "$empty" '' | tr ' ' ' ')"
}

ensure_log_parent() {
  local parent
  parent=$(dirname "$LOG_FILE")
  mkdir -p "$parent"
}

collect_once() {
  local ts cpu mem
  ts="$(date '+%Y-%m-%d %H:%M:%S')"
  cpu="$(get_cpu_usage)"
  mem="$(get_memory_usage)"

  ensure_log_parent
  printf '%s,%.2f,%.2f\n' "$ts" "$cpu" "$mem" >> "$LOG_FILE"
  printf 'recorded %s cpu=%s%% memory=%s%% -> %s\n' "$ts" "$cpu" "$mem" "$LOG_FILE"
}

watch_loop() {
  local cpu mem
  while true; do
    cpu="$(get_cpu_usage)"
    mem="$(get_memory_usage)"

    clear
    printf 'System Monitor\n'
    printf '==============\n'
    printf 'CPU:    %5.1f%% %s\n' "$cpu" "$(bar "$cpu")"
    printf 'Memory: %5.1f%% %s\n' "$mem" "$(bar "$mem")"
    printf '==============\n'
    printf 'log file: %s\n' "$LOG_FILE"
    printf 'refresh: %ss\n' "$REFRESH_SECONDS"
    printf 'Ctrl+C to exit\n'

    sleep "$REFRESH_SECONDS"
  done
}

query_range() {
  local start="$1"
  local end="$2"

  if [[ ! -f "$LOG_FILE" ]]; then
    printf 'ERROR: log file not found: %s\n' "$LOG_FILE" >&2
    exit 1
  fi

  printf 'timestamp,cpu_percent,memory_percent\n'
  awk -F',' -v start="$start" -v end="$end" '
    NF >= 3 {
      ts = $1
      if (ts >= start && ts <= end) {
        printf "%s,%.2f,%.2f\n", $1, $2, $3
      }
    }
  ' "$LOG_FILE"
}

main() {
  local mode=""
  local start=""
  local end=""

  if [[ $# -eq 0 ]]; then
    usage
    exit 1
  fi

  mode="$1"
  shift

  case "$mode" in
    collect)
      if [[ $# -ne 0 ]]; then
        printf 'ERROR: collect does not accept additional arguments\n' >&2
        usage
        exit 1
      fi
      require_commands top free awk date dirname mkdir
      collect_once
      ;;
    watch)
      if [[ $# -ne 0 ]]; then
        printf 'ERROR: watch does not accept additional arguments\n' >&2
        usage
        exit 1
      fi
      require_commands top free awk clear sleep
      watch_loop
      ;;
    query)
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --start)
            shift
            start="${1:-}"
            ;;
          --end)
            shift
            end="${1:-}"
            ;;
          *)
            printf 'ERROR: unknown argument for query: %s\n' "$1" >&2
            usage
            exit 1
            ;;
        esac
        shift || true
      done

      if [[ -z "$start" || -z "$end" ]]; then
        printf 'ERROR: query requires --start and --end\n' >&2
        usage
        exit 1
      fi

      require_commands awk
      query_range "$start" "$end"
      ;;
    help|-h|--help)
      usage
      ;;
    *)
      printf 'ERROR: unknown command: %s\n' "$mode" >&2
      usage
      exit 1
      ;;
  esac
}

main "$@"
