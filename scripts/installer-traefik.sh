#!/usr/bin/env bash
# Wrapper for Traefik installer (placeholder)
SCRIPT_NAME="traefik.sh"
exec "$(dirname "$0")/templates/installer-template.sh" "$SCRIPT_NAME" "$@"
