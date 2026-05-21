# All sources target Ubuntu 24.04 LTS (Noble Numbat).
# Canonical AWS owner ID: 099720109477

source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.image_name}-ubuntu2404-{{timestamp}}"
  instance_type = var.aws_instance_type
  region        = var.aws_region

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
    Name    = var.image_name
    OS      = "ubuntu-24.04"
    Builder = "packer"
  }
}

source "googlecompute" "ubuntu" {
  project_id          = var.gcp_project_id
  source_image_family = "ubuntu-2404-lts-amd64"
  zone                = var.gcp_zone
  machine_type        = var.gcp_machine_type
  ssh_username        = "ubuntu"
  image_name          = "${var.image_name}-ubuntu2404-{{timestamp}}"
  image_description   = "Ubuntu 24.04 base image built with Packer"

  image_labels = {
    name    = var.image_name
    os      = "ubuntu-2404"
    builder = "packer"
  }
}

source "azure-arm" "ubuntu" {
  subscription_id = var.azure_subscription_id

  managed_image_resource_group_name = var.azure_resource_group
  managed_image_name                = "${var.image_name}-ubuntu2404-{{timestamp}}"

  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-noble"
  image_sku       = "24_04-lts"

  location     = var.azure_location
  vm_size      = "Standard_B1s"
  ssh_username = "azureuser"

  azure_tags = {
    Name    = var.image_name
    OS      = "ubuntu-24.04"
    Builder = "packer"
  }
}

source "digitalocean" "ubuntu" {
  api_token     = var.do_api_token
  image         = "ubuntu-24-04-x64"
  region        = var.do_region
  size          = "s-1vcpu-1gb"
  snapshot_name = "${var.image_name}-ubuntu2404-{{timestamp}}"
  ssh_username  = "root"
}

source "hcloud" "ubuntu" {
  token         = var.hcloud_token
  image         = "ubuntu-24.04"
  location      = var.hcloud_location
  server_type   = "cx23"
  snapshot_name = "${var.image_name}-ubuntu2404-{{timestamp}}"
  ssh_username  = "root"
}
