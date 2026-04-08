#!/usr/bin/env bash
# Wrapper for Node.js installer
SCRIPT_NAME="nodejs.sh"
exec "$(dirname "$0")/templates/installer-template.sh" "$SCRIPT_NAME" "$@"
