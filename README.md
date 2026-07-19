# Shell Tools

<!-- employer-visual:end -->


Small Bash command-line utilities for task tracking and system monitoring.

**Technologies:** Bash · Unix Command Line

## Utilities

- Todo: `bin/todo.sh` — add, list, done, undo, rm, clean. Config: `TODO_FILE` (default: `$HOME/.todo-list`).
- System monitor: `bin/sysmon.sh` — `collect` a CSV sample, `watch` a live dashboard, or `query` a CSV time range. Config: `SYSMON_LOG_FILE` (default: `/tmp/sysmon.csv`), `SYSMON_REFRESH_SECONDS`.

## Quickstart

1. Use a Linux environment with Bash.
2. Run `chmod +x bin/*.sh`.
3. Run from the repository root or add `bin/` to your `PATH`:

```bash
./bin/todo.sh
./bin/sysmon.sh
```

## Usage

See [`docs/usage.md`](docs/usage.md) for command examples and environment variables.

## Dependencies

- `bin/sysmon.sh` requires: `top`, `free`, `awk`, `date`, `dirname`, `mkdir`, `clear`, `sleep`
- `bin/todo.sh` requires: `awk`, `grep`, `wc`, `tr`, `mktemp`, `mkdir`, `dirname`

## Platform

- Designed for Linux. macOS/BSD variants of `top`/`free` may not parse identically.

## Portfolio note

System-monitor output can contain local machine information; avoid committing captured output.

## License and attribution

Use and redistribution are governed by the repository's [`LICENSE`](LICENSE).
