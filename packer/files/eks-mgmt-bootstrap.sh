#!/bin/bash

# Script can be used to create create an airgapped eks-d management cluster
# Script makes assumption that it is run in the same directory as images.tar file containing eks-d images and eks-anywhere-downloads/ directory both created by eksctl anywhere command
# Script also assumes that the eksa-mgmt-cluster.yaml file is in the same directory and has had placeholder values configured for desired cluster settings

# Create self signed registry cert
host_ip=$(ip route get $(ip route show 0.0.0.0/0 | grep -oP 'via \K\S+') | grep -oP 'src \K\S+')
openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes -keyout tmp/cert.key -out tmp/cert.pem -subj "/CN=${host_ip}" -addext "subjectAltName=IP:${host_ip}"
sudo mkdir /mnt/registry-certs
sudo mv tmp/cert.key /mnt/registry-certs/.
sudo mv tmp/cert.pem /mnt/registry-certs/.

# Copy self signed registry cert into docker certs.d directory do local docker daemon trusts registry when bootstrapping management cluster
sudo mkdir /etc/docker/certs.d/${host_ip}\:5000/
sudo cp /mnt/registry-certs/cert.pem /etc/docker/certs.d/${host_ip}\:5000/ca.crt
sudo systemctl restart docker

# Start local registry
docker run -d \
  --restart=always \
  --name registry \
  -v /mnt/registry-certs:/certs \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:5000 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/cert.pem \
  -e REGISTRY_HTTP_TLS_KEY=/certs/cert.key \
  -p 5000:5000 \
  registry:2

# Copy eks-d dependencies into bootstrap registry. --insecure flag is needed to copy helm charts since registry is using self signed cert
REGISTRY_MIRROR_URL="${host_ip}:5000"
eksctl anywhere import images -i images.tar -r ${REGISTRY_MIRROR_URL} --bundles ./eks-anywhere-downloads/bundle-release.yaml --insecure

# Create mgmt cluster
eksctl anywhere create cluster -f eksa-mgmt-cluster.yaml --bundles-override ./eks-anywhere-downloads/bundle-release.yaml

echo "Management cluster has been created. Kubelet CSRs will need to be approved. Use kubectl get `csr | grep Pending` to check for pending certs and `for cert in $(kubectl get csr -o custom-columns=":metadata.name"); do kubectl certificate approve $cert; done` to sign all CSRs that currently exist."
echo "Before deploying the uds-bundle to set up the permanent registry, update the cilium-config to set 'policy-cidr-match-mode: nodes' and restart the cilium pods."
