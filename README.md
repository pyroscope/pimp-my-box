# pimp-my-box

![logo](https://raw.githubusercontent.com/pyroscope/pimp-my-box/master/images/pimp-my-box.png)
[![issues](https://img.shields.io/github/issues/pyroscope/pimp-my-box.svg)](https://github.com/pyroscope/pimp-my-box/issues)
[![travis](https://api.travis-ci.org/pyroscope/pimp-my-box.svg)](https://travis-ci.org/pyroscope/pimp-my-box)

Automated install of rTorrent-PS etc. via
[Ansible](http://docs.ansible.com/).

**Contents**

  * [Introduction](#introduction)
  * [How to Use This?](#how-to-use-this)
    * [Checking Out the Code](#checking-out-the-code)
    * [Installing Ansible](#installing-ansible)
    * [Providing SSH Access for Ansible](#providing-ssh-access-for-ansible)
    * [Setting Up Your Environment](#setting-up-your-environment)
    * [Running the Playbook](#running-the-playbook)
    * [Starting rTorrent](#starting-rtorrent)
    * [Activating Firewall Rules](#activating-firewall-rules)
    * [Changing Configuration Defaults](#changing-configuration-defaults)
    * [Enabling Optional Applications](#enabling-optional-applications)
    * [Installing FlexGet](#installing-flexget)
    * [Installing and Updating ruTorrent](#installing-and-updating-rutorrent)
  * [Using Ansible for Remote Management](#using-ansible-for-remote-management)
  * [Advanced Configuration](#advanced-configuration)
    * [Using the System Python Interpreter](#using-the-system-python-interpreter)
    * [Upgrading to a Newer Python Version](#upgrading-to-a-newer-python-version)
    * [Upgrading to a Newer rTorrent-PS Version](#upgrading-to-a-newer-rtorrent-ps-version)
    * [Using the bash Download Completion Handler](#using-the-bash-download-completion-handler)
    * [Extending the Nginx Site](#extending-the-nginx-site)
  * [Trouble-Shooting](#trouble-shooting)
    * [SSH Error: Host key verification failed](#ssh-error-host-key-verification-failed)
  * [Implementation Details](#implementation-details)
    * [Location of Configuration Files](#location-of-configuration-files)
    * [Location of Installed Software](#location-of-installed-software)
    * [Secure Communications](#secure-communications)
  * [References](#references)
    * [Server Hardening](#server-hardening)


## Introduction

The software in this repository will install ``rTorrent-PS``, ``pyrocore``, and related software
onto any remote dedicated server or VPS with ``root`` access, running Debian or a Debian-like OS.

``Ansible`` is used to describe the installation process.
It is a tool that allows you to perform a complete setup remotely
on one or any number of *target hosts*,
from the comfort of your own workstation.
The setup is described in so called *playbooks*,
before executing them you just have to add a few values like the name of your target host.
This is in many ways superior to the usual
*“call a bash script to set up things once and never be able to update them again”*,
since you can run this setup repeatedly to either fix problems,
or to install upgrades and new features added to this repository.

The playbooks contained in here install the following components:

* Security hardening of your server.
* [rTorrent-PS](https://github.com/pyroscope/rtorrent-ps#rtorrent-ps) with UI enhancements, colorization, and some added features.
* PyroScope [command line tools](https://github.com/pyroscope/pyrocore#pyrocore) (pyrocore) for rTorrent automation.

Optionally:

* [FlexGet](http://flexget.com/), the best feed reader and download automation tool there is.
* [ruTorrent](https://github.com/Novik/ruTorrent) web UI, served by [Nginx](http://wiki.nginx.org/) over HTTPS and run by PHP5-FPM.

Each includes a default configuration, so you end up with a fully working system.

The Ansible playbooks and related commands have been tested on Debian Jessie, Ubuntu Xenial, and Ubuntu Trusty
– the recommended distribution is Ubuntu Server LTS 64bit (i.e. release 16.04 at the time of this writing,
unless you want to use rutorrent, then for now go back to 14.04 or use Debian Jessie).
They should work on other platforms too, especially when they're Debian derivatives, but you might have to make some modifications.
Files are mostly installed into the user accounts `rtorrent` and `rutorrent`,
and only a few global configuration files are affected. If you run this against a host
with an existing installation, make sure that there are no conflicts.

If you have questions or need help, please use
the [pyroscope-users](http://groups.google.com/group/pyroscope-users) mailing list
or the inofficial ``##rtorrent`` channel on ``irc.freenode.net``.


## How to Use This?

Here's the steps you need to follow to get a working installation on your target host.
This might seem like an arduous process, but if you're accustomed to a *Linux* command prompt
and ideally also *Ansbile*, it boils down to these steps:

 * Create your working directory.
 * Call Ansible installer script, if you don't have it available yet.
 * Enable a SSH sudo account on your deployment target.
 * Create and edit two Ansible config files.
 * Run the playbook and wait a bit.
 * Enjoy your working and secure seedbox.

And once you got it working, moving to or adding another machine is easy and almost no work,
just add that host and run the playbooks for it.

Note that this cannot be an Ansible or Linux shell 101, so if these topics are new for you
refer to the usual sources like
[The Debian Administrator's Handbook](http://debian-handbook.info/browse/stable/),
[The Linux Command Line](http://linuxcommand.org/tlcl.php)
and [The Art of Command Line](https://github.com/jlevy/the-art-of-command-line#the-art-of-command-line),
and the [Ansible Documentation](http://docs.ansible.com/#ansible-documentation).


### Checking Out the Code

To work with the playbooks, you of course need a local copy.
Unsurprisingly, you also need ``git`` installed for this, to create that local copy (a/k/a *clone*).

Executing these commands *on your workstation* takes care of that:

```sh
which git || sudo apt-get install git
mkdir ~/src; cd ~/src
git clone "https://github.com/pyroscope/pimp-my-box.git"
cd "pimp-my-box"
```


### Installing Ansible

Ansible **must** be installed on the workstation from where you control your target hosts.
This can also be the target host itself, if you don't have a Linux or Mac OSX desktop at hand.
In that case, use a personal account on that machine, or create an ``ansible`` one
– any part of the documentation that refers to ‘the workstation’ then means that account.

To get it running on Windows is also possible, by using
[Bash for Windows 10](http://www.jeffgeerling.com/blog/2017/using-ansible-through-windows-10s-subsystem-linux)
or [CygWin](https://servercheck.in/blog/running-ansible-within-windows) on older systems
(this is untested, success stories welcome).

See the [Ansible Documentation](http://docs.ansible.com/intro_installation.html)
for how to install it using the package manager of your platform.
Make sure you get the right version that way, the playbooks are tested using Ansible *1.9.6*,
and Ansible 2 might not work (yet).

The *recommended* way to install Ansible is to put it into your home directory.
The following commands just require Python to be installed to your system,
and the installation is easy to get rid of (everything is contained within a single directory).
When you have no ``~/.ansible.cfg`` yet (which you very likely do not),
one is added.

**Enter / copy+paste this command into a shell prompt on your workstation, within the 'pimp-my-box' directory!**

```sh
./scripts/install_ansible.sh
```


### Providing SSH Access for Ansible

For a dedicated server, the first step is to create an account *Ansible* can use to perform its work.
Log into your server as ``root`` and call these commands:

```sh
account=setup
groupadd $account
useradd -g $account -G $account,users -c "Ansible remote user" -s /bin/bash --create-home $account
eval chmod 0750 ~$account
passwd -l $account
```

Calling the following command as ``root`` on the *target host* will grant password-less sudo to the new account:

```sh
# Give password-less sudo permissions to the "setup" user
echo >/etc/sudoers.d/setup "setup ALL=(ALL) NOPASSWD:ALL"
```

In case you prefer password-protected sudo, leave out the ``NOPASSWD:``,
and also set a password using ``passwd setup``.

The ``setup`` account must allow login using the ``id_rsa`` key, or another key you create on your *workstation*.
See [here](https://www.digitalocean.com/community/tutorials/ssh-essentials-working-with-ssh-servers-clients-and-keys)
for establishing working SSH access based on a pubkey login, if you've never done that before.

Finally, the last snippet of SSH configuration goes into ``~/.ssh/config`` of your *workstation* account,
add these lines providing details on how to connect to your target host via SSH
(and replace the text in ``ALL_CAPS`` by the correct value):

```ini
Host my-box
    HostName IP_ADDRESS_OR_DOMAIN_OF_TARGET
    Port 22
    User setup
    IdentityFile ~/.ssh/id_rsa
    IdentitiesOnly yes
```

Now to test that you did everything right,
call the below ``ssh`` command on your *workstation*,
and verify that you get the output as shown:

```sh
$ ssh my-box "sudo id"
uid=0(root) gid=0(root) groups=0(root)
```

In case you're asked for a password, enter the one you've set on the ``setup`` account.


### Setting Up Your Environment

Now with Ansible installed and able to connect via SSH,
you next need to configure the target host (by default named ``my-box``)
and its specific attributes (the so-called *host vars*).
There is an example in
[host_vars/rpi/main.yml](https://github.com/pyroscope/pimp-my-box/blob/master/host_vars/rpi/main.yml)
for a default *Raspberry Pi* setup which is used a template.

To create the necessary files, call this command:

```sh
./scripts/add_host.sh
```

If you already have an Ansible inventory (i.e. ``hosts`` file),
your configured editor will open it – else a suitable default is created.
Make sure you add your target's name to the ``[box]`` group, if it's missing.

Next the editor will open with ``main.yml``,
fill in the values as described in the first few lines of the file.
In a final step, you need to enter the ``sudo`` password of your target server.

Afterwards, you have these files in your working directory: ``hosts``,
``host_vars/my-box/main.yml``, and ``host_vars/my-box/secrets.yml``.
If you don't understand what is done here, read the Ansible documentation again,
specifically the “Getting Started” page.

Now we can check your setup and that Ansible is able to connect to the target and do its job there.
For this, call the command as shown after the ``$``,
and it should print what OS you have installed on the target(s),
like shown in the example.

```sh
$ ansible box -i hosts -m setup -a "filter=*distribution*"
my-box | success >> {
    "ansible_facts": {
        "ansible_distribution": "Ubuntu",
        "ansible_distribution_major_version": "14",
        "ansible_distribution_release": "trusty",
        "ansible_distribution_version": "14.04"
    },
    "changed": false
}
```

If anything goes wrong, add ``-vvvv`` to the ``ansible`` command for more diagnostics,
and also check your `~/.ssh/config` and the Ansible connection settings in your `host_vars`.
If it's a connection problem, try to directly call ``ssh -vvvv my-box`` and if that succeeds,
also make sure you can become ``root`` via ``sudo su -``.
If not, read the resources linked at the start of the “How to Use This?” section, and especially the
[SSH Essentials](https://www.digitalocean.com/community/tutorials/ssh-essentials-working-with-ssh-servers-clients-and-keys).


### Running the Playbook

To execute the playbook, call ``ansible-playbook -i hosts site.yml``.

If your Linux release isn't supported with a pre-built package,
you'll see a message like the following:

    WARNING - No DEB package URL defined for '‹platform›',
    you need to install /opt/rtorrent manually!

In that case,
[compile a binary yourself](https://github.com/pyroscope/rtorrent-ps/blob/master/docs/DebianInstallFromSource.md#build-rtorrent-and-core-dependencies-from-source).

If you added more than one host into the ``box`` group and want to only address one of them,
use ``ansible-playbook -i hosts -l ‹hostname› site.yml``.
Add (multiple) ``-v`` to get more detailed information on what each task does.


### Starting rTorrent

As mentioned before, after successfully running the Ansible playbook, a fully configured
setup is found on the target. So to start rTorrent, call this command as the `rtorrent` user:

```sh
tmux -2u new -n rT-PS -s rtorrent "~/rtorrent/start; exec bash"
```

To detach from this session (meaning rTorrent continues to run), press `Ctrl-a` followed by `d`.

If you get ``rtorrent: command not found`` when calling above ``tmux`` command,
then a pre-built Debian package is not available for your OS distribution
and you need to build from source (see previous section).


### Activating Firewall Rules

If you want to set up firewall rules using the
[Uncomplicated Firewall](https://en.wikipedia.org/wiki/Uncomplicated_Firewall) (UFW) tool,
then call the playbook using this command:

```sh
# See above regarding adding the '-l' option to select a single host
ansible-playbook -i hosts site.yml -t ufw -e ufw=true
```

This will install the `ufw` package if missing, and set up all rules needed by apps installed
using this project. Note that activating the firewall is left as a manual task, since you can
make a remote server pretty much unusable when SSH connections get disabled by accident – only
a rescue mode or virtual console can help to avoid a full reinstall then, if you have no
physical access to the machine.

So to activate the firewall rules, use this in a `root` shell on the *target host*:

```sh
egrep 'ssh|22' /lib/ufw/user.rules /etc/ufw/user.rules
# Make sure the output contains
#   ### tuple ### limit tcp 22 0.0.0.0/0 any 0.0.0.0/0 in
# followed by 3 lines starting with '-A'.

ufw enable  # activate the firewall
ufw status verbose  # show all the settings
```


### Changing Configuration Defaults

A good way to provide customizations is writing your own playbooks.
Create a separate project in your own git repository.
In that project, you can provide your versions of existing files,
add your own helper scripts, and so on.
Model it after this repository, and consult the *Ansible* documentation.
You can reuse your inventory, by passing ``-i ../pimp-by-box/hosts``
to the playbook calls, or by setting the ``ANSIBLE_INVENTORY`` environment variable.

As described in this and the following sections, some key config
files are designed to be replaced in this way.
Just be aware that once you copy them, you also have to manage them yourself,
and merge with changes made to the master in this repo!

Once created, the file `rtorrent.rc` is only overwritten when you provide
`-e force_cfg=yes` on the Ansible command line, and `_rtlocal.rc` is never
overwritten.
This gives you the opportunity to easily refresh the main configuration
in ``rtorrent.rc`` from this repository, while still being able to safely provide
your own version of ``_rtlocal.rc`` from a custom playbook.
Or apply customizations manually, by editing ``~rtorrent/rtorrent/_rtlocal.rc``.

Another way to customize rTorrent is to use the ``~/rtorrent/rtorrent.d`` directory.
Just place any file with a ``.rc`` extension there, and it will be loaded on the next restart.
This is ideally suited for custom playbooks, which can just add new files
to extend the default configuration.

That directory also contains most of the extra rTorrent configuration that comes with ``pimp-my-box``.
For example, by default terminating rTorrent via ``^Q`` gets disabled in the ``disable-control-q.rc`` file,
replacing it by ``^X q=``, which you won't type by accident.

To restore the rTorrent default, run this command as the ``rtorrent`` user
(or put the line into that file via *Ansible*):

```sh
echo >>~/rtorrent/rtorrent.d/.rcignore "disable-control-q.rc"
```

Then restart rTorrent.


### Enabling Optional Applications

To activate the optional applications, add these settings to your `host_vars`:

 * `flexget_enabled: yes` for FlexGet.
 * `rutorrent_enabled: yes` for ruTorrent.

Read the following sections for details.


### Installing FlexGet

After setting `flexget_enabled: yes`, run the playbook again.

FlexGet is just installed ready to be used, for full operation a configuration file
located in `~/.config/flexget/config.yml` must be added
(see the [FlexGet cookbook](http://flexget.com/wiki/Cookbook)).
A cronjob is provided too (called every 11 minutes),
but only starts to actually call FlexGet
*after* you add that configuration file.
Look into the files `~/.config/flexget/flexget.log` and `~/.config/flexget/flexget-cron.log`
to diagnose any problems.


### Installing and Updating ruTorrent

The ruTorrent web UI is an optional add-on, and you have to activate it by setting
`rutorrent_enabled` to `yes` and providing a `rutorrent_www_pass` value, usually in
your `host_vars/my-box/main.yml` and `host_vars/my-box/secrets.yml` files, respectively.
Then run the playbook again.

Alternatively to the self-signed certificate that is created for Nginx,
you can also copy a certificate you got from other sources to the paths
`/etc/nginx/ssl/cert.key` and `/etc/nginx/ssl/cert.pem`.
See [this blog post](https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html)
if you want *excessive* detail on secure HTTPS setups.

After the second run, ruTorrent is available at `https://my-box.example.com/rutorrent/`
(use you own domain or IP in that URL).

To *update to a new version* of ruTorrent, first add the desired version as
`rutorrent_version` to your variables – that version has to be available on
[Bintray](https://bintray.com/novik65/generic/ruTorrent#files).
Then move the old installation tree away:

```sh
cd ~rutorrent
mv ruTorrent-master _ruTorrent-master-$(date "+%Y-%m-%d-%H%M").bak
tar cfz _profile-$(date "+%Y-%m-%d-%H%M").bak profile
```

Finally, rerun the playbook to install the new version. In case anything goes wrong,
you can move back that backup you made initially.


## Using Ansible for Remote Management

The setup work to get *Ansible* controlling your machines is not just for installing things,
you can also simplify daily management tasks.

Consider this example, which prints the number of items loaded into rTorrent,
for all hosts in your inventory:

```sh
$ ansible box -f4 --become-user=rtorrent -a "~/bin/rtxmlrpc view.size=,main" -o
my-box | success | rc=0 | (stdout) 42
my-box2 | success | rc=0 | (stdout) 123
```

Another example is updating the ``pyrocore`` installation from git, like this:

```sh
ansible box -f4 -a "sudo -i -u rtorrent -- ~rtorrent/lib/pyroscope/update-to-head.sh"
ansible box -f4 --become-user=rtorrent -a "~/bin/pyroadmin --version" -o
```

This is especially useful if you control more than one host.


## Advanced Configuration

### Using the System Python Interpreter

By default, Python 2.7.13 is installed because that version handles SSL connections
according to current security standards; the version installed in your system often
does not. This has an impact on e.g. FlexGet's handling of ``https`` feeds.

If you want to use the system's Python interpreter, add these variables to your host vars:

```ini
pyenv_enabled: false
python_bin: /usr/bin/python2
venv_bin: /usr/bin/virtualenv
```

:thumbsup: Doing so is recommended on both *Xenial* (has 2.7.12) and *Jessie* (has 2.7.9).


### Upgrading to a Newer Python Version

When you installed *Python* via *pyenv* (i.e. ``pyenv_enabled`` is still set to ``true``),
you can update to a new *Python* release by reinstalling the related software.
If you want to select a specific Python version,
set the ``pyenv_python_version`` variable in your ``host_vars`` or ``group_vars``.

You first have to remove the old install directory, and all virtualenvs based on it:

```sh
ansible box -i hosts -a "rm -rf ~rtorrent/.local/pyenv ~rtorrent/lib/pyroscope ~rtorrent/lib/flexget"
```

Then execute the relevant roles again:

```sh
ansible-playbook site.yml -i hosts -t pyenv,cli,fg
```

As given, these commands affect all hosts in the ``box`` group of your inventory.
Also, both ``pyrocore`` and ``flexget`` get upgraded to the newest available version.


### Upgrading to a Newer rTorrent-PS Version

To upgrade the installed ``rtorrent-ps`` package, execute this command on your workstation:

```sh
ansible box -a "rm /opt/rtorrent/version-info.sh" -i hosts
```

Then run the playbook to install the new version:

```sh
ansible-playbook site.yml -t rtps -i hosts
```

Finally connect to your ``tmux`` session, and stop & restart rTorrent.


### Using the bash Download Completion Handler


The default configuration adds a *finished* event handler that calls the `~rtorrent/bin/_event.download.finished` script.
That script in turn just calls any existing `_event.download.finished-*.sh` script,
which allows you to easily add custom completion behaviour via your own playbooks.

The passed parameters are `hash`, `name`, and `base_path`;
the completion handler ensures the session state is flushed,
so you can confidently read the session files associated with the provided hash.

Be aware that you cannot call back into rTorrent via XML-RPC within an event handler,
because that leads to a deadlock.
If you need to do that, call your script directly using ``execute.bg``
or one of its variants.
Alternatively detach yourself from the process that rTorrent created for the event,
so the event handler finishes as far as rTorrent is concerned.
In any of these cases, be aware that things run concurrently and can go horribly wrong,
if you don't care take of race conditions and such.

Here is a non-trivial example that goes to `~/bin/_event.download.finished-jenkins.sh`,
and triggers a [Jenkins](https://jenkins.io/) job for any completed item:

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

The fact that *Jenkins* runs in its own separate process means your job can make
free use of ``rtxmlrpc`` and ``rtcontrol`` to change things in *rTorrent*.


### Extending the Nginx Site

The main Nginx server configuration includes any `/etc/nginx/conf.d/rutorrent-*.include`
files, so you can add your own locations in addition to the default `/rutorrent` one.
The main configuration file is located at `/etc/nginx/sites-available/rutorrent`.

Use a `/etc/nginx/conf.d/upstream-*.conf` file in case you need to add your own `upstream` definitions.


## Trouble-Shooting

### SSH Error: Host key verification failed

If you get this error, one easy way out is to first enter the following command
and then repeat your failing Ansible command:

```sh
export ANSIBLE_HOST_KEY_CHECKING=False
```


## Implementation Details

### Location of Configuration Files

 * ``/home/rtorrent/rtorrent/rtorrent.rc`` – Main *rTorrent* configuration file; to update it from this repository use ``-e force_cfg=yes``, see above for details.
 * ``/home/rtorrent/rtorrent/_rtlocal.rc`` – *rTorrent* configuration include for custom modifications, this is *never* overwritten once it exists.
 * ``/home/rtorrent/.pyroscope/config.ini`` – ``pyrocore`` main configuration.
 * ``/home/rtorrent/.pyroscope/config.py`` – ``pyrocore`` custom field configuration.
 * ``/home/rtorrent/.config/flexget/config.yml`` – *FlexGet* configuration.
 * ``/home/rutorrent/ruTorrent-master/conf/config.php`` – *ruTorrent* configuration.
 * ``/home/rutorrent/profile/`` – Dynamic data written by *ruTorrent*.
 * ``/etc/nginx/sites-available/rutorrent`` – *NginX* configuration for the *ruTorrent* site.
 * ``/etc/php5/fpm/pool.d/rutorrent.conf`` or ``/etc/php/7.0/fpm/pool.d/rutorrent.conf`` – PHP worker pool for *ruTorrent*.


### Location of Installed Software

 * ``/home/rtorrent/.local/profile.d/`` — Directory with shell scripts that get sourced in ``~rtorrrent/.bash_aliases``.
 * ``/home/rtorrent/.local/pyenv/`` — Unless you chose to use the system's *Python*, the interpreter used to run ``pyrocore`` and ``flexget`` is installed here.
 * ``/home/rtorrent/lib/pyroscope`` — Virtualenv for ``pyrocore``.
 * ``/home/rtorrent/lib/flexget`` — Virtualenv for ``flexget``.
 * ``/home/rutorrent/ruTorrent-master`` — *ruTorrent* code base.


### Secure Communications

All internal RPC is done via Unix domain sockets.

 * `/var/run/php-fpm-rutorrent.sock` — *NginX* sends requests to PHP using the *php-fpm* pool `rutorrent` via this socket; it's owned by `rutorrent` and belongs to the `www-data` group.
 * `/var/torrent/.scgi_local` — The XMLRPC socket of rTorrent. It's group-writable and owned by `rtorrent.rtorrent`; ruTorrent talks directly to that socket (see issue #9 for problems with using /RPC2).


## References

### Server Hardening

 * [Secure Secure Shell](https://stribika.github.io/2015/01/04/secure-secure-shell.html)
 * https://github.com/sfromm/ansible-rkhunter
