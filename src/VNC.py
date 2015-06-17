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

import psutil
import subprocess
import sys
import thread
import threading
import time
import traceback

from src import _
from src import LOCALHOST
from src import OS_DARWIN
from src import OS_LINUX
from src import OS_WINDOWS
from src.SSH import Tunnel


if OS_WINDOWS:
    import _winreg as winreg

    def prepare_tightvnc_registry():
        registry = winreg.ConnectRegistry(None, winreg.HKEY_CURRENT_USER)
        key = winreg.CreateKey(registry, r'SOFTWARE\\TightVNC\\Server')
        winreg.SetValueEx(key, 'AcceptHttpConnections', 0, winreg.REG_DWORD, 0)
        winreg.SetValueEx(key, 'AcceptRfbConnections', 0, winreg.REG_DWORD, 0)
        winreg.SetValueEx(key, 'AllowLoopback', 0, winreg.REG_DWORD, 1)
        #winreg.SetValueEx(key, 'GrabTransparentWindows', 0, winreg.REG_DWORD, 0)
        winreg.SetValueEx(key, 'RemoveWallpaper', 0, winreg.REG_DWORD, 1)
        winreg.SetValueEx(key, 'UseVncAuthentication', 0, winreg.REG_DWORD, 0)
        winreg.CloseKey(key)
        winreg.CloseKey(registry)


class VNC(threading.Thread):

    def __init__(self, app, settings):
        super(VNC, self).__init__()
        self.app = app
        self.settings = settings
        self.pid = 0
        self.error = False
        self.running = False
        self.process = Process()
        self.setDaemon(True)

    def check(self):
        #print 'Check VNC status for pid %s...' % self.pid
        if self.pid == 0 or self.process.killed:
            return False

        # look for connections on the VNC port
        port = self.settings.get_port()

        # OS X requires root privileges for 'psutil.net_connections()'
        # therefore we're using netstat in this case until a better solution may occur
        if OS_DARWIN:
            try:
                status = subprocess.check_output('LANG=C netstat -an | grep %s | grep ESTABLISHED' % port, shell=True)
                #print 'SATUS COMMAND SUCCEEDED'
                #print status.strip()

            except subprocess.CalledProcessError as e:
                #print 'SATUS COMMAND FAILED'
                #print e.output.strip()
                #print traceback.format_exc()
                return False

            return len(status) > 0

        # look for open ports with 'psutil.net_connections()'
        # see https://pythonhosted.org/psutil/#psutil.net_connections
        else:
            for c in psutil.net_connections(kind='inet'):
                #print 'CONNECTION: %s' % str(c)
                address = c.raddr
                if address is None or len(address) < 2:
                    continue
                if not c.status is psutil.CONN_ESTABLISHED:
                    continue
                if str(address[1]) == str(port):
                    return True

            return False

    def kill(self):
        self.process.stop()
        self.running = False
        self.pid = 0

    def run(self):
        self.error = False

        # start the process
        try:
            self.pid = self.process.start(self.settings)
        except:
            print traceback.format_exc()
            self.app.set_error(_('Can\'t establish the connection.'))
            self.error = True

        # check peridically, if the process is running
        if not self.error:
            time.sleep(5)
        if not self.error and self.pid > 0 and self.check():
            self.running = True
            self.app.set_connected()
            while self.running and self.check():
                time.sleep(.5)
            self.app.set_disconnected()

        # process did not start up
        else:
            self.app.set_error(_('Can\'t establish the connection.'))
            self.error = True

        self.kill()


class Process:

    def __init__(self):
        self.killed = False
        self.process = None
        self.tunnel = None
        self.vnc = None
        self.threadLock = thread.allocate_lock()

    def start(self, settings):
        self.threadLock.acquire(1)
        try:
            self.killed = False
            self.vnc = settings.get_vnc_application()
            host = settings.get_host()
            port = settings.get_port()

            # get additional VNC parameters
            additional_params = settings.get_vnc_parameters()
            if not additional_params is None:
                additional_params = additional_params.strip()
                if additional_params == '':
                    additional_params = None
                else:
                    additional_params = additional_params.split(' ')

            self.tunnel = None
            if settings.is_ssh_enabled():
                print 'Establish a secured SSH tunnel...'
                self.tunnel = Tunnel(settings)
                if not self.tunnel.connect():
                    print 'Can\'t establish SSH connection!'
                    self.process = None
                    return 0

                if not self.tunnel.start_forwarding():
                    print 'Can\'t establish SSH port forwarding!'
                    self.process = None
                    return 0

                time.sleep(5)
                if not self.tunnel.is_running():
                    print 'Can\'t establish SSH tunnel!'
                    self.process = None
                    return 0

                address = '%s:%s' % (LOCALHOST, port)

            else:
                address = '%s:%s' % (host, port)

            if OS_DARWIN:
                print 'Launch OSXvnc...'

                a = address.split(':')
                command = [self.vnc, '-connectHost', a[0], '-connectPort', a[1], '-localhost', '-nevershared']
                if not additional_params is None:
                    command += additional_params
                print command[0]
                print '  %s' % ' '.join(command[1:])
                print ''
                print '=' * 80
                print ''
                time.sleep(.5)
                self.process = psutil.Popen(command, stdout=sys.stdout, stderr=sys.stderr)
                #print self.process.status()

            elif OS_LINUX:
                print 'Launch x11vnc...'

                # command line options vor x11vnc
                # see http://www.karlrunge.com/x11vnc/x11vnc_opts.html
                command = [self.vnc, '-connect_or_exit', address, '-nopw', '-nocmds', '-nevershared', '-rfbport', '0']
                if not additional_params is None:
                    command += additional_params
                print command[0]
                print '  %s' % ' '.join(command[1:])
                print ''
                print '=' * 80
                print ''
                time.sleep(.5)
                self.process = psutil.Popen(command, stdout=sys.stdout, stderr=sys.stderr)
                #print self.process.status()

            elif OS_WINDOWS:
                print 'Prepare TightVNC...'
                prepare_tightvnc_registry()

                print 'Launch TightVNC...'
                command = [self.vnc, '-run']
                print '%s' % ' '.join(command)
                print ''
                self.process = psutil.Popen(command)
                time.sleep(3)

                print 'Configure TightVNC...'
                command = [self.vnc, '-controlapp', '-shareprimary']
                print '%s' % ' '.join(command)
                print ''
                code = subprocess.call(command)
                if code != 0:
                    print 'Can\'t configure TightVNC!'
                    self.process = None
                    return 0

                print 'Connect TightVNC...'
                command = [self.vnc, '-controlapp', '-connect', '%s' % address]
                print '%s' % ' '.join(command)
                print ''
                code = subprocess.call(command)
                if code != 0:
                    print 'Can\'t establish VNC connection!'
                    self.process = None
                    return 0

            else:
                raise RuntimeError('Platform is not detected!')

            return self.process.pid

        finally:
            self.threadLock.release()

    def stop(self):
        if self.threadLock.locked(): return
        if self.process is None or self.killed: return
        try:
            self.threadLock.acquire()
            if OS_WINDOWS:
                print 'Disconnect TightVNC...'
                command = [self.vnc, '-controlapp', '-disconnectall']
                print '%s' % ' '.join(command)
                print ''
                subprocess.call(command)

                print 'Shutdown TightVNC...'
                command = [self.vnc, '-controlapp', '-shutdown']
                print '%s' % ' '.join(command)
                print ''
                subprocess.call(command)

            else:
                #os.kill(self.returnPID, signal.SIGKILL)
                print ''
                print '=' * 80
                print ''
                children = self.process.children(recursive=True)
                for child in reversed(children):
                    print 'Kill VNC child process (%s)...' % child.pid
                    child.kill()
                print 'Kill VNC main process (%s)...' % self.process.pid
                self.process.kill()

        finally:
            try:
                if not self.tunnel is None:
                    print 'Shutdown SSH tunnel...'
                    self.tunnel.disconnect()
            finally:
                self.tunnel = None

            self.process = None
            self.killed = True
            self.threadLock.release()
