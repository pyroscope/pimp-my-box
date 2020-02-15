Advanced Topics
===============

Activating Firewall Rules
-------------------------

If you want to set up firewall rules using the `Uncomplicated Firewall`_
(UFW) tool, then call the playbook using this command:

.. code-block:: shell

    # See above regarding adding the '-l' option to select a single host
    ansible-playbook -i hosts site.yml -t ufw -e ufw=true

This will install the ``ufw`` package if missing, and set up all rules
needed by apps installed using this project. Note that activating the
firewall is left as a manual task, since you can make a remote server
pretty much unusable when SSH connections get disabled by accident –
only a rescue mode or virtual console can help to avoid a full reinstall
then, if you have no physical access to the machine.

So to activate the firewall rules, use this in a ``root`` shell on the
*target host*:

.. code-block:: shell

    egrep 'ssh|22' /lib/ufw/user.rules /etc/ufw/user.rules
    # Make sure the output contains
    #   ### tuple ### limit tcp 22 0.0.0.0/0 any 0.0.0.0/0 in
    # followed by 3 lines starting with '-A'.

    ufw enable  # activate the firewall
    ufw status verbose  # show all the settings

.. _Uncomplicated Firewall: https://en.wikipedia.org/wiki/Uncomplicated_Firewall


Using Ansible for Remote Management
-----------------------------------

The setup work to get *Ansible* controlling your machines is not just
for installing things, you can also simplify daily management tasks.

First, define this function to make calls to ``rtorrent`` tools easier:

.. code-block:: shell

    rtansible() {
        if test -z "$1"; then
            echo >&2 "usage: rtansible TARGET CMD [ARGS...]"
            return 1
        fi
        local target="${1:?Missing a group/host name as 1st arg}"; shift
        local cmd="${1:?Missing a remote command as 2nd arg}"; shift
        ansible "$target" -f4 -a "sudo -i -u rtorrent -- $cmd" "$@"
    }

Then consider this example, which prints the number of items loaded into
rTorrent, for all hosts in the ``box`` group of your inventory:

.. code-block:: console

    $ rtansible box \
        '~rtorrent/bin/rtxmlrpc view.size @/dev/null default' -o \
        | sort
    my-box | success | rc=0 | (stdout) 42
    my-box2 | success | rc=0 | (stdout) 123

Similarly, this shows the Linux release you're using:

.. code-block:: console

    $ rtansible box 'lsb_release -cs' -o | sort
    my-box | CHANGED | rc=0 | (stdout) bionic

Another example is updating the ``pyrocore`` installation from git, like
this:

.. code-block:: shell

    rtansible box '~rtorrent/.local/pyroscope/update-to-head.sh'
    rtansible box '~rtorrent/bin/pyroadmin --version' -o | sort

This is especially useful if you control more than one host.


.. _bash-finished:

Using the bash Download Completion Handler
------------------------------------------

The default configuration adds a *finished* event handler that calls the
``~rtorrent/bin/_event.download.finished`` script. That script in turn
just calls any existing ``_event.download.finished-*.sh`` script, which
allows you to easily add custom completion behaviour via your own
playbooks.

The passed parameters are ``hash``, ``name``, and ``base_path``; the
completion handler ensures the session state is flushed, so you can
confidently read the session files associated with the provided hash.

Be aware that you cannot call back into rTorrent via XML-RPC within an
event handler, because that leads to a deadlock. If you need to do that,
call your script directly using ``execute.bg`` or one of its variants.

Alternatively detach yourself from the process that rTorrent created for
the event, so the event handler finishes as far as rTorrent is concerned.

In any of these cases, be aware that things run concurrently and
can go horribly wrong, if you don't take care of race conditions and such.
A command queue like `nq`_ can help here, by accepting commands than run
in the backgropund, but strictly serialized in the order they are added.

Here is a non-trivial example that goes to
``~/bin/_event.download.finished-jenkins.sh``, and triggers a `Jenkins`_
job for any completed item:

.. code-block:: shell

    #! /bin/bash
    #
    # Called in rTorrent event handler

    set -x

    infohash="${1:?You MUST provide the infohash of the completed item!}"
    url="http://localhost:8080/job/event.download.finished/build?delay=0sec"
    json="$(python -c "import json; print json.dumps(dict(parameter=dict(name='INFOHASH', value='$infohash')))")"

    http --ignore-stdin --form POST "$url" token=C0mpl3t3 json="$json"

You need to add the related ``event.download.finished`` job and
``rtorrent`` user to Jenkins of course. The user's credentials must be
added to ``~rtorrent/.netrc``, like this:

.. code-block:: ini

    machine localhost
        login rtorrent
        password YOUR_PWD

Make sure to call ``chmod 0600 ~/.netrc`` after creating the file.

To check that everything is working, download something and check the
build history of your Jenkins job – if nothing seems to happen, look
into ``~/rtorrent/log/execute.log`` to debug.

The fact that *Jenkins* runs in its own separate process means your job
can make free use of ``rtxmlrpc`` and ``rtcontrol`` to change things in
*rTorrent*.

.. _nq: https://github.com/leahneukirchen/nq#readme
.. _Jenkins: https://jenkins.io/


Extending the Nginx Site
------------------------

The main Nginx server configuration includes any
``/etc/nginx/conf.d/rutorrent-*.include`` files, so you can add your own
locations in addition to the default ``/rutorrent`` one. The main
configuration file is located at
``/etc/nginx/sites-available/rutorrent``.

Use a ``/etc/nginx/conf.d/upstream-*.conf`` file in case you need to add
your own ``upstream`` definitions.


Implementation Details
----------------------

Location of Configuration Files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

-  ``/home/rtorrent/rtorrent/rtorrent.rc`` – Main *rTorrent*
   configuration file; to update it from this repository use
   ``-e force_cfg=yes``, see :doc:`setup` for details.
-  ``/home/rtorrent/rtorrent/_rtlocal.rc`` – *rTorrent* configuration
   include for custom modifications, this is *never* overwritten once it
   exists.
-  ``/home/rtorrent/.pyroscope/config.ini`` – ``pyrocore`` main
   configuration.
-  ``/home/rtorrent/.pyroscope/config.py`` – ``pyrocore`` custom field
   configuration.
-  ``/home/rtorrent/.config/flexget/config.yml`` – *FlexGet*
   configuration.
-  ``/home/rutorrent/ruTorrent-master/conf/config.php`` – *ruTorrent*
   configuration.
-  ``/home/rutorrent/profile/`` – Dynamic data written by *ruTorrent*.
-  ``/etc/nginx/sites-available/rutorrent`` – *NginX* configuration for
   the *ruTorrent* site.
-  ``/etc/php5/fpm/pool.d/rutorrent.conf`` or
   ``/etc/php/7.0/fpm/pool.d/rutorrent.conf`` – PHP worker pool for
   *ruTorrent*.


Location of Installed Software
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

-  ``/home/rtorrent/.local/profile.d/`` — Directory with shell scripts
   that get sourced in ``~rtorrrent/.bash_aliases``.
-  ``/home/rtorrent/.local/pyenv/`` — Unless you chose to use the
   system's *Python*, the interpreter used to run ``pyrocore`` and
   ``flexget`` is installed here.
-  ``/home/rtorrent/.local/pyroscope`` — Virtualenv for ``pyrocore``.
-  ``/home/rtorrent/.local/flexget`` — Virtualenv for ``flexget``.
-  ``/home/rutorrent/ruTorrent-master`` — *ruTorrent* code base.


Secure Communications
^^^^^^^^^^^^^^^^^^^^^

All internal RPC is done via Unix domain sockets.

-  ``/var/run/php-fpm-rutorrent.sock`` — *NginX* sends requests to PHP
   using the *php-fpm* pool ``rutorrent`` via this socket; it's owned by
   ``rutorrent`` and belongs to the ``www-data`` group.
-  ``/var/torrent/.scgi_local`` — The XMLRPC socket of rTorrent. It's
   group-writable and owned by ``rtorrent.rtorrent``; ruTorrent talks
   directly to that socket (see issue #9 for problems with using /RPC2).
