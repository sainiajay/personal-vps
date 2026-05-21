variable "image_name" {
  description = "Base name for generated images"
  type        = string
  default     = "ubuntu-base"
}

# ── AWS ────────────────────────────────────────────────────────────────────────

variable "aws_region" {
  description = "AWS region to build the AMI in"
  type        = string
  default     = "us-east-1"
}

variable "aws_instance_type" {
  description = "EC2 instance type used during the build"
  type        = string
  default     = "t3.micro"
}

# ── GCP ────────────────────────────────────────────────────────────────────────

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
  default     = ""
}

variable "gcp_zone" {
  description = "GCP zone to build in"
  type        = string
  default     = "us-central1-a"
}

variable "gcp_machine_type" {
  description = "GCP machine type used during the build"
  type        = string
  default     = "e2-medium"
}

# ── Azure ──────────────────────────────────────────────────────────────────────

variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = ""
}

variable "azure_resource_group" {
  description = "Azure resource group to store the managed image in (must exist)"
  type        = string
  default     = "packer-images"
}

variable "azure_location" {
  description = "Azure region to build in"
  type        = string
  default     = "East US"
}

# ── DigitalOcean ───────────────────────────────────────────────────────────────

variable "do_api_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
  default     = ""
}

variable "do_region" {
  description = "DigitalOcean region to build the snapshot in"
  type        = string
  default     = "nyc3"
}

# ── Hetzner ────────────────────────────────────────────────────────────────────

variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
  default     = ""
}

variable "hcloud_datacenter" {
  description = "Hetzner Cloud datacenter to build the snapshot in"
  type        = string
  default     = "fsn1-dc14"
}
