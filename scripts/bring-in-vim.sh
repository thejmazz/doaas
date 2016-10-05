#!/bin/bash

# Expects
# - USERNAME
# to be set.

# Bring in vim from a prebuilt container. This is a bit involved with regards to
# directory ownership, since container user has a different uid. So this script
# needs to be run as root for sudo ops on chown.

export VIM_VOLUME_DIR=/home/$USERNAME/vim-volume
export CONTAINER_USER_UID=998

# Make a dir to use for volume mount and OWN IT with container user's uid
mkdir $VIM_VOLUME_DIR
chown $CONTAINER_USER_UID:$CONTAINER_USER_UID $VIM_VOLUME_DIR
# Copy out ~/.vim into the volume mounted dir
docker run --rm -v $VIM_VOLUME_DIR:/home/vim/work thejmazz/vim bash -c "cp -r ../.vim ."
# Copy from volume mounted dir to ~
cp -r $VIM_VOLUME_DIR/.vim /home/$USERNAME && rm -rf $VIM_VOLUME_DIR
# Change ~/.vim ownership to user, not root
chown -R $USERNAME:$USERNAME /home/$USERNAME/.vim

