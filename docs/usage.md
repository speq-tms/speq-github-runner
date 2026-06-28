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
- name: Materialize SPEQ CI environment
  env:
    SPEQ_CI_BASE_URL: ${{ secrets.SPEQ_CI_BASE_URL }}
    SPEQ_CI_SOURCE_HEADER: ${{ secrets.SPEQ_CI_SOURCE_HEADER }}
  run: |
    python3 - <<'PY'
    import json
    import os
    from pathlib import Path

    base_url = os.environ.get("SPEQ_CI_BASE_URL") or "https://jsonplaceholder.typicode.com"
    source = os.environ.get("SPEQ_CI_SOURCE_HEADER") or "speq-github-actions"

    path = Path(".speq/environments/ci.yaml")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        "\n".join(
            [
                "name: ci",
                f"baseUrl: {json.dumps(base_url)}",
                "headers:",
                f"  x-source: {json.dumps(source)}",
                "",
            ]
        ),
        encoding="utf-8",
    )
    PY

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

## CI environments from GitHub Secrets

For MVP v1.0.0, keep real secrets out of the repository. Generate the environment YAML inside the GitHub Actions job, then run SPEQ with `env: ci`. Do not print the generated file or upload it as an artifact.

Recommended secret names:

- `SPEQ_CI_BASE_URL`: API base URL for CI.
- `SPEQ_CI_SOURCE_HEADER`: non-sensitive source marker for CI requests.
- `SPEQ_CI_AUTH_TOKEN`: optional bearer token for private APIs.

```yaml
- name: Materialize SPEQ CI environment
  env:
    SPEQ_CI_BASE_URL: ${{ secrets.SPEQ_CI_BASE_URL }}
    SPEQ_CI_SOURCE_HEADER: ${{ secrets.SPEQ_CI_SOURCE_HEADER }}
    SPEQ_CI_AUTH_TOKEN: ${{ secrets.SPEQ_CI_AUTH_TOKEN }}
  run: |
    python3 - <<'PY'
    import json
    import os
    from pathlib import Path

    base_url = os.environ["SPEQ_CI_BASE_URL"]
    source = os.environ.get("SPEQ_CI_SOURCE_HEADER") or "speq-github-actions"
    token = os.environ.get("SPEQ_CI_AUTH_TOKEN")

    lines = [
        "name: ci",
        f"baseUrl: {json.dumps(base_url)}",
        "headers:",
        f"  x-source: {json.dumps(source)}",
    ]
    if token:
        lines.append(f"  authorization: {json.dumps('Bearer ' + token)}")

    path = Path(".speq/environments/ci.yaml")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    PY

- uses: speq-tms/speq-github-runner@v1
  with:
    mode: run
    speq-root: .speq
    env: ci
    artifacts-prefix: speq-ci
```

If your API requires sensitive headers, verify your SPEQ report configuration before uploading artifacts. The materialization step above does not print secrets, but downstream request/response reports may include headers depending on CLI behavior and project configuration.

## Release setup support

`setup-method: release` expects published tarball assets named `${cli-binary-name}-${platform}-${arch}.tar.gz`, for example `speq-linux-x86_64.tar.gz` or `speq-darwin-aarch64.tar.gz`. Pin `cli-version` once the CLI release artifacts are published.

Windows is manual zip install for MVP v1.0.0. Download the Windows zip from the GitHub Release, add `speq.exe` to `PATH`, then run `speq` directly or use `mode: custom` for orchestration. The action does not install Windows release zips in MVP.
