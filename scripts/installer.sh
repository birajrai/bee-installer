#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
MANIFEST="$ROOT_DIR/manifest.yml"

usage(){
  cat <<EOF
Usage: $0 [--list] [--local /path/to/script] [--dry-run] [--skip-start] [--yes] [service]

Examples:
  curl -fsSL https://raw.githubusercontent.com/birajrai/bee-installer/main/scripts/installer.sh | sudo bash -s -- nodejs
  curl -fsSL .../installer.sh | bash -s -- --list
EOF
}

LIST=0
LOCAL=""
DRY_RUN=0
SKIP_START=0
ASSUME_YES=0
SERVICE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --list|-l) LIST=1; shift;;
    --local) LOCAL="$2"; shift 2;;
    --dry-run) DRY_RUN=1; shift;;
    --skip-start) SKIP_START=1; shift;;
    --yes) ASSUME_YES=1; shift;;
    -h|--help) usage; exit 0;;
    *) SERVICE="$1"; shift;;
  esac
done

if [[ ! -f "$MANIFEST" ]]; then
  echo "Manifest not found: $MANIFEST" >&2
  exit 2
fi

list_services(){
  awk '/^[[:alnum:]]/ {print $1}' "$MANIFEST" | sed 's/://g'
}

if [[ $LIST -eq 1 ]]; then
  echo "Available services:" 
  awk '/:$/ {svc=$1; sub(/:$/, "", svc)} /desc:/ {gsub(/^[ \t]+/, "", $0); print " - " svc " : " substr($0, index($0,$2))}' "$MANIFEST" | sed 's/:$//'
  exit 0
fi

if [[ -n "$LOCAL" ]]; then
  # Run a local script path
  if [[ ! -f "$LOCAL" ]]; then
    echo "Local script not found: $LOCAL" >&2
    exit 3
  fi
  tmpdir=$(mktemp -dt uni-installer.XXXX)
  trap 'rm -rf "$tmpdir"' EXIT
  cp "$LOCAL" "$tmpdir/installer.sh"
  chmod +x "$tmpdir/installer.sh"
  if [[ $DRY_RUN -eq 1 ]]; then echo "--dry-run: would execute $LOCAL"; exit 0; fi
  if [[ $ASSUME_YES -eq 1 ]]; then exec sudo bash "$tmpdir/installer.sh" --skip-start; else read -p "Run local installer $LOCAL as root? [y/N] " ans; case "$ans" in y|Y) exec sudo bash "$tmpdir/installer.sh" ;; *) echo "Aborted"; exit 1;; esac fi
fi

if [[ -z "$SERVICE" ]]; then
  echo "No service specified. Use --list to view available services." >&2
  usage
  exit 2
fi

# find script in manifest
SCRIPT_NAME=$(awk -v svc="$SERVICE" 'BEGIN{found=0} $0~svc":"{found=1;next} found && /script:/ {print $2; exit}' "$MANIFEST")
if [[ -z "$SCRIPT_NAME" ]]; then
  echo "Service not found in manifest: $SERVICE" >&2
  echo "Use --list to see available services." >&2
  exit 4
fi

# Use the existing template logic: download, verify, execute
TEMPLATE="$ROOT_DIR/templates/installer-template.sh"
if [[ ! -x "$TEMPLATE" ]]; then
  echo "Installer template missing: $TEMPLATE" >&2
  exit 5
fi

exec "$TEMPLATE" "$SCRIPT_NAME" $( [[ $DRY_RUN -eq 1 ]] && echo --dry-run ) $( [[ $SKIP_START -eq 1 ]] && echo --skip-start ) $( [[ $ASSUME_YES -eq 1 ]] && echo --yes )
