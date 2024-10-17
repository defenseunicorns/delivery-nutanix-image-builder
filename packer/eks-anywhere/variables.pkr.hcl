// Copyright 2024 Defense Unicorns
// SPDX-License-Identifier: AGPL-3.0-or-later OR LicenseRef-Defense-Unicorns-Commercial

variable "output_image_name" {
  type        = string
  description = "Name to use for the published image"
}

variable "timestamp" {
  type        = bool
  description = "Append a timestamp to the end of the published image name"
  default     = true
}

variable "base_image_name" {
  type        = string
  description = "Name of disk image in cluster to use as base image, tested with Ubuntu 20/04 and RHEL 8"
}

variable "image_delete" {
  type        = bool
  description = "Build, but delete the final image rather than saving on Prism Central"
  default     = false
}

variable "image_export" {
  type        = bool
  description = "Export raw image in the current folder"
  default     = false
}

variable "nutanix_username" {
  type        = string
  description = "Username for Prism Central"
}

variable "nutanix_password" {
  type        = string
  description = "Password for Prism Central"
  sensitive   = true
}

variable "nutanix_endpoint" {
  type        = string
  description = "Endpoint (URL/IP) for Prism Central"
}

variable "nutanix_port" {
  type        = number
  description = "Port for Prism Central"
  default     = 9440
}

variable "nutanix_insecure" {
  type        = bool
  description = "Whether connection to Prism Central should be insecure"
  default     = false
}

variable "nutanix_cluster" {
  type        = string
  description = "Name of cluster to use for Packer build VM"
}

variable "nutanix_subnet" {
  type        = string
  description = "Name of subnet in cluster to use for Packer build VM"
}

variable "anywhere_version" {
  type        = string
  description = "Version of EKS Anywhere plugin to install. Needs to match the version of the anywhere cli image in your eksa registry mirror for airgap installs."
  default     = "v0.20.3"
}
