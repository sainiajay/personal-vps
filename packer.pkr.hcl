packer {
  required_version = ">= 1.10.0"

  required_plugins {
    amazon = {
      version = ">= 1.3.0"
      source  = "github.com/hashicorp/amazon"
    }
    googlecompute = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/googlecompute"
    }
    azure = {
      version = ">= 2.0.0"
      source  = "github.com/hashicorp/azure"
    }
    digitalocean = {
      version = ">= 1.3.0"
      source  = "github.com/hashicorp/digitalocean"
    }
    hcloud = {
      version = ">= 1.3.0"
      source  = "github.com/hetznercloud/hcloud"
    }
  }
}
