#!/usr/bin/env bash
set -euo pipefail

root=$(dirname "$0")
missing=0
for script in "$root"/*.sh "$root"/installers/*.sh; do
  [ -f "$script" ] || continue
  sumfile="$script.sha256"
  if [ ! -f "$sumfile" ]; then
    echo "Missing checksum for $script"
    missing=1
  fi
done
if [ "$missing" -ne 0 ]; then
  echo "Validation failed: missing checksums" >&2
  exit 2
fi
echo "All scripts have checksum files present."
