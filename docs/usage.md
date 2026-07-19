# Usage

This repository provides two Bash utilities under `bin/`.

- `bin/todo.sh` — plain-text task list
- `bin/sysmon.sh` — basic system monitoring

Run from the repository root (ensure executables):

```bash
chmod +x bin/*.sh
./bin/todo.sh
./bin/sysmon.sh
```

## todo.sh

Usage (from the script):

```
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
```

Examples:

```bash
./bin/todo.sh add "Buy milk"
./bin/todo.sh            # list tasks
./bin/todo.sh done 1     # complete task #1
./bin/todo.sh clean      # remove completed tasks
```

## sysmon.sh

Usage (from the script):

```
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
```

Examples:

```bash
# Append one sample to the CSV log
./bin/sysmon.sh collect

# Watch a live dashboard (no CSV write)
./bin/sysmon.sh watch

# Query a time range from the CSV log
./bin/sysmon.sh query --start '2025-01-01 00:00:00' --end '2025-01-01 23:59:59'
```

Notes:
- `collect` appends to `SYSMON_LOG_FILE` (default `/tmp/sysmon.csv`).
- `watch` renders a live view in the terminal.
- `query` filters rows between the provided timestamps.

## Dependencies and platform

- sysmon requires: `top`, `free`, `awk`, `date`, `dirname`, `mkdir`, `clear`, `sleep`
- todo requires: `awk`, `grep`, `wc`, `tr`, `mktemp`, `mkdir`, `dirname`
- Target platform: Linux. macOS/BSD `top`/`free` output differs and may not parse identically.

## Privacy

System-monitor logs can include local machine details; avoid committing captured output.
