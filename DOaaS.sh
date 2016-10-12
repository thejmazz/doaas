#!/bin/bash

##############################
# Digital Ocean as a Service #
##############################

# Expects
# - SERVER_IP_ADDRESS
# - DO_KEY
# - USERNAME
# - KEY_NAME
# - PUBKEY
# to be set.

# Locally create private/public key pair
# bash -s < ./scripts/locksmith.sh

# Update and upgrade
ssh root@$SERVER_IP_ADDRESS -i $DO_KEY 'bash -c "apt-get update && apt-get upgrade -y"'

# === apt-get installs ===
# TODO have deps map to apt-get keys
ssh root@$SERVER_IP_ADDRESS -i $DO_KEY 'bash -c "apt-get install curl -y"'
# YCM
ssh root@$SERVER_IP_ADDRESS -i $DO_KEY 'bash -c "apt-get install build-essential cmake python-dev python3-dev -y"'
# Docker
ssh root@$SERVER_IP_ADDRESS -i $DO_KEY 'bash -c "apt-get install apt-transport-https ca-certificates -y"'
# aufs - docker storage volume driver, needs system restart
ssh root@$SERVER_IP_ADDRESS -i $DO_KEY 'bash -c "apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual -y"'
# add docker gpg keys, add docker to apt sources, install docker-engine
ssh root@$SERVER_IP_ADDRESS -i $DO_KEY USERNAME="$USERNAME" 'bash -s' < ./scripts/docker-ubuntu.sh

# === Installs ===
# yadm
ssh root@$SERVER_IP_ADDRESS -i $DO_KEY 'bash -c "curl -sfLo /usr/local/bin/yadm https://github.com/TheLocehiliosan/yadm/raw/master/yadm && chmod a+x /usr/local/bin/yadm"'
# caddy and give it permission to low ports (like 80 lol)
ssh root@$SERVER_IP_ADDRESS -i $DO_KEY 'bash -c "curl https://getcaddy.com | bash && setcap cap_net_bind_service=+ep /usr/local/bin/caddy"'

# === Setup user ===
# Run user setup script over ssh as root
ssh root@$SERVER_IP_ADDRESS -i $DO_KEY USERNAME="$USERNAME" "PUBKEY=\"$PUBKEY\"" 'bash -s' < ./scripts/setupuser.sh

# add $USERNAME to docker group
ssh root@$SERVER_IP_ADDRESS -i $DO_KEY USERNAME="$USERNAME" "bash -c \"echo $USERNAME && usermod -aG docker $USERNAME\""

# === Install things for user ===
# Bring in vim to user's home
ssh root@$SERVER_IP_ADDRESS -i $DO_KEY USERNAME="$USERNAME" 'bash -s' < ./scripts/bring-in-vim.sh

# Run home creation - install things and bring in dotfiles, vim plugins
# nvm, also gets pm2, express
# yadm hard clone
ssh $USERNAME@$SERVER_IP_ADDRESS -i $KEY_NAME USERNAME="$USERNAME" 'bash -s' < ./scripts/homemaker.sh

# === System restart ===
# Run a system restart (required cause of aufs)
./scripts/restart-and-catch.sh
