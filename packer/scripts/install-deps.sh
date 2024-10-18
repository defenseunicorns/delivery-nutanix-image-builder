#!/bin/bash
set -e

# Install dependencies and cli tools needed by other packer scripts and NDB service
dnf update -y
dnf install -y ansible unzip iptables nftables wget lvm2* zip lsof rsync network-scripts

# Ensure that ansible collections needed are installed 
ansible-galaxy collection install community.general
ansible-galaxy collection install ansible.posix
