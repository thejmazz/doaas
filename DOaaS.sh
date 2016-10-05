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

# Update
# ssh root@$SERVER_IP_ADDRESS -i $DO_KEY 'bash -s' "apt-get update -y"

# Run user setup script over ssh as root
ssh root@$SERVER_IP_ADDRESS -i $DO_KEY USERNAME="$USERNAME" "PUBKEY=\"$PUBKEY\"" 'bash -s' < ./scripts/setupuser.sh

# Install docker as root. Additionally, add $USERNAME to docker group
ssh root@$SERVER_IP_ADDRESS -i $DO_KEY USERNAME="$USERNAME" 'bash -s' < ./scripts/docker-ubuntu.sh

# Bring in vim to user's home
ssh root@$SERVER_IP_ADDRESS -i $DO_KEY USERNAME="$USERNAME" 'bash -s' < ./scripts/bring-in-vim.sh

# Run home creation - install things and bring in dotfiles, vim plugins
ssh $USERNAME@$SERVER_IP_ADDRESS -i $KEY_NAME USERNAME="$USERNAME" 'bash -s' < ./scripts/homemaker.sh

