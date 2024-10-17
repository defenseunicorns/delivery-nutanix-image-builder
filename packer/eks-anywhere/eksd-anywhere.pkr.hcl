// Copyright 2024 Defense Unicorns
// SPDX-License-Identifier: AGPL-3.0-or-later OR LicenseRef-Defense-Unicorns-Commercial

packer {
  required_version = ">= 1.9.2"

  required_plugins {
    nutanix = {
      version = ">= 0.8.0"
      source  = "github.com/nutanix-cloud-native/nutanix"
    }
  }
}

locals {
  img_name = var.timestamp ? lower("${var.output_image_name}-${var.anywhere_version}-${formatdate("YYYYMMDDhhmm", timestamp())}") : lower("${var.output_image_name}")
}

source "nutanix" "base" {
  // Nutanix Prism Central Connection Info
  nutanix_username = var.nutanix_username
  nutanix_password = var.nutanix_password
  nutanix_endpoint = var.nutanix_endpoint
  nutanix_port     = var.nutanix_port
  nutanix_insecure = var.nutanix_insecure
  cluster_name     = var.nutanix_cluster

  // Temporary VM Config
  vm_disks {
    image_type        = "DISK_IMAGE"
    source_image_name = var.base_image_name
    disk_size_gb      = 15
  }
  vm_nics {
    subnet_name = var.nutanix_subnet
  }
  cpu       = 2
  memory_mb = 2048

  // Base image / publishing settings
  os_type          = "Linux"
  image_name       = local.img_name
  image_delete     = var.image_delete
  image_export     = var.image_export
  force_deregister = true
  vm_force_delete  = true
  boot_type        = "uefi"

  // Startup / Connection / Shutdown Details
  user_data        = base64encode(file("cloud-config.yaml"))
  ssh_username     = "packer"
  ssh_password     = "builder"
  shutdown_command = "sudo su root -c \"userdel -rf packer; rm /etc/sudoers.d/90-cloud-init-users; /sbin/shutdown -hP now\""
  shutdown_timeout = "2m"
}

build {
  name    = local.img_name
  sources = ["source.nutanix.base"]

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; sudo {{ .Vars }} {{ .Path }}"
    script          = "../scripts/install-deps.sh"
    timeout         = "20m"
  }

  provisioner "shell" {
    // STIG-ing must be run as root
    execute_command   = "chmod +x {{ .Path }}; sudo {{ .Vars }} {{ .Path }}"
    script            = "../scripts/os-stig.sh"
    expect_disconnect = true
    timeout           = "20m"
  }

  provisioner "file" {
    source      = "../files"
    destination = "/tmp"
  }

  provisioner "shell" {
    environment_vars = [
      "ANYWHERE_VERSION=${var.anywhere_version}"
    ]
    script          = "../scripts/eks-anywhere-setup.sh"
    timeout         = "20m"
  }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; sudo {{ .Vars }} {{ .Path }}"
    script          = "../scripts/cleanup-cloud-init.sh"
    timeout         = "15m"
  }
}
