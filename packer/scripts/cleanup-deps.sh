#!/bin/bash
# Copyright 2024 Defense Unicorns
# SPDX-License-Identifier: AGPL-3.0-or-later OR LicenseRef-Defense-Unicorns-Commercial

set -e

# Cleanup dependencies and utils that shouldn't be in final image
yum remove ansible -y


cd && rm -rf /tmp/*
