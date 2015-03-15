# pimp-my-box

![logo](https://raw.githubusercontent.com/pyroscope/pimp-my-box/master/images/pimp-my-box.png)

Automated install of rTorrent-PS etc. via
[Ansible](http://docs.ansible.com/).


## Introduction

Ansible is a tool that allows you to install a complete setup remotely on one or any number of *target hosts*,
from the comfort of your own workstation.
The setup is described in so called *playbooks*,
before executing them you just have to add a few values like the name of your target.

The playbooks contained in this repository install the following components:

* [rTorrent-PS](https://github.com/pyroscope/rtorrent-ps#rtorrent-ps)
* [PyroScope](https://code.google.com/p/pyroscope/) command line tools

Each includes a default configuration, so you end up with a fully working system.

The Ansible playbooks and related commands have been tested on Debian Wheezy, Ubuntu Trusty, and Ubuntu Lucid.
They should work on other platforms too, especially when they're Debian derivatives, but you might have to make some modifications.

If you have questions or need help, please use
the [pyroscope-users](http://groups.google.com/group/pyroscope-users) mailing list
or the inofficial ``##rtorrent`` channel on ``irc.freenode.net``.


## Installing Ansible

Ansible has to be installed on the workstation from where you control your target hosts.
See the [Ansible documentation](http://docs.ansible.com/intro_installation.html)
for how to install it using the package manager of your platform.

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

To get it running on Windows is also possible,
by [using CygWin](https://servercheck.in/blog/running-ansible-within-windows)
(untested, success stories welcome).


## Checking Out the Code

To work with the playbooks, you of course need a local copy.
Unsurprisingly, you also need ``git`` installed for this.

```sh
which git || sudo apt-get install git
mkdir ~/src; cd ~/src
git clone "https://github.com/pyroscope/pimp-my-box.git"
cd "pimp-my-box"
```


## Setting Up Your Environment

Now with Ansible installed and having local working directory, you next need to configure the target host.
This can either be added to ``/etc/ansible/hosts``, or else  via a ``hosts`` file in your working directory.
The ``hosts-example`` file shows how this has to look like, enter the name of your target instead of ``box.example.com``.


```ini
[box]
box.example.com
```

Next, we check your setup and that Ansible is able to connect to the target and do its job there.
Call the command as shown after the ``$``, and it should print what OS you have installed, like shown in the example.

```sh
$ ansible box -m setup -a "filter=*distribution*"
box.example.com | success >> {
    "ansible_facts": {
        "ansible_distribution": "Debian",
        "ansible_distribution_major_version": "7",
        "ansible_distribution_release": "wheezy",
        "ansible_distribution_version": "7.8"
    },
    "changed": false
}
```

If anything goes wrong, add ``-vvvv`` to the ``ansible`` command.


## Running the Playbook

To execute the playbook, call either ``ansible-playbook site.yml`` with a configuration in ``/etc``,
or else ``ansible-playbook -i hosts site.yml``.
If you added more than one host into the ``box`` group and want to only address one of them,
use ``ansible-playbook -l ‹hostname› site.yml``.
Add ``-v`` to get more detailed information on what each action does.


## References

### Server Hardening

 * [Secure Secure Shell](https://stribika.github.io/2015/01/04/secure-secure-shell.html)
