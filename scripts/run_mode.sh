#!/usr/bin/env bash
set -euo pipefail

speq_root="${INPUT_SPEQ_ROOT:-.}"
env_name="${INPUT_ENV:-}"
test_file="${INPUT_TEST:-}"
suite_dir="${INPUT_SUITE:-}"
tags="${INPUT_TAGS:-}"
skip_validate="${INPUT_SKIP_VALIDATE:-false}"
summary_output="${INPUT_SUMMARY_OUTPUT:-.speq-artifacts/results/summary.json}"
logs_output="${INPUT_LOGS_OUTPUT:-.speq-artifacts/logs/speq-runner.log}"

mkdir -p "$(dirname "$summary_output")" "$(dirname "$logs_output")"

if [[ "$skip_validate" != "true" ]]; then
  echo "running: speq validate --speq-root $speq_root"
  set -o pipefail
  speq validate --speq-root "$speq_root" 2>&1 | tee "$logs_output"
  set +o pipefail
fi

run_cmd=(speq run --speq-root "$speq_root" --report summary --output "$summary_output")
if [[ -n "$env_name" ]]; then
  run_cmd+=(--env "$env_name")
fi
if [[ -n "$test_file" && -n "$suite_dir" ]]; then
  echo "inputs test and suite are mutually exclusive"
  exit 1
fi
if [[ -n "$test_file" ]]; then
  run_cmd+=(--test "$test_file")
fi
if [[ -n "$suite_dir" ]]; then
  run_cmd+=(--suite "$suite_dir")
fi
if [[ -n "$tags" ]]; then
  run_cmd+=(--tags "$tags")
fi

echo "running: ${run_cmd[*]}"
set -o pipefail
"${run_cmd[@]}" 2>&1 | tee -a "$logs_output"
set +o pipefail

echo "running: speq report --speq-root $speq_root --format allure --summary $summary_output"
set -o pipefail
speq report --speq-root "$speq_root" --format allure --summary "$summary_output" 2>&1 | tee -a "$logs_output"
set +o pipefail

{
  echo "summary_path=$summary_output"
  echo "logs_path=$logs_output"
} >> "$GITHUB_OUTPUT"
