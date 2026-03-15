#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-latest}"
BASE_URL="${2:-https://regrada.com/releases}"

os="$(uname -s | tr '[:upper:]' '[:lower:]')"
arch="$(uname -m)"

case "$os" in
  darwin) os="darwin" ;;
  linux) os="linux" ;;
  *)
    echo "Unsupported OS: $os" >&2
    exit 1
    ;;
esac

case "$arch" in
  x86_64|amd64) arch="amd64" ;;
  arm64|aarch64) arch="arm64" ;;
  *)
    echo "Unsupported architecture: $arch" >&2
    exit 1
    ;;
esac

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
    return
  fi

  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
    return
  fi

  echo "Missing sha256 tool" >&2
  exit 1
}

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

if [ "$VERSION" = "latest" ]; then
  VERSION="$(curl -fsSL "$BASE_URL/latest.txt")"
fi

asset="regrada_${VERSION}_${os}_${arch}.tar.gz"
asset_url="$BASE_URL/$VERSION/$asset"
checksums_url="$BASE_URL/$VERSION/checksums.txt"

echo "Downloading $asset_url"
curl -fsSL "$asset_url" -o "$tmpdir/$asset"
curl -fsSL "$checksums_url" -o "$tmpdir/checksums.txt"

expected_sum="$(awk -v asset="$asset" '$2 == asset { print $1 }' "$tmpdir/checksums.txt")"
if [ -z "$expected_sum" ]; then
  echo "Checksum for $asset not found in $checksums_url" >&2
  exit 1
fi

actual_sum="$(sha256_file "$tmpdir/$asset")"
if [ "$expected_sum" != "$actual_sum" ]; then
  echo "Checksum mismatch for $asset" >&2
  exit 1
fi

tar -C "$tmpdir" -xzf "$tmpdir/$asset"

bin_path=""
if [ -f "$tmpdir/regrada" ]; then
  bin_path="$tmpdir/regrada"
else
  candidate="$(find "$tmpdir" -maxdepth 2 -type f -name 'regrada*' | head -n 1 || true)"
  if [ -n "$candidate" ]; then
    bin_path="$candidate"
  fi
fi

if [ -z "$bin_path" ]; then
  echo "Regrada binary not found after extracting $asset" >&2
  exit 1
fi

chmod +x "$bin_path"

install_dir="${RUNNER_TEMP:-$HOME/.local}/regrada-action/bin"
mkdir -p "$install_dir"
cp "$bin_path" "$install_dir/regrada"

if [ -n "${GITHUB_PATH:-}" ]; then
  echo "$install_dir" >> "$GITHUB_PATH"
fi

echo "Installed regrada $VERSION to $install_dir/regrada"
