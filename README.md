An atomic bootc image for my server based on fedora-bootc

Build a container image locally:

```bash
sudo just pull # (optional)
sudo just build
sudo just rechunk
```

Build an Anaconda installer ISO image:

```bash
sudo podman pull ghcr.io/teackot/srv:44
sudo just registry=ghcr.io/teackot image=srv tag=44 disk
```
