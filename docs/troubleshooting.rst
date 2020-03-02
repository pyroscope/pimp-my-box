Trouble-Shooting Guide
======================

Reporting Problems
------------------

If you have any trouble during *pimp-my-box* installation and configuration,
or using any of the commands from the documentation,
join the `rtorrent-community`_ channel `pyroscope-tools`_ on Gitter.
You can also ask questions on platforms like `Reddit`_ or `Stack Exchange`_.

.. image:: https://raw.githubusercontent.com/pyroscope/pyrocore/master/docs/_static/img/help.png
    :align: left

If you are sure there is a bug, then `open an issue`_ on *GitHub*.
Make sure that nobody else reported the same problem before you,
there is a `search box`_ you can use (after the **Filter** button).
Please note that the *GitHub* issue tracker is not a support platform,
use the Gitter channel or Reddit for any questions, as mentioned above.

And ESR's golden oldie `How To Ask Questions The Smart Way`_ is still a most valuable resource, too.

.. note::

    Please **describe your problem clearly**, and provide any pertinent
    information.
    What are the **version numbers** of software and OS?
    What did you do?
    What was the **unexpected result**?
    If things worked and ‘suddenly’ broke, **what did you change**?

    **In the chat, don't ask if somebody is there, just describe your problem**.
    Eventually, someone will notice you – people *do* live in different time zones than you.

    Put up any logs on `0bin <http://0bin.net/>`_ or any other pastebin
    service, and **make sure you removed any personal information** you
    don't want to be publically known. Copy the pastebin link into the
    chat window.

The following helps with querying your system environment, e.g. the
version of Python and your OS.

.. _`rtorrent-community`: https://gitter.im/rtorrent-community/
.. _`pyroscope-tools`: https://gitter.im/rtorrent-community/pyroscope-tools
.. _`pyroscope-users`: http://groups.google.com/group/pyroscope-users
.. _`open an issue`: https://github.com/pyroscope/pimp-my-box/issues
.. _`search box`: https://help.github.com/articles/searching-issues/
.. _`How To Ask Questions The Smart Way`: http://www.catb.org/~esr/faqs/smart-questions.html
.. _`Reddit`: https://www.reddit.com/r/rtorrent/
.. _`Stack Exchange`: https://unix.stackexchange.com/


Providing Diagnostic Information
--------------------------------

Python Diagnostics
^^^^^^^^^^^^^^^^^^

Execute the following command to be able to provide some information on
your Python installation:

.. code-block:: shell

    deactivate 2>/dev/null; /usr/bin/virtualenv --version; python <<'.'
    import sys, os, time, pprint
    pprint.pprint(dict(
        version=sys.version,
        prefix=sys.prefix,
        os_uc_names=os.path.supports_unicode_filenames,
        enc_def=sys.getdefaultencoding(),
        maxuchr=sys.maxunicode,
        enc_fs=sys.getfilesystemencoding(),
        tz=time.tzname,
        lang=os.getenv("LANG"),
        term=os.getenv("TERM"),
        sh=os.getenv("SHELL"),
    ))
    .

If ``enc_fs`` is **not** ``UTF-8``, then call
``dpkg-reconfigure locales`` (on Debian type systems) and choose a
proper locale (you might also need ``locale-gen en_US.UTF-8``), and make
sure ``LANG`` is set to ``en_US.UTF-8`` (or another locale with UTF-8
encoding).


OS Diagnostics
^^^^^^^^^^^^^^

Similarly, execute this in a shell prompt:

.. code-block:: shell

    uname -a; echo $(lsb_release -as 2>/dev/null); grep name /proc/cpuinfo | uniq -c; \
    free -m | head -n2; uptime; \
    strings $(which rtorrent) | grep "client version"; \
    ldd $(which rtorrent) | egrep "lib(torrent|curses|curl|xmlrpc.so|cares|ssl|crypto)"; \
    ps auxw | egrep "USER|/rtorrent" | grep -v grep


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
