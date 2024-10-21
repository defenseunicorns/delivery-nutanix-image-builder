#!/bin/bash
# Copyright 2024 Defense Unicorns
# SPDX-License-Identifier: AGPL-3.0-or-later OR LicenseRef-Defense-Unicorns-Commercial

set -e

# Cleanup cloud-init and machine-id, this is generally only needed for non-AWS environments
cloud-init clean
truncate -s 0 /etc/machine-id
