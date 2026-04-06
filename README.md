# speq-github-runner

GitHub Action wrapper for running `speq-cli` in CI.

## Scope

`speq-github-runner` provides reproducible GitHub workflows around CLI commands:

- setup mode (install CLI);
- run mode (`validate` + `run` + `report`);
- custom mode (user-defined command sequence).

## Design principle

Runner must never reimplement test execution logic. It orchestrates `speq-cli` only.

## Repository structure

```text
action.yml
scripts/
workflows-examples/
docs/
```

## Quick start

```yaml
name: speq smoke

on:
  pull_request:

jobs:
  speq:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: stepankaziatko/speq-github-runner@v1
        with:
          mode: run
          speq-root: .speq
          env: ci
```

## Modes

- `setup`: installs `speq-cli` only.
- `run`: `validate` + `run` (summary) + `report` (allure) and uploads artifacts.
- `custom`: runs user-defined shell command (optional artifact upload).

## Inputs

- `mode`: `setup|run|custom` (default: `run`)
- `speq-root`: value for `--speq-root` (default: `.`)
- `env`, `test`, `suite`, `tags`: forwarded to `speq run`
- `skip-validate`: skip `speq validate` before run (default: `false`)
- `summary-output`: summary path (default: `.speq-artifacts/results/summary.json`)
- `logs-output`: logs path (default: `.speq-artifacts/logs/speq-runner.log`)
- `allure-dir`: path for allure artifacts upload (default: `reports/allure`)
- `upload-artifacts`: toggle artifact upload (default: `true`)
- `artifacts-prefix`: upload artifact name prefix (default: `speq`)
- `setup-method`: `release|cargo` (default: `release`)
- `cli-version`: release tag (or `latest`), or tag when `setup-method=cargo`
- `cli-repository`: GitHub repo with cli binaries/source (default: `stepankaziatko/speq-cli`)
- `cli-binary-name`: binary name in archive/path (default: `speq`)
- `custom-command`: command for `mode=custom`
- `custom-artifact-paths`: newline-separated paths to upload in `mode=custom`

## Artifacts

In `run` mode the action uploads:

- `${artifacts-prefix}-summary`
- `${artifacts-prefix}-allure`
- `${artifacts-prefix}-logs`

## Reference workflows

See ready-to-copy examples:

- `workflows-examples/pr-smoke.yml`
- `workflows-examples/nightly-regression.yml`

For integration details:

- `docs/usage.md`
- `docs/troubleshooting.md`

## Release channel

Use major tags in production workflows:

- `@v1` for stable updates without breaking changes.
- `@v1.x.x` for exact version pinning.
- commit SHA pinning for maximum supply-chain strictness.

## Status

Runner MVP is implemented and ready for demo projects.

## Adoption checklist

- Publish stable major tag (`v1`) and keep examples pinned to `@v1`.
- Validate `setup`, `run`, and `custom` flows in CI on pull requests.
- Verify artifact upload for every integration (`summary`, `allure`, `logs`).
- Pin `cli-version` in critical production pipelines when deterministic behavior is required.
