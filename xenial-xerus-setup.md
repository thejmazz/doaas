# Jumping Into Serverland

So, you've been provided a `root` password and an `$IP`. After `ssh root@$IP`, you are greeted,

```
Welcome to Ubuntu 16.04.1 LTS (GNU/Linux 2.6.32-042stab120.16 x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.
```

Now what? We are inside a VM running inside a physical host somewhere on the planet, which has been granted 
a public facing IP. You can verify how you look to the outside world with `wget -qO - icanhazip.com`.

First steps: we need to secure the machine. Sure, we can already start downloading and installing software,
but it is better to do so as user. Furthermore, we should disable login via a password and only allow keys.
This ensures that you have a local file (key) that no one else does and that this is the only way to get shell access
to the machine. 

So, *on your client machine*, generate a private and public RSA key pair:

```
ssh-keygen -t rsa -f ~/.ssh/secret-key_rsa
```

Then on the server, create a user. The `--gecos ""` skips asking for the [Gecos field](https://en.wikipedia.org/wiki/Gecos_field); else you can skip through or enter these values.

```
adduser --gecos "" $USERNAME
```

Then add the user to the `sudo` group:

```
usermod -aG sudo $USERNAME
```

This enables sudo abilities because of what is written in `/etc/sudoers` concerning the *group* `sudo`:

```
$ cat /etc/sudoers | grep -B 1 %sudo
# Allow members of group sudo to execute any command
%sudo   ALL=(ALL:ALL) ALL
```

You can double check your user is in the group with `groups $USERNAME`.

Then, *back on your client machine*, you can use `ssh-copy-id` to bring in your public key and set all the proper
permissions on `~/.ssh` and `~/.ssh/authorized_keys` (you may need to `ssh-add ~/.ssh/yourkey_rsa` if it does not match the
`default_ID_file`):

```
ssh-copy-id username@$IP
```

What this is doing behind the scenes is something along the lines of:

```
mkdir /home/$USERNAME/.ssh
chmod 700 /home/$USERNAME/.ssh
# Add public key to authorized_keys
echo "$PUBKEY" >> /home/$USERNAME/.ssh/authorized_keys
chmod 600 /home/$USERNAME/.ssh/authorized_keys
chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
```

You can `cat /home/$USERNAME/.ssh/authorized_keys` to see that it contains your public key at `~/.ssh/your-key_rsa.pub`.

Great! Now we can log in to our server as our new user. We could now do `ssh user@$IP` and fill in the password, but we are going to disable password login anyways and have already set up our keys. With a little bit of `~/.ssh/config` we can make
it even easier:

```
Host blockname
        Hostname $IP
        User $USERNAME
        IdentityFile /Users/jmazz/.ssh/secret-key_rsa
```

After this, we can `ssh $blockname` with whatever we chose for the config block name. This is great if you log into
a bunch of different hosts, as even thoug the service will run over all your keys when trying to log in somewhere,
it may get rejected after some attempts before even reaching the correct key. You could also use `ssh -i` to specify
the identity file.

Once you are logged in (with the key not password) it is safe to disable password login. This is recommended as it prevents
brute force attacks. As an extra measure, you may also want to disable root login as this is still using a password and we are not going to set up a key for root. For this we edit some values in `/etc/ssh/sshd_config`. You can either edit the files manually using
a text editor like `nano` or `vim` or run the following `sed` commands:

```
sudo sed -i -E 's/^#?PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sudo sed -i -E 's/^#?PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
```

You will then need to tell the `sshd` (SSH Daemon) program to reload its configuration. `systemctl` is used to manage a bunch of daemons, startup processes and their orders.

```
sudo systemctl reload sshd
```

DON'T LOG OUT YET! Log in from another terminal locally just to make sure you can still get in. If your key is correct and had its public key added to the `authorized_keys` file you will be fine.

Insall these so you lose ssh connection nicer on restart (see [this](http://serverfault.com/questions/706475/ssh-sessions-hang-on-shutdown-reboot/706494#706494)):
```
apt-get install libpam-systemd dbus
```

HTTPS and certs + apt
```
apt-get install apt-transport-https ca-certificates software-properties-common -y
```

