Trouble-Shooting Guide
======================

Reporting Problems
------------------

If you have any trouble during *pimp-my-box* installation and
configuration, or using any of the commands used, join the `pyroscope-users`_
mailing list or the inofficial ``##rtorrent`` channel on
``irc.freenode.net``. IRC will generally provide a faster resolution.

If you are sure there is a bug, then `open an issue`_ on *GitHub*.
Make sure that nobody else reported the same problem before you,
there is a `search box`_ you can use (after the **Filter** button).
Please note that the *GitHub* issue tracker is not a support platform,
use the mailing list or IRC for that.

.. note::

    Please **describe your problem clearly**, and provide any pertinent
    information.
    What are the **version numbers** of software and OS?
    What did you do?
    What was the **unexpected result**?
    If things worked and ‘suddenly’ broke, **what did you change**?

    **On IRC, don't ask if somebody is there, just describe your problem**.
    Eventually, someone will notice you – IRC is a global medium, and
    people *do* live in different time zones than you.

    Put up any logs on `0bin <http://0bin.net/>`_ or any other pastebin
    service, and **make sure you removed any personal information** you
    don't want to be publically known. Copy the pastebin link into IRC
    or into your post.

.. _`pyroscope-users`: http://groups.google.com/group/pyroscope-users
.. _`open an issue`: https://github.com/pyroscope/pimp-my-box/issues
.. _`search box`: https://help.github.com/articles/searching-issues/


Common Problems & Solutions
---------------------------

Error in option file: …/05-rt-ps-columns.rc:…: Invalid key
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You combined a brand-new `pimp-my-box` with an older version of `rTorrent-PS`.


.. rubric:: Solution ♯1 (preferred)

:ref:`rt-ps-update` to a recent build.

Also make sure your ``~/rtorrent/rtorrent.rc`` is the newest one with the line…

.. code-block:: ini

    method.insert = pyro.extended, const|value, (system.has, rtorrent-ps)

This auto-detects the presence of `rTorrent-PS`, but only works with builds from June 2018 onwards.


.. rubric:: Solution ♯2

Replace this line in ``~/rtorrent/rtorrent.rc``…

.. code-block:: ini

    method.insert = pyro.extended, const|value, (system.has, rtorrent-ps)

with that one…

.. code-block:: ini

    method.insert = pyro.extended, const|value, 1


SSH Error: Host key verification failed
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you get this error, one easy way out is to first enter the following
command and then repeat your failing Ansible command:

.. code-block:: shell

    export ANSIBLE_HOST_KEY_CHECKING=False


rtorrent: command not found
^^^^^^^^^^^^^^^^^^^^^^^^^^^

When you get this error using the ``tmux`` start command as shown in :ref:`tmux-start`,
then neither a package nor an explicitly compiled binary of rTorrent is installed on your machine.

See :ref:`run-ansible` on how to solve this.
