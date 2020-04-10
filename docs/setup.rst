Basic Installation
==================

Here's the steps you need to follow to get a working installation on
your target host. This might seem like an arduous process, but if you're
accustomed to a *Linux* command prompt and ideally also *Ansible*, it
boils down to these steps:

-  Create your working directory.
-  Call the `Ansible`_ installer script, if you don't have it available yet.
-  Enable a SSH sudo account on your deployment target.
-  Create and edit two Ansible config files.
-  Run the playbook and wait a bit.
-  Enjoy your working and secure seedbox.

And once you got it working, moving to or adding another machine is easy
and almost no work, just add that host and run the playbooks for it.

Note that this cannot be an `Ansible`_ or Linux shell 101, so if these
topics are new for you refer to the usual sources like
`The Debian Administrator's Handbook`_, `The Linux Command Line`_,
`The Art of Command Line`_, and the `Ansible Documentation`_.

.. _Ansible: http://docs.ansible.com/
.. _The Debian Administrator's Handbook: http://debian-handbook.info/browse/stable/
.. _The Linux Command Line: http://linuxcommand.org/tlcl.php
.. _The Art of Command Line: https://github.com/jlevy/the-art-of-command-line#the-art-of-command-line
.. _Ansible Documentation: http://docs.ansible.com/#ansible-documentation


Checking Out the Code
---------------------

To work with the playbooks, you need a local copy of them.
Unsurprisingly, you also need ``git`` installed for this,
to create that local copy (a/k/a *clone* the repository).

Executing these commands *on your workstation* takes care of that:

.. code-block:: shell

    which git || sudo apt-get install git
    mkdir -p ~/src; cd $_
    git clone "https://github.com/pyroscope/pimp-my-box.git"
    cd "pimp-my-box"


.. _install-ansible:

Installing Ansible
------------------

Ansible **must** be installed on the workstation from where you control
your target hosts. This can also be the target host itself, if you don't
have a local computer running on Linux, Mac OSX, or Windows 10 with WSL installed.
In that case, use a personal
account on that machine, or create an ``ansible`` one – any part of the
documentation that refers to ‘the workstation’ then means that account.

See the `Ansible Installation Documentation`_ for how to install it using the package
manager of your platform. Make sure you get the right version that way,
the playbooks are tested using Ansible *2.9.5*.
Read :ref:`ansible-update` when you have an existing workdir from before February 2020.

The *recommended* way to install Ansible is to put it into your home
directory. The following commands just require Python 3.5+ to be installed on
your system. The installation is easy to get rid of (everything is
contained within a single directory). When you have no
``~/.ansible.cfg`` yet (which you very likely do not), one is added.

**Enter / copy+paste this command into a shell prompt on your
workstation, within the 'pimp-my-box' directory!**

.. code-block:: shell

    ./scripts/install_ansible.sh

.. _Bash for Windows 10: http://www.jeffgeerling.com/blog/2017/using-ansible-through-windows-10s-subsystem-linux
.. _CygWin: https://servercheck.in/blog/running-ansible-within-windows
.. _Babun: https://babun.github.io/
.. _`Ansible Installation Documentation`: http://docs.ansible.com/intro_installation.html


Providing SSH Access for Ansible
--------------------------------

For a dedicated server, the first step is to create an account *Ansible*
can use to perform its work. Log into your server as ``root`` and call
these commands:

.. code-block:: shell

    account=setup
    groupadd $account
    useradd -g $account -G $account,users -c "Ansible remote user" \
            -s /bin/bash --create-home $account
    eval chmod 0750 ~$account
    passwd -l $account

Calling the following command as ``root`` on the *target host* will
grant password-less sudo to the new account:

.. code-block:: shell

    # Give password-less sudo permissions to the "setup" user
    echo >/etc/sudoers.d/setup "setup ALL=(ALL) NOPASSWD:ALL"

In case you prefer password-protected sudo, leave out the ``NOPASSWD:``,
and also set a password using ``passwd setup``.

The ``setup`` account must allow login using the ``id_rsa`` key, or
another key you create on your *workstation*. See `here`_ for
establishing working SSH access based on a pubkey login, if you've never
done that before.

Finally, the last snippet of SSH configuration goes into
``~/.ssh/config`` of your *workstation* account, add these lines
providing details on how to connect to your target host via SSH (and
replace the text in ``ALL_CAPS`` by the correct value):

.. code-block:: ini

    Host my-box
        HostName IP_ADDRESS_OR_DOMAIN_OF_TARGET
        Port 22
        User setup
        IdentityFile ~/.ssh/id_rsa
        IdentitiesOnly yes

Now to test that you did everything right, call the below ``ssh``
command on your *workstation*, and verify that you get the output as
shown:

.. code-block:: console

    $ ssh my-box "sudo id"
    uid=0(root) gid=0(root) groups=0(root)

In case you're asked for a password, enter the one you've set on the
``setup`` account.

.. _here: https://www.digitalocean.com/community/tutorials/ssh-essentials-working-with-ssh-servers-clients-and-keys


Setting Up Your Environment
---------------------------

Now with Ansible installed and able to connect via SSH, you next need to
configure the target host (by default named ``my-box``) and its specific
attributes (the so-called *host vars*). There is an example in
`host\_vars/rpi/main.yml`_ for a default *Raspberry Pi* setup which is
used a template.

To create the necessary files, call this command:

.. code-block:: shell

    ./scripts/add_host.sh

If you already have an Ansible inventory (i.e. ``hosts`` file), your
configured editor will open it – else a suitable default is created.
Make sure you add your target's name to the ``[box]`` group, if it's
missing.

Next the editor will open with ``main.yml``, fill in the values as
described in the first few lines of the file. In a final step, you need
to enter the ``sudo`` password of your target server.

Afterwards, you have these files in your working directory: ``hosts``,
``host_vars/my-box/main.yml``, and ``host_vars/my-box/secrets.yml``. If
you don't understand what is done here, read the Ansible documentation
again, specifically the “Getting Started” page.

Now we can check your setup and that Ansible is able to connect to the
target and do its job there. For this, call the command as shown after
the ``$``, and it should print what OS you have installed on the
target(s), like shown in the example.

.. code-block:: console

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

If anything goes wrong, add ``-vvvv`` to the ``ansible`` command for
more diagnostics, and also check your ``~/.ssh/config`` and the Ansible
connection settings in your ``host_vars``. If it's a connection problem,
try to directly call ``ssh -vvvv my-box`` and if that succeeds, also
make sure you can become ``root`` via ``sudo su -``. If not, read the
resources linked at :doc:`the start of this chapter <setup>`, and
especially the `SSH Essentials`_.

.. _host\_vars/rpi/main.yml: https://github.com/pyroscope/pimp-my-box/blob/master/host_vars/rpi/main.yml
.. _SSH Essentials: https://www.digitalocean.com/community/tutorials/ssh-essentials-working-with-ssh-servers-clients-and-keys


Using the System Python Interpreter
-----------------------------------

By default, Python 2.7.13 is installed because that version handles SSL
connections according to current security standards; the version
installed in your system often does not. This has an impact on e.g.
FlexGet's handling of ``https`` feeds.

If you want to use the system's Python interpreter, add these variables
to your host vars:

.. code-block:: ini

    pyenv_enabled: false
    python_bin: /usr/bin/python2
    venv_bin: /usr/bin/virtualenv

Doing so is recommended on *Xenial* (has 2.7.12),
*Jessie* (2.7.9), or *Stretch* (2.7.13).


.. _run-ansible:

Running the Playbook
--------------------

To execute the playbook, call ``ansible-playbook -i hosts site.yml``.
The initial installation will take a while, so be patient.

If your Linux release isn't supported with a pre-built package, you'll
see a message like the following:

::

    WARNING - No DEB package URL defined for '‹platform›', you need to install /opt/rtorrent manually!

In that case, `compile a binary yourself`_. If you want to run a
*rTorrent-PS* version that is not yet released to `Bintray`_, do the
same.

If you added more than one host into the ``box`` group and want to only
address one of them, use
``ansible-playbook -i hosts -l ‹hostname› site.yml``. Add (multiple)
``-v`` to get more detailed information on what each task does.

.. _compile a binary yourself: https://github.com/pyroscope/rtorrent-ps/blob/master/docs/DebianInstallFromSource.md#build-rtorrent-and-core-dependencies-from-source
.. _Bintray: https://bintray.com/pyroscope/rtorrent-ps/rtorrent-ps#files


.. _tmux-start:

Starting rTorrent
-----------------

As mentioned before, after successfully running the Ansible playbook, a
fully configured setup is found on the target. So to start rTorrent,
log in as the ``rtorrent`` user and start this command:

.. code-block:: shell

    tmux -2u new -n rT-PS -s rtorrent "~/rtorrent/start; exec bash"

To detach from this session (meaning rTorrent continues to run), press
``Ctrl-a`` followed by ``d``.

If you get ``rtorrent: command not found`` when calling above ``tmux``
command, then a pre-built Debian package is not available for your OS
distribution and you need to build from source (see previous section).
You can check explicitly with the following command:

.. code-block:: console

    $ dpkg -l rtorrent-ps
    dpkg-query: no packages found matching rtorrent-ps


.. _change-cfg-defaults:

Changing Configuration Defaults
-------------------------------

Customizing Your Setup
^^^^^^^^^^^^^^^^^^^^^^

A good way to provide customizations is writing your own playbooks.
Create a separate project in your own git repository. In that project,
you can provide your versions of existing files, add your own helper
scripts, and so on. Model it after this repository, and consult the
*Ansible* documentation. You can reuse your inventory, by passing
``-i ../pimp-by-box/hosts`` to the playbook calls, or by setting the
``ANSIBLE_INVENTORY`` environment variable.

As described in this and the following sections, some key config files
are designed to be replaced in this way. Just be aware that once you
copy them, you also have to manage them yourself, and merge with changes
made to the master in this repo!


.. _force-cfg:

Handling Top-Level Config Files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Once created, the file ``rtorrent.rc`` is only overwritten when you
provide ``-e force_cfg=yes`` on the Ansible command line.
This gives you the opportunity to easily refresh the main configuration
in ``rtorrent.rc`` from this repository.
But it *also* gives you the option to provide your own
custom version by other means, e.g. your own additional playbook,
without having that version constantly overwritten.

However, additional files in ``rtorrent.d/``
or the ``_rtlocal.rc`` include file are
the intended places to make customizations, so it's advisable to always
add ``-e force_cfg=yes`` on updates.

The ``_rtlocal.rc`` file, which is included by ``rtorrent.rc`` *after*
the standard configuration includes in ``rtorrent.d/``, is never overwritten.
So it's easy and safe to provide your own version of ``_rtlocal.rc`` from a custom playbook.
Or apply customizations manually, by editing ``~rtorrent/rtorrent/_rtlocal.rc``
– these will not be reverted by updating from the repository.

A typical use of ``_rtlocal.rc`` is to change how long log files are kept uncompressed,
here the default of 2 days is reduced to just one:

.. code-block:: shell

    pyro.log_archival.days.set = 1


.. _drop-in-files:

Adding Drop-In Files
^^^^^^^^^^^^^^^^^^^^

Another way to customize rTorrent is to use the
``~/rtorrent/rtorrent.d`` directory. Just place any file with a ``.rc``
extension there, and it will be loaded on the next restart. This is
ideally suited for custom playbooks, which can just add new files to
extend the default configuration.

That directory also contains most of the extra rTorrent configuration
that comes with ``pimp-my-box``. For example, by default terminating
rTorrent via ``^Q`` gets disabled in the ``disable-control-q.rc`` file,
replacing it by ``^X q=``, which you won't type by accident.

To restore the rTorrent default, run this command as the ``rtorrent``
user (or put the line into that file via *Ansible*):

.. code-block:: shell

    echo >>~/rtorrent/rtorrent.d/.rcignore "disable-control-q.rc"

Then restart rTorrent.


Optional Applications & More
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

See :doc:`options` on how to activate add-ons like ruTorrent,
and  :doc:`advanced` for more details about the box installation
and its features.
