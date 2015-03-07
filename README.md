# pimp-my-box

![logo](https://raw.githubusercontent.com/pyroscope/pimp-my-box/master/images/pimp-my-box.png)

Automated install of rTorrent-PS etc. via
[Ansible](http://docs.ansible.com/).


## Introduction

**TODO**

The Ansible playbooks and related commands have been tested on Debian Wheezy, Ubuntu Trusty, and Ubuntu Lucid.
They should work on other platforms too, especially when they're Debian derivatives, but you might have to make some modifications.


## Installing Ansible

**TODO** Package install

Another way to install Ansible is to put it into your home directory.
The following commands just require Python to be installed to your system,
and the installation is easy to get rid of (everything is contained within a single directory).

```sh
# just to make sure you have what you need
sudo apt-get install build-essential python-virtualenv python-dev

base="$HOME/.local/venvs"
mkdir -p "$base" "$HOME/bin"
/usr/bin/virtualenv "$base/ansible"
cd "$base/ansible"
bin/pip install "ansible"
ln -s "$PWD/bin"/ansible* "$HOME/bin"
ansible --version
```
