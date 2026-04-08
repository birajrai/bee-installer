#!/usr/bin/env bash
set -euo pipefail

# Node.js installer with version selector
# Usage: sudo bash nodejs.sh [--version 20] [--yes]

AVAILABLE=(18 20 22 24 26)
VER=""
ASSUME_YES=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version) VER="$2"; shift 2;;
    --yes) ASSUME_YES=1; shift;;
    -h|--help) echo "Usage: $0 [--version <${AVAILABLE[*]}>] [--yes]"; exit 0;;
    *) shift;;
  esac
done

choose_version(){
  echo "Available Node.js versions: ${AVAILABLE[*]}"
  PS3="Select version number: "
  select v in "${AVAILABLE[@]}"; do
    if [[ -n "$v" ]]; then
      echo "$v"
      return
    fi
  done
}

if [[ -z "$VER" ]]; then
  VER=$(choose_version)
fi

valid=0
for v in "${AVAILABLE[@]}"; do [[ "$v" == "$VER" ]] && valid=1; done
if [[ $valid -ne 1 ]]; then
  echo "Invalid version: $VER" >&2
  exit 2
fi

# Determine target user (prefer SUDO_USER)
TARGET_USER=${SUDO_USER:-$(id -un)}
TARGET_HOME=$(eval echo "~$TARGET_USER")

echo "Installing Node.js $VER for user $TARGET_USER"

if [[ $ASSUME_YES -ne 1 ]]; then
  read -p "Continue? [y/N] " ans
  case "$ans" in
    y|Y) ;;
    *) echo "Aborted"; exit 1;;
  esac
fi

# Install build essentials and curl
if ! command -v curl >/dev/null 2>&1; then
  apt-get update -y
  apt-get install -y curl build-essential
fi

# Install nvm for the target user if not present
NVM_DIR="$TARGET_HOME/.nvm"
if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
  echo "Installing nvm for $TARGET_USER"
  # Run install as the target user
  su - "$TARGET_USER" -c "curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash"
fi

# Load nvm and install node
echo "Installing Node $VER via nvm for $TARGET_USER"
su - "$TARGET_USER" -c "bash -lc 'export NVM_DIR=\"\$HOME/.nvm\"; [ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"; nvm install $VER; nvm alias default $VER; nvm use default; node -v; npm -v'"

echo "Node.js $VER installed for $TARGET_USER. To use it in new shells, log out and log back in, or source ~/.nvm/nvm.sh"
