#!/usr/bin/env bash
# Wrapper for NPM installer
SCRIPT_NAME="npm.sh"
OWNER_PLACEHOLDER="OWNER"
REPO_PLACEHOLDER="REPO"
BRANCH_PLACEHOLDER="main"

exec "$(dirname "$0")/templates/installer-template.sh" "$SCRIPT_NAME" "$@"
