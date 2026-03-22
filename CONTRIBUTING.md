# Contributing

## Development

- Keep the project CLI-based and Bash-first
- Prefer readable scripts over clever packaging
- Do not hide installation logic behind opaque tooling
- Preserve the standalone `speak` and `speak-selection` workflow

## Local Checks

```bash
make lint
bash -n install.sh uninstall.sh bin/speak bin/speak-selection scripts/*.sh
```

## Pull Requests

- Describe the user-facing behavior change
- Mention any install, config, or keyboard shortcut impact
- Update `README.md` and docs when behavior changes
- Keep shell scripts `shellcheck`-clean
