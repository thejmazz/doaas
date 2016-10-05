#!/bin/bash

# Expects
# - SERVER_IP_ADDRESS
# - DO_KEY
# - USERNAME
# - PUBKEY
# to be set.

sed -i -E 's/^#?PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
echo "Disabled password login (see /etc/ssh/sshd_config)"

# sed -i -E 's/^#?PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
# echo "Disabled remote root login"

# Reload sshd_config
sudo systemctl reload sshd

# No prompt for password but can login via ssh key
adduser --disabled-password --gecos "" $USERNAME
echo "Created user $USERNAME"

# Set a default password (this isn't a security issue since we only allow key logins)
echo "$USERNAME:password" | chpasswd

usermod -aG sudo $USERNAME
echo "Added $USERNAME to sudoers"

# Force passwd to be set next login
# chage -d 0 $USERNAME

# Make ~/.ssh for new user with proper permissions
mkdir /home/$USERNAME/.ssh
chmod 700 /home/$USERNAME/.ssh
# Add public key to authorized_keys
echo "$PUBKEY" >> /home/$USERNAME/.ssh/authorized_keys
chmod 600 /home/$USERNAME/.ssh/authorized_keys
chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh

echo "Added public key to authorized_keys"

curl -sfLo /usr/local/bin/yadm https://github.com/TheLocehiliosan/yadm/raw/master/yadm
chmod a+x /usr/local/bin/yadm
echo "Installed yadm"

apt-get install build-essential cmake python-dev python3-dev -y
echo "Installed a bunch of stuff"
