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
but its better to do so as user. Furthermore, we should disable login via a password and only allow keys.
This ensures that you can have a locale file (key) that no one else does be the only way to get shell access
to the machine. 
