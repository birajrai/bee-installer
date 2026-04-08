#!/usr/bin/env bash
set -euo pipefail
root=$(dirname "$0")
for script in "$root"/*.sh "$root"/installers/*.sh; do
  [ -f "$script" ] || continue
  sha256sum "$script" > "$script.sha256"
done
echo "Generated checksums"
