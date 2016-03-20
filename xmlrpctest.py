#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Quick XMLRPC connection test via /RPC2"""
import sys
import socket
import xmlrpclib
from datetime import datetime

def main(args):
    """XMLRPC /RPC2 test."""
    host = 'localhost'
    if len(args) >= 1:
        host = args[0]
    url = "https://{}/RPC2".format(host)
    print("Connecting to {!r}...".format(url))
    server = xmlrpclib.ServerProxy(url)
    print(server)

    try:
        print("Session:         %s" % server.session.name())
        print("XMLRPC methods:  %d" % len(server.system.listMethods()))
        time_usec = server.system.time_usec()
        print("Time (µsec):     %d (%s)" % (
            time_usec, datetime.fromtimestamp(time_usec/1E6).isoformat()))
    except (socket.error, xmlrpclib.Error) as cause:
        print("ERROR: %s" % cause)
    else:
        print("OK")


if __name__ == "__main__":
    main(sys.argv[1:])
