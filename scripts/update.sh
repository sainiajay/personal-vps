#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get upgrade -y -o Dpkg::Options::="--force-confnew"
apt-get install -y \
  curl \
  wget \
  gnupg \
  ca-certificates \
  apt-transport-https \
  lsb-release \
  unzip

apt-get clean
rm -rf /var/lib/apt/lists/*
