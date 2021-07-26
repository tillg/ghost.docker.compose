# Multipass Cheatsheet

I use [Multipass](https://multipass.run) for testing my Ansible scripts, as it worked best for me (easier to use than VirtualBox).

### Install
```bash
# Installing Multipass on a Mac with brew
brew install --cask multipass
```

For other plattforms and other ways to install see [here](https://multipass.run/docs/installing-on-macos)

### Once running


```bash

# Check what networks we have
multipass networks

# Launch an instance that is attached to a network
multipass launch --network en0   # on my Mac that's the Wifi
# or
multipass launch --network bridge0   # on my Mac that's the cable

# Check which VMs are running, incl their IPs
multipass list

# Attach to a running VM
multipass shell <name>

# Stop a running instance
multipass top <name>
```

The [Multipass docs](https://multipass.run/docs) are pretty straight forward too.