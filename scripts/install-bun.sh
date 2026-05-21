#!/usr/bin/env bash
set -euo pipefail

# Install bun system-wide so all users have it in PATH via /usr/local/bin
curl -fsSL https://bun.sh/install | BUN_INSTALL=/usr/local bash

bun --version
