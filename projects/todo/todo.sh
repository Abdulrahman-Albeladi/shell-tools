#!/usr/bin/env bash
# todo - Simple todo list manager

set -euo pipefail

TODO_FILE="${TODO_FILE:-$HOME/.todos}"
touch "$TODO_FILE"

usage() {
  echo "Usage: ${0##*/} [add <task description> | done <num> [num ...] | rm <num> | clean]"
}

add_todo() {
  [ "$#" -gt 0 ] || { echo "Usage: ${0##*/} add <task description>" >&2; exit 1; }

  printf '[ ] %s\n' "$*" >> "$TODO_FILE"
  echo "Added: $*"
}

list_tasks() {
  sed -e 's/^\[x\] /✅ /' -e 's/^\[ \] /⬜ /' "$TODO_FILE" | cat -n
}

validate_line_number() {
  case "$1" in
    ''|*[!0-9]*|0) return 1 ;;
    *) return 0 ;;
  esac
}

done_tasks() {
  [ "$#" -gt 0 ] || { echo "Usage: ${0##*/} done <num> [num ...]" >&2; exit 1; }

  for number in "$@"; do
    validate_line_number "$number" || {
      echo "Invalid task number: $number" >&2
      exit 1
    }

    sed -i "${number}s/^\[ \] /[x] /" "$TODO_FILE"
    echo "Completed task #$number"
  done
}

rm_task() {
  [ "$#" -eq 1 ] || { echo "Usage: ${0##*/} rm <num>" >&2; exit 1; }
  validate_line_number "$1" || { echo "Invalid task number: $1" >&2; exit 1; }

  sed -i "${1}d" "$TODO_FILE"
  echo "Removed task #$1"
}

clean() {
  local completed temp_file

  completed=$(grep -c '^\[x\] ' "$TODO_FILE" || true)
  temp_file=$(mktemp "${TODO_FILE}.tmp.XXXXXX")
  trap 'rm -f "$temp_file"' RETURN

  grep -v '^\[x\] ' "$TODO_FILE" > "$temp_file" || true
  mv "$temp_file" "$TODO_FILE"
  trap - RETURN

  echo "Cleaned up $completed completed tasks"
}

case "${1:-}" in
  add)
    shift
    add_todo "$@"
    ;;
  done)
    shift
    done_tasks "$@"
    ;;
  rm)
    shift
    rm_task "$@"
    ;;
  clean)
    [ "$#" -eq 1 ] || { usage >&2; exit 1; }
    clean
    ;;
  '')
    list_tasks
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
