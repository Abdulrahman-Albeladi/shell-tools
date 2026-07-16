#!/usr/bin/env bash
# Standalone todo list utility.
# Stores tasks in a plain-text file with one task per line:
#   [ ] pending task
#   [x] completed task

set -u

TODO_FILE="${TODO_FILE:-$HOME/.todo-list}"

ensure_store() {
  local dir
  dir="$(dirname "$TODO_FILE")"
  mkdir -p "$dir"
  touch "$TODO_FILE"
}

usage() {
  cat <<EOF
Usage:
  todo.sh                 List tasks
  todo.sh list            List tasks
  todo.sh add <text...>   Add a task
  todo.sh done <n...>     Mark one or more tasks complete
  todo.sh undo <n...>     Mark one or more tasks pending
  todo.sh rm <n>          Remove a task
  todo.sh clean           Remove completed tasks
  todo.sh help            Show this message

Configuration:
  TODO_FILE   Path to the task file (default: $HOME/.todo-list)
EOF
}

is_positive_integer() {
  case "$1" in
    ''|*[!0-9]*) return 1 ;;
    0) return 1 ;;
    *) return 0 ;;
  esac
}

task_count() {
  wc -l < "$TODO_FILE" | tr -d ' '
}

list_tasks() {
  ensure_store
  if [ ! -s "$TODO_FILE" ]; then
    echo "No tasks."
    return 0
  fi

  awk '
    /^\[x\] / { status = "done"; text = substr($0, 5) }
    /^\[ \] / { status = "todo"; text = substr($0, 5) }
    !/^\[[ x]\] / { status = "raw"; text = $0 }
    {
      icon = (status == "done") ? "✅" : ((status == "todo") ? "⬜" : "•")
      printf "%3d. %s %s\n", NR, icon, text
    }
  ' "$TODO_FILE"
}

add_task() {
  ensure_store
  if [ "$#" -eq 0 ]; then
    echo "error: missing task text" >&2
    usage >&2
    return 1
  fi

  printf '[ ] %s\n' "$*" >> "$TODO_FILE"
  echo "Added task."
}

rewrite_task_status() {
  local target="$1"
  local replacement="$2"
  local total tmp

  ensure_store
  if ! is_positive_integer "$target"; then
    echo "error: invalid task number: $target" >&2
    return 1
  fi

  total="$(task_count)"
  if [ "$target" -gt "$total" ]; then
    echo "error: task number out of range: $target" >&2
    return 1
  fi

  tmp="$(mktemp "${TODO_FILE}.XXXXXX")" || {
    echo "error: could not create temporary file" >&2
    return 1
  }

  awk -v n="$target" -v repl="$replacement" '
    NR == n {
      if ($0 ~ /^\[[ x]\] /) {
        print repl substr($0, 5)
      } else {
        print repl $0
      }
      next
    }
    { print }
  ' "$TODO_FILE" > "$tmp" && mv "$tmp" "$TODO_FILE"
}

mark_done() {
  local n
  if [ "$#" -eq 0 ]; then
    echo "error: provide at least one task number" >&2
    usage >&2
    return 1
  fi

  for n in "$@"; do
    rewrite_task_status "$n" '[x] ' || return 1
    echo "Completed task #$n"
  done
}

mark_todo() {
  local n
  if [ "$#" -eq 0 ]; then
    echo "error: provide at least one task number" >&2
    usage >&2
    return 1
  fi

  for n in "$@"; do
    rewrite_task_status "$n" '[ ] ' || return 1
    echo "Reopened task #$n"
  done
}

remove_task() {
  local target="$1"
  local total tmp

  ensure_store
  if [ "$#" -ne 1 ]; then
    echo "error: remove expects exactly one task number" >&2
    usage >&2
    return 1
  fi

  if ! is_positive_integer "$target"; then
    echo "error: invalid task number: $target" >&2
    return 1
  fi

  total="$(task_count)"
  if [ "$target" -gt "$total" ]; then
    echo "error: task number out of range: $target" >&2
    return 1
  fi

  tmp="$(mktemp "${TODO_FILE}.XXXXXX")" || {
    echo "error: could not create temporary file" >&2
    return 1
  }

  awk -v n="$target" 'NR != n { print }' "$TODO_FILE" > "$tmp" && mv "$tmp" "$TODO_FILE"
  echo "Removed task #$target"
}

clean_completed() {
  local before tmp

  ensure_store
  before="$(grep -c '^\[x\] ' "$TODO_FILE" 2>/dev/null || true)"
  tmp="$(mktemp "${TODO_FILE}.XXXXXX")" || {
    echo "error: could not create temporary file" >&2
    return 1
  }

  grep -v '^\[x\] ' "$TODO_FILE" > "$tmp" || true
  mv "$tmp" "$TODO_FILE"
  echo "Removed $before completed task(s)."
}

main() {
  local command="${1:-list}"

  case "$command" in
    list)
      list_tasks
      ;;
    add)
      shift
      add_task "$@"
      ;;
    done)
      shift
      mark_done "$@"
      ;;
    undo)
      shift
      mark_todo "$@"
      ;;
    rm|remove)
      shift
      remove_task "$@"
      ;;
    clean)
      clean_completed
      ;;
    help|-h|--help)
      usage
      ;;
    *)
      echo "error: unknown command: $command" >&2
      usage >&2
      return 1
      ;;
  esac
}

main "$@"
