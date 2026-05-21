#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# TARGET_USER is passed via Packer environment_vars.
# On DO/Hetzner (SSH as root), this script creates the user if absent.
# On AWS/GCP the ubuntu user already exists; on Azure it's azureuser.
TARGET_USER="${TARGET_USER:-ubuntu}"

# ── System packages ────────────────────────────────────────────────────────────

apt-get update -y
apt-get install -y uidmap dbus-user-session
curl -fsSL https://get.docker.com | sh
apt-get install -y docker-ce-rootless-extras

apt-get clean
rm -rf /var/lib/apt/lists/*

# The rootful daemon is not needed; rootless replaces it per-user
systemctl disable --now docker.service docker.socket 2>/dev/null || true

# ── Target user setup ──────────────────────────────────────────────────────────

if ! id -u "$TARGET_USER" &>/dev/null; then
  useradd -m -s /bin/bash "$TARGET_USER"
  usermod -aG sudo "$TARGET_USER"
  echo "${TARGET_USER} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${TARGET_USER}"
fi

# Allocate subordinate UID/GID ranges required by the user-namespace sandbox
grep -q "^${TARGET_USER}:" /etc/subuid 2>/dev/null || \
  usermod --add-subuids 100000-165535 "$TARGET_USER"
grep -q "^${TARGET_USER}:" /etc/subgid 2>/dev/null || \
  usermod --add-subgids 100000-165535 "$TARGET_USER"

# Allow user systemd services to survive logout
loginctl enable-linger "$TARGET_USER"

# ── Rootless Docker setup ──────────────────────────────────────────────────────

USER_ID=$(id -u "$TARGET_USER")
USER_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
XDG_RUNTIME_DIR="/run/user/${USER_ID}"

mkdir -p "$XDG_RUNTIME_DIR"
chown "${TARGET_USER}:${TARGET_USER}" "$XDG_RUNTIME_DIR"
chmod 0700 "$XDG_RUNTIME_DIR"

# Run the rootless setup tool as the target user.
# --skip-iptables avoids failures in build environments without full netfilter.
XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
  sudo -u "$TARGET_USER" \
  /usr/bin/dockerd-rootless-setuptool.sh install --skip-iptables

# Enable the user-scoped systemd unit (best-effort; unit files are already written)
XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
  sudo -u "$TARGET_USER" \
  systemctl --user enable docker 2>/dev/null || true

# Ensure DOCKER_HOST is set on login so `docker` works without extra config
PROFILE_SNIPPET="
# Docker rootless
export DOCKER_HOST=unix:///run/user/\$(id -u)/docker.sock
"
if ! grep -qF "DOCKER_HOST" "${USER_HOME}/.bashrc" 2>/dev/null; then
  printf '%s\n' "$PROFILE_SNIPPET" >> "${USER_HOME}/.bashrc"
fi

chown "${TARGET_USER}:${TARGET_USER}" "${USER_HOME}/.bashrc"
