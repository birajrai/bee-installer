#!/usr/bin/env bash
set -euo pipefail

# Template installer
# Variables to update for your repo
OWNER="birajrai"
REPO="bee-installer"
BRANCH="main"

SCRIPT_NAME="${1:-}" # expected to be provided by wrapper

usage(){
  cat <<EOF
Usage: $0 [--dry-run] [--skip-start] [--yes]

This wrapper downloads and verifies an installer script from raw.githubusercontent.com and executes it.
EOF
}

DRY_RUN=0
SKIP_START=0
ASSUME_YES=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift;;
    --skip-start) SKIP_START=1; shift;;
    --yes) ASSUME_YES=1; shift;;
    -h|--help) usage; exit 0;;
    *) shift;;
  esac
done

if [[ -z "$SCRIPT_NAME" ]]; then
  echo "Missing script name in wrapper."
  exit 2
fi

BASE_URL="https://raw.githubusercontent.com/${OWNER}/${REPO}/${BRANCH}/scripts"
SCRIPT_URL="${BASE_URL}/${SCRIPT_NAME}"
SUM_URL="${SCRIPT_URL}.sha256"

tmpdir=$(mktemp -dt installer.XXXXXX)
trap 'rm -rf "$tmpdir"' EXIT

script_file="$tmpdir/$(basename "$SCRIPT_NAME")"
sum_file="$script_file.sha256"

echo "Downloading $SCRIPT_URL"
curl -fsSL "$SCRIPT_URL" -o "$script_file"
if curl -fsSL "$SUM_URL" -o "$sum_file"; then
  echo "Verifying checksum"
  pushd "$tmpdir" >/dev/null
  sha256sum -c "$(basename "$sum_file")" || { echo "Checksum mismatch" >&2; exit 3; }
  popd >/dev/null
else
  echo "No checksum available; continuing without verification" >&2
fi

if [[ $DRY_RUN -eq 1 ]]; then
  echo "--dry-run set; not executing"
  exit 0
fi

chmod +x "$script_file"
if [[ $ASSUME_YES -eq 1 ]]; then
  exec sudo bash "$script_file" --skip-start
else
  read -p "Run installer $SCRIPT_NAME as root? [y/N] " ans
  case "$ans" in
    y|Y) exec sudo bash "$script_file" ;;
    *) echo "Aborted"; exit 1;;
  esac
fi
