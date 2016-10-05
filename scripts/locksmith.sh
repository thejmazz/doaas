#!/bin/bash

# Script for setting up keys following blockname_hostname_username_rsa formatting

CAN_SKIP=true
if [ -z "$APPEND_TO_SSH_CONFIG" ]; then
    export APPEND_TO_SSH_CONFIG=false
fi

if [ -z "$SERVER_IP_ADDRESS" ]; then
    CAN_SKIP=false
    echo Server IP address:
    read SERVER_IP_ADDRESS
fi

if [ -z "$USERNAME" ]; then
    CAN_SKIP=false
    echo Desired username:
    read USERNAME
fi

if [ -z "$BLOCKNAME" ]; then
    CAN_SKIP=false
    echo "SSH Config block name (will be used like 'ssh $blockname')"
    read BLOCKNAME
fi

printf "You entered:\n\nSERVER_IP_ADDRESS: %s\nUSERNAME: %s\nBLOCKNAME: %s\n" "$SERVER_IP_ADDRESS" "$USERNAME" "$BLOCKNAME"

if [ "$CAN_SKIP" = false ]; then
    while true; do
        read -p "Continue? (Yn) " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
fi


export KEY_NAME="$HOME/.ssh/${BLOCKNAME}_${SERVER_IP_ADDRESS}_${USERNAME}_rsa"

ssh-keygen -t rsa -f $KEY_NAME

export SSH_CONFIG=$(printf "Host %s\n\tHostname %s\n\tUser %s\n\tIdentityFile %s" "$BLOCKNAME" "$SERVER_IP_ADDRESS" "$USERNAME" "$KEY_NAME")

printf "\nSSH Config:\n%s\n" "$SSH_CONFIG"

if [ "$APPEND_TO_SSH_CONFIG" = false ]; then
    while true; do
        read -p "Append to ~/.ssh/config? (Yn) " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
fi

printf "\n%s\n" "$SSH_CONFIG" >> ~/.ssh/config
