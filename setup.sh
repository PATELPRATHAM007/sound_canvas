#!/usr/bin/env bash

# Convenience shortcut to run setup_macos.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "$SCRIPT_DIR/setup_macos.sh" "$@"
