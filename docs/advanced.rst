Advanced Topics
===============

Using Ansible for Remote Management
-----------------------------------

The setup work to get *Ansible* controlling your machines is not just
for installing things, you can also simplify daily management tasks.

Consider this example, which prints the number of items loaded into
rTorrent, for all hosts in your inventory:

.. code-block:: console

    $ ansible box -f4 --become-user=rtorrent -a "~/bin/rtxmlrpc view.size '' default" -o
    my-box | success | rc=0 | (stdout) 42
    my-box2 | success | rc=0 | (stdout) 123

Another example is updating the ``pyrocore`` installation from git, like
this:

.. code-block:: shell

    ansible box -f4 -a "sudo -i -u rtorrent -- ~rtorrent/.local/pyroscope/update-to-head.sh"
    ansible box -f4 --become-user=rtorrent -a "~/bin/pyroadmin --version" -o

This is especially useful if you control more than one host.


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
