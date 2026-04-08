#!/usr/bin/env bash
# Wrapper for Postgres installer (placeholder)
SCRIPT_NAME="postgres.sh"
exec "$(dirname "$0")/templates/installer-template.sh" "$SCRIPT_NAME" "$@"
