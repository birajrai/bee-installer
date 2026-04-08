#!/usr/bin/env bash
# Wrapper for nodejs installer
SCRIPT_NAME="nodejs.sh"
exec "$(dirname "$0")/../templates/installer-template.sh" "$SCRIPT_NAME" "$@"
