#!/bin/bash

# Expects
# - SERVER_IP_ADDRESS
# - USERNAME
# - KEY_NAME
# to be set.

# Install nvm. Gets sourced from .bashrc
export NVM_DIR=/home/$USERNAME/.nvm && (
  git clone https://github.com/creationix/nvm.git "$NVM_DIR"
  cd "$NVM_DIR"
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" origin`
) && . "$NVM_DIR/nvm.sh"

nvm install 6
npm install -g pm2 express

yadm clone https://github.com/thejmazz/dotfiles
yadm reset --hard HEAD

