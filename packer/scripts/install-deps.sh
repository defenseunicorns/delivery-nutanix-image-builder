#!/bin/bash
# Copyright 2024 Defense Unicorns
# SPDX-License-Identifier: AGPL-3.0-or-later OR LicenseRef-Defense-Unicorns-Commercial

set -e

# Install dependencies and cli tools needed by other packer scripts and NDB service
dnf update -y && yum upgrade -y
dnf install -y ansible unzip iptables nftables wget lvm2* zip lsof rsync network-scripts

# Ensure that ansible collections needed are installed 
ansible-galaxy collection install community.general
ansible-galaxy collection install ansible.posix
