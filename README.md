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

#### Known issues

##### `systemd-remount-fs.service` fails on boot

Happens because Anaconda adds an fstab entry for `/`. Tracked here: https://github.com/bootc-dev/bootc/issues/971

To fix simply remove the `/` entry from fstab

### Method 2: from within an existing VPS

This can be useful if your VPS provider doesn't allow installing custom operating systems.

1. Boot into an existing system
2. Add an ssh key to any user. It will be used later to ssh into your root account
3. Install `system-reinstall-bootc`: `sudo dnf install system-reinstall-bootc`
4. Pull the image: `sudo podman pull ghcr.io/teackot/srv:44`
5. Install the system: `sudo system-reinstall-bootc ghcr.io/teackot/srv:44`
6. Answer all prompts, then wait for the installation process to finish and reboot
7. ssh into the root account of the new system and configure it
