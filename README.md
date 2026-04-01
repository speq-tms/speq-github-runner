# speq-github-runner

GitHub Action wrapper for running `speq-cli` in CI.

## Scope

`speq-github-runner` provides reproducible GitHub workflows around CLI commands:

- setup mode (install CLI);
- run mode (`validate` + `run` + `report`);
- custom mode (user-defined command sequence).

## Design principle

Runner must never reimplement test execution logic. It orchestrates `speq-cli` only.

## Planned structure

```text
action.yml
scripts/
workflows-examples/
docs/
```

## Status

Bootstrap complete. Ready for OSS runner MVP implementation.
