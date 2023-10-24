#!/bin/bash
set -e

# Cleanup dependencies and utils that shouldn't be in final image
yum remove ansible -y


cd && rm -rf /tmp/*
