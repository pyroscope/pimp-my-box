Overview
========

The playbooks in the ``pimp-my-box`` repository will install ``rTorrent-PS``, ``pyrocore``,
and related software onto any remote dedicated server or VPS with ``root`` access,
running Debian or a Debian-like OS.
And nobody prevents you from treating your own workstation as ‘remote’,
so it can be used for a local install too. ☺

``Ansible`` is used to describe the installation process. It is a tool
that allows you to perform a complete setup remotely on one or any
number of *target hosts*, from the comfort of your own workstation. The
setup is described in so called *playbooks*, before executing them you
just have to add a few values like the name of your target host.

This is in many ways superior to the usual *“call a bash script to set up things
once and never be able to update them again”*, since you can run this
setup repeatedly to either fix problems, or to install upgrades and new
features added to this repository.

Additionally, if your host crashes and cannot be repaired for some reason,
restoring the software and its configuration is a breeze and typically done in under an hour.
You just need proper backups of crucial data, like the rTorrent session directory.
The same works for moving from one hosting provider to another,
just copy your data via rsync to your new host, to an identical setup.

The playbooks contained in here install the following components:

-  Security hardening of your server.
-  `rTorrent-PS`_ with UI enhancements, colorization, and some added
   features.
-  PyroScope `command line tools`_ (pyrocore) for rTorrent automation.

Optionally:

-  `FlexGet`_, the best feed reader and download automation tool there is.
-  `ruTorrent`_ web UI, served by `Nginx`_ over HTTPS and run by PHP FPM.

Each includes a default configuration, so you end up with a fully
working system.

The Ansible playbooks and related commands have been tested on Debian
Jessie, Ubuntu Xenial, and Ubuntu Trusty – the recommended distribution
is Ubuntu Server LTS 64bit (i.e. release 16.04 at the time of this
writing, unless you want to use rutorrent, then for now go back to 14.04
or use Debian Jessie). They should work on other platforms too,
especially when they're Debian derivatives, but you might have to make
some modifications.

Files are mostly installed into the user accounts
``rtorrent`` and ``rutorrent``, and only a few global configuration
files are affected. If you run this against a host with an existing
installation, make sure that there are no conflicts.

If you have questions or need help, please use the `pyroscope-users`_
mailing list or the inofficial ``##rtorrent`` channel on
``irc.freenode.net``.


.. _Ansible: http://docs.ansible.com/
.. _rTorrent-PS: https://github.com/pyroscope/rtorrent-ps#rtorrent-ps
.. _command line tools: https://github.com/pyroscope/pyrocore#pyrocore
.. _FlexGet: http://flexget.com/
.. _ruTorrent: https://github.com/Novik/ruTorrent
.. _Nginx: http://wiki.nginx.org/
.. _pyroscope-users: http://groups.google.com/group/pyroscope-users
