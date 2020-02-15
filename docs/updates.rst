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

Also :ref:`re-read the explanation <force-cfg>` of adding ``-e force_cfg=yes`` and the
consequences that has, namely overwriting some configuration files that
are normally created only once and then left untouched.

Don't ask *“Should I add this option?”* in support, that is entirely
dependent on how *you* manage your system. See above.

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


.. _ansible-update:

Update to Ansible2 on Your Workstation
--------------------------------------

Make sure to uninstall the old Ansible version, or move its commands to an extra directory:

.. code-block:: shell

    ls -l ~/bin/ansible*
    mkdir -p ~/.local/bin/ansible1
    mv ~/bin/ansible* $_

Install Ansible 2.9.5, see :ref:`install-ansible` for details:

.. code-block:: shell

    ./scripts/install_ansible.sh

Check by calling ``ansible --version``, which should show something like this::

    ansible 2.9.5
      config file = ~/.ansible.cfg
      configured module search path = ['~/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
      ansible python module location = ~/.local/venvs/ansible/lib/python3.6/site-packages/ansible
      executable location = ~/.local/bin/ansible
      python version = 3.6.8 (default, Jan 28 2020, 20:29:43) [GCC 4.6.3]

Add this to your ``host_vars`` file(s), e.g. ``host_vars/my-box/main.yml``:

.. code-block:: yaml

    ansible_become: true
    ansible_python_interpreter: /usr/bin/python3

Try to call the playbook in check mode:

.. code-block:: shell

    ansible-playbook site.yml -l my-box -t base --check --diff

This might show deprecation warnings, but should run without errors otherwise.


.. hint::

    .. rubric:: Special considerations for Trusty (Ubuntu 14.04)

    Python version 3.4 as available on Trusty is too old for Ansible.
    So set the Python interpreter explicitly to Python2 as follows:

    .. code-block:: yaml

        ansible_python_interpreter: /usr/bin/python2


.. _rt-ps-update:

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
