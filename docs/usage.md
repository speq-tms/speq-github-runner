# Usage guide

## Setup only

```yaml
- uses: stepankaziatko/speq-github-runner@main
  with:
    mode: setup
    setup-method: release
    cli-version: latest
```

## Validate + run + report

```yaml
- uses: stepankaziatko/speq-github-runner@main
  with:
    mode: run
    speq-root: .speq
    env: ci
    tags: smoke,api
```

## Custom orchestration

```yaml
- uses: stepankaziatko/speq-github-runner@main
  with:
    mode: custom
    custom-command: |
      speq validate --speq-root .speq --format json
      speq run --speq-root .speq --report summary --output .speq-artifacts/results/custom-summary.json
    custom-artifact-paths: |
      .speq-artifacts/results/custom-summary.json
      .speq-artifacts/logs
```
