#!/usr/bin/env bash
# Wrapper for Certbot installer (placeholder)
SCRIPT_NAME="certbot.sh"
exec "$(dirname "$0")/templates/installer-template.sh" "$SCRIPT_NAME" "$@"
