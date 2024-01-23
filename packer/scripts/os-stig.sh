#!/bin/bash
set -e

# Pull Ansible STIGs from https://public.cyber.mil/stigs/supplemental-automation-content/
mkdir -p /tmp/ansible && chmod 700 /tmp/ansible && cd /tmp/ansible
curl -L -o ansible.zip https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/U_RHEL_8_V1R13_STIG_Ansible.zip
unzip ansible.zip
unzip *-ansible.zip
chmod +x enforce.sh && ./enforce.sh
