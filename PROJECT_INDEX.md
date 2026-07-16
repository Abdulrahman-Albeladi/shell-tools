# Project Index

## Todo utility

| Field | Details |
| --- | --- |
| Files | `bin/todo.sh`; `projects/todo/todo.sh` |
| Category | Shell command-line utility |
| Intended function | Manage a todo list through a shell script. |
| Setup | Use a Unix-like environment with a compatible shell. Mark the selected script executable if needed. Review `docs/usage.md` and the script before supplying arguments or creating task data. |
| Local/private data | Task entries may be personal or sensitive. The recovered inventory does not establish the task-file path, format, permissions, or retention behavior. Do not commit real task data. |
| Validation status | No confirmed test or manual-validation result is available from the file inventory. A CI configuration exists, but its contents and status have not been verified. |
| Limitations | The relationship between the `bin/` and `projects/todo/` copies is not established. Shell compatibility, persistence behavior, error handling, and supported commands require source review. |
| Provenance | Recovered as publish-eligible 398W material. Assignment wording, grading scaffolding, and hidden-test assumptions are not treated as project documentation. |

### Suggested inspection and validation

```sh
sh -n bin/todo.sh
sh -n projects/todo/todo.sh
cmp -s bin/todo.sh projects/todo/todo.sh; printf 'comparison exit status: %s\n' "$?"
```

Use a temporary directory and synthetic task text for manual checks. Confirm that adding, listing, completing, deleting, and invalid-input behavior match the script's documented interface before recording any result.

## System monitor

| Field | Details |
| --- | --- |
| Files | `bin/sysmon.sh`; `projects/sysmon/sysmon.sh` |
| Category | Shell command-line utility |
| Intended function | Report system-monitoring information through a shell script. |
| Setup | Use a Unix-like environment with a compatible shell and the system commands required by the implementation. Review the script and `docs/usage.md` before execution. |
| Local/private data | Runtime output may reveal hostnames, usernames, process names or arguments, filesystem paths, mount information, network details, and resource usage. Do not publish unreviewed captured output. |
| Validation status | No confirmed test, platform-compatibility, or CI result is available from the recovered inventory. The presence of `.github/workflows/ci.yml` does not establish that the monitor has been executed successfully. |
| Limitations | Required operating-system commands, privilege requirements, output format, sampling behavior, and platform support are not established by the file list. The relationship between `bin/` and `projects/sysmon/` must be verified. |
| Provenance | Recovered as publish-eligible 398W material and retained as an independent utility without course prompt or grading content. |

### Suggested inspection and validation

```sh
sh -n bin/sysmon.sh
sh -n projects/sysmon/sysmon.sh
cmp -s bin/sysmon.sh projects/sysmon/sysmon.sh; printf 'comparison exit status: %s\n' "$?"
```

Run the selected implementation on a non-sensitive development machine. Review output before saving or sharing it, and verify behavior against the commands and fields actually implemented by the script.

## Repository-level documentation and automation

| File or directory | Role | Status requiring review |
| --- | --- | --- |
| `docs/usage.md` | Usage documentation | Confirm that examples match the current scripts. |
| `.github/workflows/ci.yml` | Continuous-integration configuration | Inspect triggers, shell versions, operating systems, and checks; no workflow outcome is claimed. |
| `CONTRIBUTING.md` | Contribution guidance | Review before accepting changes. |
| `SECURITY.md` | Security-reporting guidance | Review before publishing contact or disclosure details. |
| `LICENSE_REVIEW.md` | License-review notes | Review before incorporating third-party material. |
| `.gitignore` | Exclusion rules | Confirm that local todo files, logs, and monitoring captures are excluded where appropriate. |

## Canonical-source question

Each subproject appears in both `bin/` and `projects/`. The repository inventory alone does not establish whether one location is a wrapper, a copy, a generated artifact, or the canonical source. Compare each pair before editing. If they differ, document the intended source of truth and update the CI workflow or release process accordingly.
