# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

HashiCorp Packer project that builds Ubuntu 24.04 LTS VM images for five cloud providers. Each image has an updated package index and the following tools pre-installed: git, gh (GitHub CLI), bun, rootless Docker, and ollama.

## Supported Providers

| Provider | Source type | SSH user | Image artifact |
|---|---|---|---|
| AWS | `amazon-ebs` | `ubuntu` | AMI |
| GCP | `googlecompute` | `ubuntu` | GCE custom image |
| Azure | `azure-arm` | `azureuser` | Managed image |
| DigitalOcean | `digitalocean` | `root` | Droplet snapshot |
| Hetzner | `hcloud` | `root` | Server snapshot (server type: `cx23`, location: `fsn1`) |

## Commands

```bash
# Install required plugins (once after cloning)
packer init .

# Validate all configuration
packer validate -var-file=variables.pkrvars.hcl .

# Build all providers
packer build -var-file=variables.pkrvars.hcl .

# Build a single provider
packer build -only=ubuntu-base.amazon-ebs.ubuntu      -var-file=variables.pkrvars.hcl .
packer build -only=ubuntu-base.googlecompute.ubuntu   -var-file=variables.pkrvars.hcl .
packer build -only=ubuntu-base.azure-arm.ubuntu       -var-file=variables.pkrvars.hcl .
packer build -only=ubuntu-base.digitalocean.ubuntu    -var-file=variables.pkrvars.hcl .
packer build -only=ubuntu-base.hcloud.ubuntu          -var-file=variables.pkrvars.hcl .
```

## Setup

1. Copy `variables.pkrvars.hcl.example` → `variables.pkrvars.hcl` and fill in credentials.
2. `variables.pkrvars.hcl` is git-ignored; never commit it.
3. Authenticate with each provider before building:
   - **AWS**: `~/.aws/credentials`, env vars, or instance profile
   - **GCP**: `gcloud auth application-default login`
   - **Azure**: `az login` or `ARM_*` env vars; the resource group in `azure_resource_group` must exist
   - **DigitalOcean / Hetzner**: API tokens in the `.pkrvars.hcl` file

## Architecture

All `.pkr.hcl` files in the root are merged by Packer at build time:

- **`packer.pkr.hcl`** — version constraint and required plugin declarations
- **`variables.pkr.hcl`** — all variable declarations with defaults
- **`sources.pkr.hcl`** — one `source` block per provider, all targeting Ubuntu 24.04 LTS
- **`build.pkr.hcl`** — single `build` block that fans out across all sources

### Provisioner execution order

All shell provisioners run via `sudo env {{ .Vars }} bash` so the scripts have root regardless of the SSH user.

| Script | What it does |
|---|---|
| `scripts/update.sh` | `apt update && apt upgrade`, installs curl/wget/gnupg/etc. |
| `scripts/install-git-gh.sh` | git + GitHub CLI via the official apt repo |
| `scripts/install-bun.sh` | bun installed system-wide at `/usr/local/bin/bun` |
| `scripts/install-docker-rootless.sh` | Docker Engine + rootless mode configured for `TARGET_USER` |
| `scripts/install-ollama.sh` | Ollama binary + systemd service via official installer |

### Rootless Docker design

The `install-docker-rootless.sh` script accepts a `TARGET_USER` env var (set via `environment_vars` + `only` blocks in `build.pkr.hcl`):

- `ubuntu` for AWS, GCP, DigitalOcean, Hetzner
- `azureuser` for Azure

On DO/Hetzner (SSH as root), the script creates the `ubuntu` user if it doesn't exist. It then calls `dockerd-rootless-setuptool.sh install --skip-iptables` as that user, enables the user-scoped systemd unit, and appends `DOCKER_HOST` to the user's `.bashrc`.
