#!/usr/bin/env bash
set -euo pipefail

# Minimal installer wrapper intended for: curl | bash
# This script fetches scripts/npm.sh from the same repository location and executes it.

REPO_BASE="https://installer.raibiraj.com.np"
SCRIPT_PATH="/scripts/npm.sh"

echo "Fetching installer from ${REPO_BASE}${SCRIPT_PATH}"

tmpfile=$(mktemp -t bee-npm.XXXXXX)
cleanup(){ rm -f "$tmpfile"; }
trap cleanup EXIT

if ! curl -fsSL "${REPO_BASE}${SCRIPT_PATH}" -o "$tmpfile"; then
  echo "Failed to download installer from ${REPO_BASE}${SCRIPT_PATH}" >&2
  exit 1
fi

chmod +x "$tmpfile"
echo "Running installer..."
exec sudo bash "$tmpfile" "$@"
