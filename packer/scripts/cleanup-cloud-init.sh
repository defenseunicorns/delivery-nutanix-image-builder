#!/bin/bash
set -e

# Cleanup cloud-init and machine-id, this is generally only needed for non-AWS environments
cloud-init clean
truncate -s 0 /etc/machine-id
