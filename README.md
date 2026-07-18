# Shell Tools

Recovered shell utilities from 398W coursework and related project files. The repository is organized as standalone command-line scripts with copies or entry points under `bin/` and project-local source locations under `projects/`.

## Contents

| Project | Primary files | Purpose |
| --- | --- | --- |
| Todo utility | `bin/todo.sh`, `projects/todo/todo.sh` | Shell-based todo-list utility. |
| System monitor | `bin/sysmon.sh`, `projects/sysmon/sysmon.sh` | Shell-based system-monitoring utility. |

Supporting repository files include:

- `docs/usage.md` for available usage documentation.
- `.github/workflows/ci.yml` for repository automation configuration.
- `CONTRIBUTING.md`, `SECURITY.md`, and `LICENSE_REVIEW.md` for repository policy and review notes.
- `.gitignore` for local and generated-file exclusions.

## Setup

The scripts are shell programs and should be run in a compatible Unix-like shell environment. Review the script headers and `docs/usage.md` before use because the recovered file list does not establish required shell versions, external commands, storage paths, or command-line interfaces.

Typical local setup:

```sh
git clone <repository-url> shell-utilities
cd shell-utilities
chmod +x bin/todo.sh bin/sysmon.sh
```

Run a utility directly only after reviewing its usage and local-data behavior:

```sh
./bin/todo.sh
./bin/sysmon.sh
```

If the project-local copies are intended as the canonical implementations, they can be inspected or run from their project directories:

```sh
chmod +x projects/todo/todo.sh projects/sysmon/sysmon.sh
./projects/todo/todo.sh
./projects/sysmon/sysmon.sh
```

## Private data and local state

This repository should not contain personal todo items, machine inventories, hostnames, usernames, process output, credentials, API tokens, or private filesystem paths.

The todo utility may create or read local task data; its actual storage location and format must be confirmed from the script and usage documentation before use. Keep any local task file outside version control unless the implementation explicitly documents a safe project-local example file.

The system-monitoring utility may expose information about the current machine when run. Treat captured output as potentially sensitive, especially when it includes usernames, hostnames, process arguments, mounted paths, network configuration, or resource usage.

## Limitations

- The available inventory identifies scripts but does not establish their exact interfaces or dependencies.
- `bin/` and `projects/` contain similarly named scripts. Their relationship, synchronization status, and canonical source location should be verified before making changes.
- Portability across operating systems and shell implementations has not been established.
- The repository does not currently document confirmed automated-test results.
- Monitoring output and task storage behavior require source review before publication or deployment in a shared environment.

## Provenance

The included utilities were recovered as publish-eligible material from 398W files. They have been presented as independent shell projects rather than as assignment prompts or grading artifacts. Original demonstrated behavior and attribution should be retained when editing the recovered scripts. The recovered inventory does not provide enough information to attribute individual implementation details beyond that course provenance.

## Repository layout

```text
.
├── bin/
│   ├── sysmon.sh
│   └── todo.sh
├── docs/
│   └── usage.md
├── projects/
│   ├── sysmon/
│   │   └── sysmon.sh
│   └── todo/
│       └── todo.sh
├── .github/workflows/
│   └── ci.yml
├── CONTRIBUTING.md
├── LICENSE_REVIEW.md
├── README.md
└── SECURITY.md
```

## Contributing and security

See `CONTRIBUTING.md` for contribution guidance and `SECURITY.md` for vulnerability-reporting information. Review `LICENSE_REVIEW.md` before adding third-party code, copied command snippets, or redistributed datasets.
