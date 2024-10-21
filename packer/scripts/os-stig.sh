#!/bin/bash
# Copyright 2024 Defense Unicorns
# SPDX-License-Identifier: AGPL-3.0-or-later OR LicenseRef-Defense-Unicorns-Commercial

set -e

# Pull Ansible STIGs from https://public.cyber.mil/stigs/supplemental-automation-content/
mkdir -p /tmp/ansible && chmod 700 /tmp/ansible && cd /tmp/ansible
curl -L -o ansible.zip https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/U_RHEL_8_V1R13_STIG_Ansible.zip
unzip ansible.zip
unzip *-ansible.zip
# Remove do_reboot handler from tasks file - VMs used to create templates from packer will be booted later for SELINUX changes to take effect
TASKS_FILE=$( find roles/*/tasks -name main.yml -type f )
sed -i '/notify: do_reboot/d' $TASKS_FILE
chmod +x enforce.sh && ./enforce.sh
