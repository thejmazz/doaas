#!/bin/bash

# Expects
# - USERNAME
# to be set.

# Need HTTPS and certs
apt-get install apt-transport-https ca-certificates -y
# So we can use aufs storage driver
apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual -y
# Add GPG key
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
# Add Docker repo to apt sources
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | tee /etc/apt/sources.list.d/docker.list
apt-get update
# Purge old repo in case it exists
apt-get purge lxc-docker
# Ensure apt pulls from correct repository
apt-cache policy docker-engine

# Install docker-engine
apt-get install docker-engine -y

# Add $USERNAME to docker group
usermod -aG docker $USERNAME
