#!/bin/bash
# Script installs and configures dependencies needed to both build eks-d node images as well as bootstrap and eks-anywhere environment in an airgapped environment

# Move EKS-A bootrap files somewhere permanent
config_dir=/eks-anywhere-bootstrap
file_dir=/tmp/files
sudo mkdir -p $config_dir
sudo mv $file_dir/eks* $config_dir/.

sudo yum update -y
sudo yum install -y git jq unzip make wget python3.11-pip

# Install brew and related dependencies
NONINTERACTIVE=1 CI=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> ~/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
sudo yum groupinstall -y 'Development Tools'
brew install gcc

# Install eks-anywhere and deps needed
curl "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" \
    --silent --location \
    | tar xz -C /tmp
sudo install -m 0755 /tmp/eksctl /usr/local/bin/eksctl
RELEASE_VERSION=${ANYWHERE_VERSION}
EKS_ANYWHERE_TARBALL_URL=$(curl https://anywhere-assets.eks.amazonaws.com/releases/eks-a/manifest.yaml --silent --location | yq ".spec.releases[] | select(.version==\"$RELEASE_VERSION\").eksABinary.$(uname -s | tr A-Z a-z).uri")
curl $EKS_ANYWHERE_TARBALL_URL \
    --silent --location \
    | tar xz ./eksctl-anywhere
sudo install -m 0755 ./eksctl-anywhere /usr/local/bin/eksctl-anywhere
brew install yq

# Install tfk8s which can be used to help convert kubernetes manifests into HCL
brew install tfk8s

# Install eks-anywhere image-builder
EKSA_RELEASE_VERSION=$(curl -sL https://anywhere-assets.eks.amazonaws.com/releases/eks-a/manifest.yaml | yq ".spec.latestVersion")
cd /tmp
BUNDLE_MANIFEST_URL=$(curl -s https://anywhere-assets.eks.amazonaws.com/releases/eks-a/manifest.yaml | yq ".spec.releases[] | select(.version==\"$EKSA_RELEASE_VERSION\").bundleManifestUrl")
IMAGEBUILDER_TARBALL_URI=$(curl -s $BUNDLE_MANIFEST_URL | yq ".spec.versionsBundles[0].eksD.imagebuilder.uri")
curl -s $IMAGEBUILDER_TARBALL_URI | tar xz ./image-builder
sudo install -m 0755 ./image-builder /usr/local/bin/image-builder   
cd -
mkdir -p /home/$USER/.ssh
echo "HostKeyAlgorithms +ssh-rsa" >> /home/$USER/.ssh/config
echo "PubkeyAcceptedKeyTypes +ssh-rsa" >> /home/$USER/.ssh/config
sudo chmod 600 /home/$USER/.ssh/config

# Remove symlink that conflicts with actual packer
sudo unlink /usr/bin/packer
# Install packer
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install packer

# Install docker
sudo yum remove -y docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine \
    podman \
    runc
sudo yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
sudo tee /etc/docker/daemon.json <<EOF >/dev/null
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF
sudo systemctl restart docker

# Startup a registry so there is a registry image baked onto image that can be used to set up a registry mirror in an airgap
sudo docker image pull registry:2

# Install uds which includes tools like zarf, k9s, kubectl, etc
brew tap defenseunicorns/tap
brew install uds
