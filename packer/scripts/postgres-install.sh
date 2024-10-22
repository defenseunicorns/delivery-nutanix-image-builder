#!/bin/bash
set -e

export PATH=$PATH:/usr/local/bin
subscription-manager repos --enable codeready-builder-for-rhel-8-$(arch)-rpms
rpm --import https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-8
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf groupinstall -y "Development Tools"
dnf install -y zlib-devel readline-devel libicu-devel systemd-devel cmake libxml2-devel proj-devel gdal-devel protobuf-c-devel protobuf-c-compiler protobuf-devel json-c-devel

dnf -qy module disable postgresql

wget https://ftp.postgresql.org/pub/source/v${POSTGRES_VERSION}/postgresql-${POSTGRES_VERSION}.tar.bz2

tar -xvf postgresql-${POSTGRES_VERSION}.tar.bz2
cd postgresql-${POSTGRES_VERSION}/
ls -l

./configure --with-systemd
make
make install
useradd postgres
cd

# Install postgis
## Install GEOS from source
wget https://download.osgeo.org/geos/geos-3.13.0.tar.bz2
# Unpack and setup build directory
tar xvfj geos-3.13.0.tar.bz2
cd geos-3.13.0
mkdir _build
cd _build
# Set up the build
cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    ..
# Run the build, test, install
make
make install
cd

## Install postgis from source
wget https://postgis.net/stuff/postgis-${POSTGIS_VERSION}.tar.gz
tar -xvzf postgis-${POSTGIS_VERSION}.tar.gz
cd postgis-${POSTGIS_VERSION}
./configure --with-pgconfig=/usr/local/pgsql/bin/pg_config
make
make install
cd

# Install HA postgres deps

dnf install -y  python3-devel python3-psycopg2 haproxy keepalived
wget https://github.com/etcd-io/etcd/releases/download/v3.5.16/etcd-v3.5.16-linux-amd64.tar.gz
tar xzvf etcd-v3.5.16-linux-amd64.tar.gz
mv etcd-v3.5.16-linux-amd64/etcd* /usr/local/bin/.

pip3 install patroni

# Move files

# Copy the postgres systemd service into the correct location for NDB
cp /tmp/files/postgres.service /etc/systemd/system/era_postgres.service
cp /tmp/files/haproxy* /etc/firewalld/services/.
cd /etc/firewalld/services
restorecon haproxy-http.xml
restorecon haproxy-https.xml
chmod 640 haproxy*