#!/usr/bin/env bash
set -euo pipefail

custom_command="${INPUT_CUSTOM_COMMAND:-}"

if [[ -z "$custom_command" ]]; then
  echo "custom-command is required when mode=custom"
  exit 1
fi

echo "running custom command"
bash -c "$custom_command"
