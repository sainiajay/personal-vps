build {
  name = "ubuntu-base"

  sources = [
    "source.amazon-ebs.ubuntu",
    "source.googlecompute.ubuntu",
    "source.azure-arm.ubuntu",
    "source.digitalocean.ubuntu",
    "source.hcloud.ubuntu",
  ]

  # Update package index, upgrade installed packages, install prerequisites
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; sudo env {{ .Vars }} bash '{{ .Path }}'"
    scripts = [
      "scripts/update.sh",
      "scripts/install-git-gh.sh",
      "scripts/install-bun.sh",
    ]
  }

  # Docker rootless — target user is the default SSH non-root user per provider.
  # DO and Hetzner SSH as root; the script creates an 'ubuntu' user for them.
  provisioner "shell" {
    only            = ["amazon-ebs.ubuntu", "googlecompute.ubuntu", "digitalocean.ubuntu", "hcloud.ubuntu"]
    execute_command = "chmod +x {{ .Path }}; sudo env {{ .Vars }} bash '{{ .Path }}'"
    script          = "scripts/install-docker-rootless.sh"
    environment_vars = ["TARGET_USER=ubuntu"]
  }

  provisioner "shell" {
    only            = ["azure-arm.ubuntu"]
    execute_command = "chmod +x {{ .Path }}; sudo env {{ .Vars }} bash '{{ .Path }}'"
    script          = "scripts/install-docker-rootless.sh"
    environment_vars = ["TARGET_USER=azureuser"]
  }

  # Ollama — installs binary, creates ollama user, and enables systemd service
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; sudo env {{ .Vars }} bash '{{ .Path }}'"
    script          = "scripts/install-ollama.sh"
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}
