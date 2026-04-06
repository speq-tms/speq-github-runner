# Usage guide

## Setup only

```yaml
- uses: speq-tms/speq-github-runner@v1
  with:
    mode: setup
    setup-method: release
    cli-version: latest
```

## Validate + run + report

```yaml
- uses: speq-tms/speq-github-runner@v1
  with:
    mode: run
    speq-root: .speq
    env: ci
    tags: smoke,api
```

## Custom orchestration

```yaml
- uses: speq-tms/speq-github-runner@v1
  with:
    mode: custom
    custom-command: |
      speq validate --speq-root .speq --format json
      speq run --speq-root .speq --report summary --output .speq-artifacts/results/custom-summary.json
    custom-artifact-paths: |
      .speq-artifacts/results/custom-summary.json
      .speq-artifacts/logs
```
