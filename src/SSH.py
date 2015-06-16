#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2015 OpenIndex.de
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
import threading
import traceback

from src import LOCALHOST
from src import TIMEOUT
from src.thirdparty import forward


def create_forwarding_server(local_port, remote_host, remote_port, transport):
    # this is a little convoluted, but lets me configure things for the Handler
    # object.  (SocketServer doesn't give Handlers any way to access the outer
    # server normally.)
    class SubHander (forward.Handler):
        chain_host = remote_host
        chain_port = remote_port
        ssh_transport = transport
    return forward.ForwardServer(('', local_port), SubHander)


def read_private_key_from_file(path, password=None):
    with open(path, 'r') as key_file:
        key_head = key_file.readline()
        key_file.seek(0)
        if 'DSA' in key_head:
            keytype = paramiko.DSSKey
        elif 'RSA' in key_head:
            keytype = paramiko.RSAKey
        else:
            raise Exception('Can\'t identify type of private key!')
        return keytype.from_private_key(key_file, password=password)


class Tunnel:
    def __init__(self, settings):
        self.settings = settings
        self.client = None
        self.forwarder = None

    def connect(self):
        print 'Open SSH connection...'
        host = self.settings.get_host()
        ssh_port = self.settings.get_ssh_port()
        ssh_user = self.settings.get_ssh_user()
        ssh_keyfile = self.settings.get_ssh_keyfile()
        ssh_password = self.settings.get_ssh_password()

        if not self.client is None:
            self.disconnect()

        # use provided SSH private key
        if self.settings.is_ssh_use_provided_key():
            from src import PROVIDED_SSH_KEY
            pkey = PROVIDED_SSH_KEY

        # read SSH private key from configured file
        else:
            try:
                if ssh_keyfile:
                    pkey = read_private_key_from_file(ssh_keyfile, password=ssh_password)
                else:
                    pkey = None

            except:
                print 'Can\'t read private SSH key!'
                print traceback.format_exc()
                return False

        try:
            # create SSH client
            self.client = paramiko.SSHClient()
            #self.client.load_system_host_keys()
            self.client.set_missing_host_key_policy(paramiko.WarningPolicy())
            #self.client.set_missing_host_key_policy(paramiko.RejectPolicy())
            #self.client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

            # open SSH connection
            self.client.connect(host, port=ssh_port, username=ssh_user, password=ssh_password if pkey is None else '',
                                pkey=pkey, timeout=TIMEOUT, banner_timeout=TIMEOUT,
                                look_for_keys=False, compress=True, allow_agent=False)

            return True

        except:
            self.client = None
            print 'Can\'t open SSH connection!'
            print traceback.format_exc()
            return False

    def disconnect(self):
        try:
            if not self.forwarder is None:
                print 'Shutdown SSH port forwarding...'
                self.forwarder.kill()
        finally:
            self.forwarder = None

        try:
            if not self.client is None:
                print 'Shutdown SSH connection...'
                self.client.close()
        finally:
            self.client = None

    def is_running(self):
        return not self.client is None and not self.forwarder is None and self.forwarder.running

    def start_forwarding(self):
        if self.client is None:
            print 'No SSH connection is available.'
            return False

        self.forwarder = TunnelForwarderThread(self.settings, self.client)
        self.forwarder.start()
        return True


class TunnelForwarderThread(threading.Thread):
    def __init__(self, settings, client):
        super(TunnelForwarderThread, self).__init__()
        self.settings = settings
        self.client = client
        self.forwarder = None
        self.running = False

    def kill(self):
        try:
            if not self.forwarder is None:
                self.forwarder.shutdown()
        finally:
            self.forwarder = None
            self.running = False

    def run(self):
        self.running = True
        port = self.settings.get_port()

        if not self.forwarder is None:
            self.kill()

        try:
            # open SSH tunnel
            print 'Open SSH port forwarding...'
            transport = self.client.get_transport()
            #transport.window_size = 2147483647
            #transport.packetizer.REKEY_BYTES = pow(2, 40) # 1TB max, this is a security degradation
            #transport.packetizer.REKEY_PACKETS = pow(2, 40) # 1TB max, this is a security degradation
            self.forwarder = create_forwarding_server(port, LOCALHOST, port, transport)
            self.forwarder.serve_forever()

        except:
            print 'Can\'t open SSH tunnel!'
            print traceback.format_exc()

        finally:
            self.kill()
