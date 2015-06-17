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

import Tkinter

from src import get_configuration
from src import get_configuration_boolean
from src import get_configuration_int
from src import DEFAULT_SSH_KEYFILE
from src import DEFAULT_VNC_APPLICATION
from src import PROVIDED_SSH_KEY


class Settings:

    def __init__(self):
        has_configured_ssh_keyfile = not DEFAULT_SSH_KEYFILE is None

        configured_vnc_application = get_configuration('settings', 'vnc-application', default='')
        if configured_vnc_application is None:
            configured_vnc_application = ''
        elif len(configured_vnc_application.strip()) < 1:
            configured_vnc_application = ''

        self.host = Tkinter.StringVar(value=get_configuration('settings', 'host', default=''))
        self.port = Tkinter.IntVar(value=get_configuration_int('settings', 'port', default=5500))
        self.ssh_enabled = Tkinter.BooleanVar(value=get_configuration_boolean('settings', 'ssh-enabled', default=False))
        self.ssh_use_provided_key = Tkinter.BooleanVar(value=not PROVIDED_SSH_KEY is None)
        self.ssh_user = Tkinter.StringVar(value=get_configuration('settings', 'ssh-user', default=''))
        self.ssh_password = Tkinter.StringVar(value=get_configuration('settings', 'ssh-password', default=''))
        self.ssh_keyfile = Tkinter.StringVar(value=DEFAULT_SSH_KEYFILE if has_configured_ssh_keyfile else '')
        self.ssh_port = Tkinter.IntVar(value=get_configuration_int('settings', 'ssh-port', default=22))
        self.vnc_application = Tkinter.StringVar(value=configured_vnc_application)
        self.vnc_parameters = Tkinter.StringVar(value=get_configuration('settings', 'vnc-parameters', default=''))

    def copy_from(self, settings):
        self.host.set(settings.host.get())
        self.port.set(settings.port.get())
        self.ssh_enabled.set(settings.ssh_enabled.get())
        self.ssh_use_provided_key.set(settings.ssh_use_provided_key.get())
        self.ssh_user.set(settings.ssh_user.get())
        self.ssh_password.set(settings.ssh_password.get())
        self.ssh_keyfile.set(settings.ssh_keyfile.get())
        self.ssh_port.set(settings.ssh_port.get())
        self.vnc_application.set(settings.vnc_application.get())
        self.vnc_parameters.set(settings.vnc_parameters.get())

    def copy_to(self, settings):
        settings.copy_from(self)

    def get_host(self, default=None):
        host = self.host.get()
        if host is None:
            return default
        host = host.strip()
        if host == '':
            return default
        return host

    def get_port(self, default=None):
        try:
            return self.port.get()
        except ValueError:
            return default

    def get_ssh_keyfile(self, default=None):
        keyfile = self.ssh_keyfile.get()
        if not keyfile is None and not keyfile == '':
            return keyfile
        else:
            return default

    def get_ssh_password(self, default=''):
        password = self.ssh_password.get()
        if not password is None and not password == '':
            return password
        else:
            return default

    def get_ssh_port(self, default=22):
        try:
            return self.ssh_port.get()
        except ValueError:
            return default

    def get_ssh_user(self, default='support'):
        user = self.ssh_user.get()
        if not user is None and not user == '':
            return user
        else:
            return default

    def get_vnc_application(self, default=DEFAULT_VNC_APPLICATION):
        app = self.vnc_application.get()
        if not app is None and not app == '':
            return app
        else:
            return default

    def get_vnc_parameters(self, default=''):
        parameters = self.vnc_parameters.get()
        if not parameters is None and not parameters == '':
            return parameters
        else:
            return default

    def is_ssh_enabled(self):
        return self.ssh_enabled.get()

    def is_ssh_use_provided_key(self):
        return not PROVIDED_SSH_KEY is None and self.ssh_use_provided_key.get()
