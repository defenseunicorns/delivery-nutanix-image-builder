#!/bin/bash
set -e

wget https://apt.postgresql.org/pub/repos/yum/RPM-GPG-KEY-PGDG
sudo rpm --import RPM-GPG-KEY-PGDG
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo dnf -qy module disable postgresql
sudo dnf install -y postgresql${POSTGRES_VERSION}-server
