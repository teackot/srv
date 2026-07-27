An atomic system which allows you to set up a proxy server with a management panel

This is a *mostly* preconfigured atomic bootc image which ships all necessary
tools to set up a proxy server with PasarGuard.

## Build

To build a container image locally:

```bash
just pull
just build
```

## Install

### Method 1: directly with Anaconda

Build an interactive Anaconda installer ISO image:

```bash
just prepare_interactive
sudo podman pull ghcr.io/teackot/srv:44
sudo just registry=ghcr.io/teackot image=srv tag=44 disk
```

Build an unattended Anaconda installer ISO image (installs to the first disk found):

```bash
just prepare_unattended user defaultpassword "ssh-ed25519 abcdef123456..."
sudo podman pull ghcr.io/teackot/srv:44
sudo just registry=ghcr.io/teackot image=srv tag=44 disk_type=anaconda-iso disk
```

### Method 2: from within an existing VPS

This can be useful if your VPS provider doesn't allow installing custom operating systems.

1. Boot into an existing system
2. Add an ssh key to any user. It will be used later to ssh into your root account
3. Install `system-reinstall-bootc`: `sudo dnf install system-reinstall-bootc`
4. Pull the image: `sudo podman pull ghcr.io/teackot/srv:44`
5. Install the system: `sudo system-reinstall-bootc ghcr.io/teackot/srv:44`
6. Answer all prompts, then wait for the installation process to finish and reboot
7. ssh into the root account of the new system and configure it

## Post-install steps

### 1. Create a user (if not created during installation)

Important: this image assumes that `uid=1000` and `gid=1000`

```bash
sudo useradd -m -G wheel -u 1000 -g 1000 user
```

### 2. Copy your ssh key

For example (on a local machine):

```bash
ssh-copy-id -i .ssh/key.pub -p 1022 user@ip-address
```

### 3. Secure the sshd configuration

Remove the default insecure config:

```bash
sudo rm /etc/ssh/sshd_config.d/10-REMOVEME_allow_password_auth.conf
```

If installed using `system-reinstall-bootc`, remove the root ssh keys:

```bash
sudo rm /etc/tmpfiles.d/bootc-root-ssh.conf /root/.ssh/authorized_keys
```

Restart sshd:

```bash
sudo systemctl restart sshd.service
```

### 4. Upgrade the system

If installed with Anaconda:

```bash
sudo bootc upgrade --apply
```

If installed with `system-reinstall-bootc` (this command also switches you to a signed image for increased security):

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/teackot/srv:44 --apply
```

## Known issues

### `systemd-remount-fs.service` fails on boot

Happens because Anaconda adds an fstab entry for `/`. Tracked here: https://github.com/bootc-dev/bootc/issues/971

To fix simply remove the `/` entry from fstab
