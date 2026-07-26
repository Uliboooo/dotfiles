#!/usr/bin/env bash
set -euo pipefail

if command -v bat >/dev/null 2>&1; then
  exec bat "$@"
else
  exec cat "$@"
fi
