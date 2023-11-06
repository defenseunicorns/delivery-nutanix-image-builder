#!/bin/bash
set -e

wget https://apt.postgresql.org/pub/repos/yum/RPM-GPG-KEY-PGDG
sudo rpm --import RPM-GPG-KEY-PGDG
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo dnf -qy module disable postgresql
sudo dnf install -y postgresql${POSTGRES_VERSION}-server
sudo rpm --import http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-8
sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo subscription-manager repos --enable codeready-builder-for-rhel-8-x86_64-rpms
sudo dnf install -y ${POSTGIS_VERSION}
