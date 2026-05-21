#!/usr/bin/env bash
set -euo pipefail

# Official installer places the binary at /usr/local/bin/ollama,
# creates an 'ollama' system user, and installs + enables the systemd service.
curl -fsSL https://ollama.com/install.sh | sh
