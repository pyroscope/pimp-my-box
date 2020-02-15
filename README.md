# pimp-my-box

:warning: | A migration to Ansible 2 is underway, so to get something stable / usable, clone / check out the `ansible1` tag for now!
---: | :---

![logo](https://raw.githubusercontent.com/pyroscope/pimp-my-box/master/images/pimp-my-box.png)
[![issues](https://img.shields.io/github/issues/pyroscope/pimp-my-box.svg)](https://github.com/pyroscope/pimp-my-box/issues)
[![travis](https://api.travis-ci.org/pyroscope/pimp-my-box.svg)](https://travis-ci.org/pyroscope/pimp-my-box)

Automated install of rTorrent-PS etc. via
[Ansible](http://docs.ansible.com/).

:warning: | Right now, you need a *rTorrent-PS 1.1* version (git head) for the contained configuration to work. If you use an older installation, call ``echo >>~rtorrent/rtorrent/rtorrent.d/.rcignore 05-rt-ps-columns.rc`` when you get errors about ``ui.column.render`` on startup.
---: | :---

The playbooks in the ``pimp-my-box`` repository will install ``rTorrent-PS``, ``pyrocore``, and related software
onto any remote dedicated server or VPS with ``root`` access, running Debian or a Debian-like OS.

**See the [main documentation](http://pimp-my-box.readthedocs.io/) on how to install and use this.**

To get in contact and share your experiences with other users of *PyroScope*, join the
[pyroscope-users](http://groups.google.com/group/pyroscope-users)
mailing list or the inofficial ``##rtorrent`` channel on ``irc.freenode.net``.


## References

### Server Hardening

 * [Secure Secure Shell](https://stribika.github.io/2015/01/04/secure-secure-shell.html)
 * https://github.com/sfromm/ansible-rkhunter
