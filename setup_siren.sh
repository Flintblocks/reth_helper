#!/bin/bash

# Load the environment variables
source load_variables.sh

# Update package information
sudo apt-get update

# Install prerequisites
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common unzip

# Add Docker's GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add the Docker APT repository
sudo add-apt-repository "deb [arch=$SERVER_ARCH] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update the package database with Docker packages
sudo apt-get update

# Install Docker
sudo apt-get install -y docker-ce

# Download Siren
curl -LO https://github.com/sigp/siren/archive/refs/tags/v0.1.0-beta.4.tar.gz

# Unzip Siren
tar xvfz "v0.1.0-beta.4.tar.gz"

# Go to Siren directory
cd siren-0.1.0-beta.4

# Assuming there's a Dockerfile, build the Docker image
sudo make docker

# Run Siren in a Docker container
sudo docker run --rm -ti -d --name siren -p 6969:80 siren -d

# We need to get current servers ipv4 address
public_ip=$(curl -s https://ipinfo.io/ip)

echo "Siren is now accessible at http://$public_ip:6009"