#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

assert_file_contains() {
  local file="$1"
  local expected="$2"
  if [[ ! -f "$file" ]]; then
    echo "file not found: $file"
    exit 1
  fi
  local content
  content="$(sed -n '1,200p' "$file")"
  if [[ "$content" != *"$expected"* ]]; then
    echo "expected '$expected' in $file"
    echo "actual content:"
    printf "%s\n" "$content"
    exit 1
  fi
}

test_run_mode() {
  local work_dir="${TMP_DIR}/run-mode"
  local bin_dir="${work_dir}/bin"
  local calls_file="${work_dir}/speq_calls.log"
  local output_file="${work_dir}/github_output.txt"
  mkdir -p "${bin_dir}" "${work_dir}/project/reports/allure"

  cat > "${bin_dir}/speq" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cmd="${1:-}"
echo "$*" >> "${SPEQ_CALLS_FILE}"
if [[ "$cmd" == "run" ]]; then
  output=""
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --output)
        output="$2"
        shift 2
        ;;
      *)
        shift
        ;;
    esac
  done
  if [[ -n "$output" ]]; then
    mkdir -p "$(dirname "$output")"
    echo '{"ok":true}' > "$output"
  fi
fi
if [[ "$cmd" == "report" ]]; then
  mkdir -p reports/allure
  echo '{}' > reports/allure/dummy-result.json
fi
EOF
  chmod +x "${bin_dir}/speq"

  (
    cd "${work_dir}/project"
    export PATH="${bin_dir}:${PATH}"
    export SPEQ_CALLS_FILE="${calls_file}"
    export GITHUB_OUTPUT="${output_file}"
    export INPUT_SPEQ_ROOT=".speq"
    export INPUT_ENV="ci"
    export INPUT_TEST=""
    export INPUT_SUITE="suites"
    export INPUT_TAGS="smoke,api"
    export INPUT_SKIP_VALIDATE="false"
    export INPUT_SUMMARY_OUTPUT=".speq-artifacts/results/summary.json"
    export INPUT_LOGS_OUTPUT=".speq-artifacts/logs/runner.log"
    bash "${ROOT_DIR}/scripts/run_mode.sh"
  )

  assert_file_contains "${calls_file}" "validate --speq-root"
  assert_file_contains "${calls_file}" "run --speq-root .speq --report summary --output .speq-artifacts/results/summary.json --env ci --suite suites --tags smoke,api"
  assert_file_contains "${calls_file}" "report --speq-root .speq --format allure --summary .speq-artifacts/results/summary.json"
  assert_file_contains "${work_dir}/project/.speq-artifacts/results/summary.json" "\"ok\":true"
  assert_file_contains "${output_file}" "summary_path=.speq-artifacts/results/summary.json"
  assert_file_contains "${output_file}" "logs_path=.speq-artifacts/logs/runner.log"
}

test_custom_mode() {
  local work_dir="${TMP_DIR}/custom-mode"
  mkdir -p "${work_dir}"
  (
    cd "${work_dir}"
    export INPUT_CUSTOM_COMMAND="echo custom-ok > custom_result.txt"
    bash "${ROOT_DIR}/scripts/custom_mode.sh"
  )
  assert_file_contains "${work_dir}/custom_result.txt" "custom-ok"
}

test_setup_mode_invalid_method() {
  local output_file="${TMP_DIR}/setup_invalid.log"
  set +e
  (
    export INPUT_SETUP_METHOD="bad-method"
    export INPUT_CLI_VERSION="latest"
    export INPUT_CLI_REPOSITORY="speq-tms/speq-cli"
    export INPUT_CLI_BINARY_NAME="speq"
    bash "${ROOT_DIR}/scripts/setup.sh"
  ) >"${output_file}" 2>&1
  local code=$?
  set -e
  if [[ "$code" -eq 0 ]]; then
    echo "setup.sh must fail for invalid setup method"
    exit 1
  fi
  assert_file_contains "${output_file}" "unknown setup-method"
}

test_run_mode
test_custom_mode
test_setup_mode_invalid_method
echo "smoke tests passed"
