#!/usr/bin/env bash
set -euo pipefail

setup_method="${INPUT_SETUP_METHOD:-release}"
cli_version="${INPUT_CLI_VERSION:-latest}"
cli_repository="${INPUT_CLI_REPOSITORY:-speq-tms/speq-cli}"
cli_binary_name="${INPUT_CLI_BINARY_NAME:-speq}"

ensure_tools() {
  local missing=0
  for tool in "$@"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      echo "missing required tool: $tool"
      missing=1
    fi
  done
  if [[ "$missing" -ne 0 ]]; then
    exit 1
  fi
}

platform="$(uname -s | tr '[:upper:]' '[:lower:]')"
arch="$(uname -m)"
case "$arch" in
  x86_64) arch="x86_64" ;;
  aarch64|arm64) arch="aarch64" ;;
esac

if [[ "$setup_method" == "release" ]]; then
  ensure_tools curl tar sed

  if [[ "$cli_version" == "latest" ]]; then
    version="$(curl -fsSL "https://api.github.com/repos/${cli_repository}/releases/latest" | sed -n 's/.*"tag_name": "\(.*\)".*/\1/p' | sed -n '1p')"
    if [[ -z "${version:-}" ]]; then
      echo "failed to resolve latest release tag from ${cli_repository}"
      exit 1
    fi
  else
    version="$cli_version"
  fi

  asset="${cli_binary_name}-${platform}-${arch}.tar.gz"
  download_url="https://github.com/${cli_repository}/releases/download/${version}/${asset}"
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT
  archive_path="${tmp_dir}/${asset}"

  echo "downloading ${download_url}"
  curl -fsSL "$download_url" -o "$archive_path"
  tar -xzf "$archive_path" -C "$tmp_dir"

  binary_path="$(find "$tmp_dir" -type f -name "$cli_binary_name" | sed -n '1p')"
  if [[ -z "${binary_path:-}" ]]; then
    echo "could not find ${cli_binary_name} in extracted archive"
    exit 1
  fi

  chmod +x "$binary_path"
  install_dir="$HOME/.local/bin"
  mkdir -p "$install_dir"
  cp "$binary_path" "${install_dir}/${cli_binary_name}"
  echo "${install_dir}" >> "$GITHUB_PATH"
  echo "installed ${cli_binary_name} from ${version} release"
elif [[ "$setup_method" == "cargo" ]]; then
  if ! command -v cargo >/dev/null 2>&1; then
    echo "cargo is required for setup-method=cargo"
    exit 1
  fi

  args=(install --git "https://github.com/${cli_repository}.git" --locked --force)
  if [[ "$cli_version" != "latest" ]]; then
    args+=(--tag "$cli_version")
  fi
  args+=("$cli_binary_name")

  echo "running cargo ${args[*]}"
  cargo "${args[@]}"
  echo "$HOME/.cargo/bin" >> "$GITHUB_PATH"
else
  echo "unknown setup-method: ${setup_method}"
  exit 1
fi

if ! command -v "$cli_binary_name" >/dev/null 2>&1; then
  echo "installation completed but ${cli_binary_name} is not available in PATH"
  exit 1
fi

"$cli_binary_name" --help >/dev/null
