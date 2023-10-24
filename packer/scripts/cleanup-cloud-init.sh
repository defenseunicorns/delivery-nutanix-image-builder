#!/bin/bash
set -e

# Cleanup cloud-init and machine-id, this is generally only needed for non-AWS environments
cloud-init clean
rm -rf /etc/machine-id
