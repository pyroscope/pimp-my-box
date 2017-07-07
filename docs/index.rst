.. pimp-my-box documentation master file, created by
   sphinx-quickstart on Sun Jul  2 13:26:28 2017.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to the “pimp-my-box” Manual!
====================================

The playbooks in the ``pimp-my-box`` repository will install ``rTorrent-PS``, ``pyrocore``, and related software
onto any remote dedicated server or VPS with ``root`` access, running Debian or a Debian-like OS.
Read :doc:`overview` to learn more.

|issues| |travis|


.. warning::

    Right now, you need a *rTorrent-PS 1.1* version (git head)
    for the contained configuration to work. If you use an older
    installation, call

    .. code-block:: shell

        echo >>~rtorrent/rtorrent/rtorrent.d/.rcignore 05-rt-ps-columns.rc

    when you get errors about ``ui.column.render`` on startup.


.. note::

    .. include:: include-contacts.rst


.. |logo| image:: https://raw.githubusercontent.com/pyroscope/pimp-my-box/master/images/pimp-my-box.png
.. |issues| image:: https://img.shields.io/github/issues/pyroscope/pimp-my-box.svg
   :alt: GitHub Issues
   :target: https://github.com/pyroscope/pimp-my-box/issues
.. |travis| image:: https://api.travis-ci.org/pyroscope/pimp-my-box.svg
   :alt: Travis CI Status
   :target: https://travis-ci.org/pyroscope/pimp-my-box


Full Contents
-------------

.. toctree::
   :maxdepth: 3

   overview
   setup
   options
   advanced
   troubleshooting
   updates


Indices & Tables
----------------

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
