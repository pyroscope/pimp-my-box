# pimp-my-box

![logo](https://raw.githubusercontent.com/pyroscope/pimp-my-box/master/images/pimp-my-box.png)
[![issues](https://img.shields.io/github/issues/pyroscope/pimp-my-box.svg)](https://github.com/pyroscope/pimp-my-box/issues)
[![travis](https://api.travis-ci.org/pyroscope/pimp-my-box.svg)](https://travis-ci.org/pyroscope/pimp-my-box)

Automated install of rTorrent-PS etc. via
[Ansible](http://docs.ansible.com/).


## Introduction

Ansible is a tool that allows you to install a complete setup remotely on one or any number of *target hosts*,
from the comfort of your own workstation.
The setup is described in so called *playbooks*,
before executing them you just have to add a few values like the name of your target host.

The playbooks contained in this repository install the following components:

* Security hardening of your server.
* [rTorrent-PS](https://github.com/pyroscope/rtorrent-ps#rtorrent-ps) with UI enhancements, colorization, and some added features.
* [PyroScope](https://code.google.com/p/pyroscope/) command line tools for rTorrent automation.

Optionally:

* [FlexGet](http://flexget.com/), the best feed reader and download automation tool there is.
* [ruTorrent](https://github.com/Novik/ruTorrent) web UI, served by [Nginx](http://wiki.nginx.org/) over HTTPS and run by PHP5-FPM.

Each includes a default configuration, so you end up with a fully working system.

The Ansible playbooks and related commands have been tested on Debian Jessie, Ubuntu Trusty, and Ubuntu Lucid
– the recommended distribution is Ubuntu Server LTS 64bit (i.e. release 14.04 at the time of this writing).
They should work on other platforms too, especially when they're Debian derivatives, but you might have to make some modifications.
Files are mostly installed into the user accounts `rtorrent` and `rutorrent`,
and only a few global configuration files are affected. If you run this against a host
with an existing installation, make sure that there are no conflicts.

If you have questions or need help, please use
the [pyroscope-users](http://groups.google.com/group/pyroscope-users) mailing list
or the inofficial ``##rtorrent`` channel on ``irc.freenode.net``.


## How to Use This?

Here's the steps you need to follow to get a working installation on your target host.
Note that this cannot be an Ansible or Linux shell 101, so for details refer to
the usual sources
like [The Debian Administrator's Handbook](http://debian-handbook.info/browse/stable/),
[The Linux Command Line](http://linuxcommand.org/tlcl.php),
and the [Ansible Documentation](http://docs.ansible.com/#ansible-documentation).


### Installing Ansible

Ansible has to be installed on the workstation from where you control your target hosts.
See the [Ansible Documentation](http://docs.ansible.com/intro_installation.html)
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

test -f ~/.ansible.cfg || cat >~/.ansible.cfg <<'EOF'
remote_tmp      = $HOME/.ansible/tmp
roles_path      = $HOME/.ansible/roles:/etc/ansible/roles
EOF
```

To get it running on Windows is also possible,
by [using CygWin](https://servercheck.in/blog/running-ansible-within-windows)
(untested, success stories welcome).


### Checking Out the Code

To work with the playbooks, you of course need a local copy.
Unsurprisingly, you also need ``git`` installed for this.

```sh
which git || sudo apt-get install git
mkdir ~/src; cd ~/src
git clone "https://github.com/pyroscope/pimp-my-box.git"
cd "pimp-my-box"
```


### Setting Up Your Environment

Now with Ansible installed and having a local working directory,
you next need to configure the target host
via a ``hosts`` file in your working directory (the so-called *inventory*).
The ``hosts-example`` file shows how this has to look like,
enter the name of your target instead of ``my-box.example.com``.


```ini
[box]
my-box.example.com
```

Next, we check your setup and that Ansible is able to connect to the target and do its job there.
Make sure you have working SSH access based on a pubkey login first (see
[here](https://www.digitalocean.com/community/tutorials/ssh-essentials-working-with-ssh-servers-clients-and-keys)).
Otherwise, use `--ask-pass` in combination with a password login
– for any details with this, consult the Ansible documentation.

Then call the command as shown after the ``$``,
and it should print what OS you have installed,
like shown in the example.

```sh
$ ansible my-box.example.com -i hosts -m setup -a "filter=*distribution*"
my-box.example.com | success >> {
    "ansible_facts": {
        "ansible_distribution": "Debian",
        "ansible_distribution_major_version": "7",
        "ansible_distribution_release": "wheezy",
        "ansible_distribution_version": "7.8"
    },
    "changed": false
}
```

If anything goes wrong, add ``-vvvv`` to the ``ansible`` command for more diagnostics,
and also check your `~/.ssh/config` and the Ansible connection settings in your `host_vars`.

Here is an example `~/.ssh/config` snippet:

```ini
Host rpi
    HostName 192.168.1.2
    User pi
    IdentityFile ~/.ssh/id_rsa
    IdentitiesOnly yes
    # The following is unsecure, for a Raspberry PI it allows easy card swapping...
    CheckHostIP no
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no
```

And these are example host variables in `host_vars/rpi/main.yml` (remember changing `rpi` to your hostname):

```ini
box_ipv4: 192.168.1.2
ansible_ssh_host: "{{ box_ipv4 }}"
ansible_ssh_port: 22
ansible_ssh_user: pi
ansible_ssh_private_key_file: ~/.ssh/id_rsa
ansible_sudo: true

rt_global_up_rate_kb: 50
rt_global_down_rate_kb: 500
rt_pieces_memory: 500M

flexget_enabled: yes
rutorrent_enabled: no
```

This works with a default *Raspberry Pi* setup which has a password-less sudo account,
normally you'd add `ansible_sudo_pass` in `host_vars/my-box/secrets.yml`, or else use
`-K` on the command line to prompt for the password.


### Running the Playbook

To execute the playbook, call ``ansible-playbook -i hosts site.yml``.
If you added more than one host into the ``box`` group and want to only address one of them,
use ``ansible-playbook -i hosts -l ‹hostname› site.yml``.
Add (multiple) ``-v`` to get more detailed information on what each task does.

Note that at the moment, you still need to additionally download and install (`dpkg -i`)
the `rtorrent-ps` Debian package as found on
[Bintray](https://bintray.com/pyroscope/rtorrent-ps/rtorrent-ps#files).
Choose one that fits the distribution of your target host, e.g. current *Mint*
is based on *Ubuntu 14.04 LTS*. Or compile a binary yourself.

Also, the SSL certificate generation is not fully automatic yet, run the command shown in
the error message you'll get, as `root` in the `/etc/nginx/ssl` directory – once the
certificate is created, re-run the playbook and it should progress beyond that point.
Of course, you can also copy a certificate you got from other sources to the paths
`/etc/nginx/ssl/cert.key` and `/etc/nginx/ssl/cert.pem`.
See [this blog post](https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html)
if you want *excessive* detail on secure HTTPS setups.


### Starting rTorrent

As mentione before, after successfully running the Ansible playbook, a fully configured
setup is found on the target. So to start rTorrent, call this command as the `rtorrent` user:

```sh
tmux -2u new -n rT-PS -s rtorrent "~/rtorrent/start; exec bash"
```

To detach from this session (meaning rTorrent continues to run), press `Ctrl-a` followed by `d`.


### Activating Firewall Rules

If you want to set up firewall rules using the
[Uncomplicated Firewall](https://en.wikipedia.org/wiki/Uncomplicated_Firewall) (UFW) tool,
then call the playbook using this command:

```sh
# See above regarding adding '-i' and '-l' options
ansible-playbook -i hosts site.yml -t ufw -e ufw=true
```

This will install the `ufw` package if missing, and set up all rules needed by apps installed
using this project. Note that activating the firewall is left as a manual task, since you can
make a remote server pretty much unusable when SSH connections get disabled by accident – only
a rescue mode or virtual console can help to avoid a full reinstall then, if you have no
physical access to the machine.

So to activate the firewall rules, use this in a `root` shell on the *target host*:

```sh
egrep 'ssh|22' /lib/ufw/user.rules
# Make sure the output contains
#   ### tuple ### limit tcp 22 0.0.0.0/0 any 0.0.0.0/0 in
# followed by 3 lines starting with '-A'.

ufw enable  # activate the firewall
ufw status verbose  # show all the settings
```


### Changing Configuration Defaults

Once created, the file `rtorrent.rc` is only overwritten when you provide
`-e force_cfg=yes` on the Ansible command line, and `_rtlocal.rc` is never
overwritten.
This gives you the opportunity to easily refresh the main configuration from
this repository, while still being able to provide your own version from
a custom playbook (which you then have to merge with changes made to the master
in this repo).


### Enabling Optional Applications

To activate the optional applications, add these settings to your `host_vars`:

 * `flexget_enabled: yes` for FlexGet.
 * `rutorrent_enabled: yes` for ruTorrent (see below for details).

Then run the playbook again.

FlexGet is just installed ready to be used, for full operation a configuration file
(see the [cookbook](http://flexget.com/wiki/Cookbook)) and a cronjob must be added.

ruTorrent, if enabled, is available at `https://my-box.example.com/rutorrent/`.


### Installing and Updating ruTorrent

The ruTorrent web UI is an optional add-on, and you have to activate it by setting
`rutorrent_enabled` to `yes` and providing a `rutorrent_www_pass` value, usually in
your `host_vars/my-box/main.yml` and `host_vars/my-box/secrets.yml` files, respectively.

To update to a new version of ruTorrent, first add the desired version as
`rutorrent_version` to your variables – that version has to be available on
[Bintray](https://bintray.com/novik65/generic/ruTorrent#files).
Then move the old installation tree away:

```sh
cd ~rutorrent
mv ruTorrent-master _ruTorrent-master-$(date "+%Y-%m-%d-%H%M").bak
tar cfz _profile-$(date "+%Y-%m-%d-%H%M").bak profile
```

Finally, rerun the playbook to install the new version. In case anything goes wrong,
you can move back that backup.


## Advanced Configuration

### Using the System Python Interpreter

By default, Python 2.7.10 is installed because that version handles SSL connections
according to current security standards; the version installed in your system often
does not. This has an impact on e.g. FlexGet's handling of ``https`` feeds.

If you want to use the system's Python interpreter, add these variables to your host vars:

```ini
pyenv_enabled: false
python_bin: /usr/bin/python2
venv_bin: /usr/bin/virtualenv
```


### Using the bash Completion Handler

The default configuration adds a *finished* event handler that calls the `~rtorrent/bin/_event.download.finished` script.
That script in turn just calls any existing `_event.download.finished-*.sh` script,
which allows you to easily add custom completion behaviour via your own playbooks.
The passed parameters are `hash`, `name`, and `base_path`;
the completion handler ensures the session state is flushed,
so you can confidently read the session files associated with the provided hash.

Here is an example `~/bin/_event.download.finished-jenkins.sh`
that triggers a Jenkins job for any completed item:

```sh
#! /bin/bash
#
# Called in rTorrent event handler

set -x

infohash="${1:?You MUST provide the infohash of the completed item!}"
url="http://localhost:8080/job/event.download.finished/build?delay=0sec"
json="$(python -c "import json; print json.dumps(dict(parameter=dict(name='INFOHASH', value='$infohash')))")"

http --ignore-stdin --form POST "$url" token=C0mpl3t3 json="$json"
```

You need to add the related `event.download.finished` job
and `rtorrent` user to Jenkins of course.
The user's credentials must be added to `~rtorrent/.netrc`, like this:

```sh
machine localhost
    login rtorrent
    password YOUR_PWD
```

Make sure to call `chmod 0600 ~/.netrc` after creating the file.
To check that everything is working, download something
and check the build history of your Jenkins job
– if nothing seems to happen, look into `~/rtorrent/log/execute.log` to debug.


### Extending the Nginx Site

The main Nginx server configuration includes any `/etc/nginx/conf.d/rutorrent-*.include`
files, so you can add your own locations in addition to the default `/rutorrent` one.
The main configuration file is located at `/etc/nginx/sites-available/rutorrent`.

Use a `/etc/nginx/conf.d/upstream-*.conf` file in case you need to add your own `upstream` definitions.


## References

### Server Hardening

 * [Secure Secure Shell](https://stribika.github.io/2015/01/04/secure-secure-shell.html)
 * https://github.com/sfromm/ansible-rkhunter
