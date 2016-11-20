#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2015-2016 OpenIndex.de
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

__author__ = 'Andreas Rudolph'

import paramiko

from src import DEFAULT_SSH_KEYFILE
from src import LOCALHOST
from src.thirdparty.forward import forward_tunnel


def test_tunnel():
    host = 'my-server-name'
    port = 5500
    ssh_port = 22
    ssh_user = 'support'
    ssh_keyfile = DEFAULT_SSH_KEYFILE

    # create ssh private key
    pkey = paramiko.RSAKey.from_private_key_file(ssh_keyfile, password='')

    # create ssh client
    client = paramiko.SSHClient()
    #client.load_system_host_keys()
    client.set_missing_host_key_policy(paramiko.WarningPolicy())
    #client.set_missing_host_key_policy(paramiko.RejectPolicy())
    #client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    # open ssh connection
    client.connect(host, port=ssh_port, username=ssh_user, pkey=pkey, password='',
                   look_for_keys=False, compress=True, allow_agent=False)

    # open ssh tunnel
    transport = client.get_transport()
    #transport.window_size = 2147483647
    #transport.packetizer.REKEY_BYTES = pow(2, 40) # 1TB max, this is a security degradation
    #transport.packetizer.REKEY_PACKETS = pow(2, 40) # 1TB max, this is a security degradation
    forward_tunnel(port, LOCALHOST, port, transport)

if __name__ == '__main__':
    test_tunnel()
