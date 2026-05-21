#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# git
apt-get update -y
apt-get install -y git

# GitHub CLI — official apt repository
mkdir -p -m 755 /etc/apt/keyrings
wget -qO /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  https://cli.github.com/packages/githubcli-archive-keyring.gpg
chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] \
  https://cli.github.com/packages stable main" \
  > /etc/apt/sources.list.d/github-cli.list

apt-get update -y
apt-get install -y gh

apt-get clean
rm -rf /var/lib/apt/lists/*
