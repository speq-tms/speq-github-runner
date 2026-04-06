# Troubleshooting

## `speq` command not found

Symptoms:

- setup step seems green but `run` fails with `speq: command not found`.

Checks:

1. Ensure action runs in `mode: run` (this mode invokes setup automatically).
2. If using `mode: setup` in a separate job, repeat setup in every job where `speq` is needed.
3. Ensure `cli-repository` and `cli-binary-name` match your release assets.

## Release asset download fails in setup mode

Symptoms:

- setup fails while downloading archive from GitHub release.

Checks:

1. Confirm `cli-version` exists in `cli-repository` releases.
2. Ensure binary asset naming matches:
   - `${cli-binary-name}-linux-x86_64.tar.gz`
   - `${cli-binary-name}-linux-aarch64.tar.gz`
   - `${cli-binary-name}-darwin-x86_64.tar.gz`
   - `${cli-binary-name}-darwin-aarch64.tar.gz`
3. For private CLI repos, use `setup-method: cargo` and configure access credentials in workflow.

## `run` step fails with mutually exclusive filters

Symptoms:

- error: `inputs test and suite are mutually exclusive`.

Fix:

- pass only one of `test` or `suite`.

## No artifacts uploaded

Checks:

1. Ensure `upload-artifacts: true`.
2. Verify output paths:
   - `summary-output` points to generated summary file.
   - `allure-dir` points to generated allure directory.
   - `logs-output` points to writable path.
3. Check action logs for upload step warnings (`if-no-files-found: warn`).

## Validate succeeds locally but fails in CI

Checks:

1. Ensure the same `speq-root` layout in CI and local environment.
2. Ensure required environment files are present (`environments/*.yaml`).
3. Pin `cli-version` to avoid unexpected behavior changes between runs.
