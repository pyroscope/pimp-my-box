Software Updates
================

Updating Your System with Changes in The Repository
---------------------------------------------------

You have full control over when your system is upgraded with new
features and fixes, which implies you are also responsible for that.

`Read the commit log`_ from the top to the date / commit SHA you last
updated your working directory, to actually know what you're installing.
You can also use ``git log`` or ``gitk`` on your machine for that,
*after* a pull.

Call these commands *in your working directory of the pimp-my-box repository* for
updating:

.. code-block:: shell

    git pull --ff-only
    ansible-playbook -i hosts site.yml

Before you start, make sure to read any warnings that might be at the
top of the `README`_.

Also re-read the explanation of adding ``-e force_cfg=yes`` and the
consequences that has, namely overwriting some configuration files that
are normally created only once and then left untouched.

Don't ask *“Should I add this option?”* in support, that is entirely
dependendent on how *you* manage your system. See above.

.. _Read the commit log: https://github.com/pyroscope/pimp-my-box/commits/master
.. _`README`: https://github.com/pyroscope/pimp-my-box#pimp-my-box


Upgrade the Python Version
--------------------------

When you installed *Python* via *pyenv* (i.e. ``pyenv_enabled`` is still
set to ``true``), you can update to a new *Python* release by
reinstalling the related software. If you want to select a specific
Python version, set the ``pyenv_python_version`` variable in your
``host_vars`` or ``group_vars``.

You first have to remove the old install directory, and all virtualenvs
based on it:

.. code-block:: shell

    ansible box -i hosts -a "bash -c 'cd ~rtorrent/.local && rm -rf pyenv pyroscope flexget'"

Then execute the relevant roles again:

.. code-block:: shell

    ansible-playbook site.yml -i hosts -t pyenv,cli,fg

As given, these commands affect all hosts in the ``box`` group of your
inventory. Also, both ``pyrocore`` and ``flexget`` get upgraded to the
newest available version.


Upgrade the rTorrent-PS Version
-------------------------------

To upgrade the installed ``rtorrent-ps`` package, execute this command
on your workstation:

.. code-block:: shell

    ansible box -i hosts -a "rm /opt/rtorrent/pmb-installed"

Then run the playbook to install the new version:

.. code-block:: shell

    ansible-playbook site.yml -i hosts -t rtps

Finally connect to your ``tmux`` session, and stop & restart rTorrent.
