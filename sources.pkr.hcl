# All sources target Ubuntu 24.04 LTS (Noble Numbat).
# Canonical AWS owner ID: 099720109477

locals {
  description   = "Ubuntu 24.04 LTS base image — git, gh, bun, rootless Docker, Ollama"
  # Normalise instance-type strings for use in image names:
  #   t3.micro  → t3micro   (dots removed)
  #   Standard_B1s → standard-b1s (lowercased, underscores → dashes)
  aws_type_slug   = replace(var.aws_instance_type, ".", "")
  azure_size_slug = lower(replace(var.azure_vm_size, "_", "-"))
}

source "amazon-ebs" "ubuntu" {
  ami_name        = "${var.image_name}-ubuntu2404-${local.aws_type_slug}-{{timestamp}}"
  ami_description = local.description
  instance_type   = var.aws_instance_type
  region          = var.aws_region

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  ssh_username = "ubuntu"

  tags = {
    Name         = var.image_name
    OS           = "ubuntu-24.04"
    Builder      = "packer"
    InstanceType = var.aws_instance_type
  }
}

source "googlecompute" "ubuntu" {
  project_id          = var.gcp_project_id
  source_image_family = "ubuntu-2404-lts-amd64"
  zone                = var.gcp_zone
  machine_type        = var.gcp_machine_type
  ssh_username        = "ubuntu"
  image_name          = "${var.image_name}-ubuntu2404-${var.gcp_machine_type}-{{timestamp}}"
  image_description   = local.description

  image_labels = {
    name         = var.image_name
    os           = "ubuntu-2404"
    builder      = "packer"
    machine-type = var.gcp_machine_type
  }
}

source "azure-arm" "ubuntu" {
  subscription_id = var.azure_subscription_id

  managed_image_resource_group_name = var.azure_resource_group
  managed_image_name                = "${var.image_name}-ubuntu2404-${local.azure_size_slug}-{{timestamp}}"

  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-noble"
  image_sku       = "24_04-lts"

  location     = var.azure_location
  vm_size      = var.azure_vm_size
  ssh_username = "azureuser"

  azure_tags = {
    Name        = var.image_name
    OS          = "ubuntu-24.04"
    Builder     = "packer"
    VMSize      = var.azure_vm_size
    Description = local.description
  }
}

source "digitalocean" "ubuntu" {
  api_token     = var.do_api_token
  image         = "ubuntu-24-04-x64"
  region        = var.do_region
  size          = var.do_size
  snapshot_name = "${var.image_name}-ubuntu2404-${var.do_size}-{{timestamp}}"
  ssh_username  = "root"
}

source "hcloud" "ubuntu" {
  token         = var.hcloud_token
  image         = "ubuntu-24.04"
  location      = var.hcloud_location
  server_type   = var.hcloud_server_type
  snapshot_name = "${var.image_name}-ubuntu2404-${var.hcloud_server_type}-{{timestamp}}"
  ssh_username  = "root"
}
