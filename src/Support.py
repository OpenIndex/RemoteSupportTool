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

import os
import socket
import sys
import thread
import Tkinter
import tkMessageBox

from src import _
from src import COLOR_BG
from src import DEFAULT_VNC_APPLICATION
from src import FONT_DIALOG
from src import OS_DARWIN
from src import TIMEOUT
from src import TITLE
from src import get_configuration_int
from src import get_log_file
from src import resource_path
from src import run_applescript
from src.GUI import AboutDialog
from src.GUI import AppFrame
from src.GUI import SettingsDialog
from src.Imaging import open_photoimage
from src.Settings import Settings
from src.VNC import VNC


def center(win):
    """
    centers a tkinter window
    :param win: the root or Toplevel window to center
    """

    # The "tk::PlaceWindow" throws an error in OS X.
    # Therefore the window is centered manually in this case.
    if OS_DARWIN:
        win.update_idletasks()
        width = win.winfo_width()
        frm_width = win.winfo_rootx() - win.winfo_x()
        win_width = width + 2 * frm_width
        height = win.winfo_height()
        titlebar_height = win.winfo_rooty() - win.winfo_y()
        win_height = height + titlebar_height + frm_width
        x = win.winfo_screenwidth() // 2 - win_width // 2
        y = win.winfo_screenheight() // 2 - win_height // 2
        win.geometry('{}x{}+{}+{}'.format(width, height, x, y))
        win.deiconify()

    else:
        win.eval('tk::PlaceWindow %s center' % win.winfo_pathname(win.winfo_id()))


class Application(Tkinter.Tk):
    def __init__(self):
        Tkinter.Tk.__init__(self)
        self.attributes('-alpha', 0.0)
        self.thread = None
        self.threadLock = thread.allocate_lock()
        self.settings = Settings()
        self.initialize()

    def initialize(self):

        self.title(TITLE)
        self.config(background=COLOR_BG)

        # HACK: set application icon
        # see http://stackoverflow.com/a/11180300
        icon = open_photoimage(resource_path('resources', 'icon.png'))
        self.tk.call('wm', 'iconphoto', self._w, icon)

        # create application frame
        self.frame = AppFrame(self)
        self.frame.pack(fill=Tkinter.BOTH, expand=1)

        # Specific modifications for Mac OS X systems
        if OS_DARWIN:

            # Add an empty main menu.
            menu = Tkinter.Menu(self)
            try:
                self.config(menu=menu)
            except AttributeError:
                # master is a toplevel window (Python 1.4/Tkinter 1.63)
                self.tk.call(self, 'config', '-menu', menu)

            # Register about dialog.
            self.createcommand('tkAboutDialog', self.show_about_dialog)

        # event on window close
        self.protocol('WM_DELETE_WINDOW', self.shutdown)

        # close window with ESC
        #self.bind('<Escape>', lambda e: self.on_close())

        # set window size
        #self.resizable(False,False)
        #self.resizable(width=False, height=False)
        w = get_configuration_int('gui', 'application-window-width', 500)
        h = get_configuration_int('gui', 'application-window-height', 300)
        self.geometry('%sx%s' % (w, h))

    def mainloop(self, n=0):
        self.attributes('-alpha', 1.0)
        Tkinter.Tk.mainloop(self, n=n)

    def set_connected(self):
        if self.threadLock.locked(): return
        try:
            self.threadLock.acquire()
            self.frame.set_connected()
        finally:
            self.threadLock.release()

    def set_connecting(self):
        if self.threadLock.locked(): return
        try:
            self.threadLock.acquire()
            self.frame.set_connecting()
        finally:
            self.threadLock.release()

    def set_disconnected(self, show_message=True):
        if self.threadLock.locked(): return
        try:
            self.threadLock.acquire()
            self.frame.set_disconnected(show_message=show_message)
        finally:
            self.threadLock.release()

    def set_error(self, msg=None):
        if self.threadLock.locked(): return
        try:
            self.threadLock.acquire()
            self.frame.set_error(msg=msg)
        finally:
            self.threadLock.release()

    def show_about_dialog(self):
        dlg = AboutDialog(self)
        #self.eval('tk::PlaceWindow %s center' % dlg.winfo_pathname(dlg.winfo_id()))

        x = self.winfo_rootx()
        y = self.winfo_rooty()
        w = get_configuration_int('gui', 'about-window-width', 550)
        h = get_configuration_int('gui', 'about-window-height', 350)
        dlg.geometry('%sx%s+%d+%d' % (w, h, x+25, y+25))

        dlg.grab_set()
        self.wait_window(dlg)

    def show_extended_settings_dialog(self):
        dlg = SettingsDialog(self)
        #self.eval('tk::PlaceWindow %s center' % dlg.winfo_pathname(dlg.winfo_id()))

        x = self.winfo_rootx()
        y = self.winfo_rooty()
        w = get_configuration_int('gui', 'settings-window-width', 550)
        h = get_configuration_int('gui', 'settings-window-height', 350)
        dlg.geometry('%sx%s+%d+%d' % (w, h, x+25, y+25))

        dlg.grab_set()
        self.wait_window(dlg)

    def shutdown(self):
        self.stop_thread()
        self.destroy()

    def start_thread(self):
        self.stop_thread(False)

        # validate hostname
        host = self.settings.get_host()
        if host is None:
            self.set_error(msg=_('The address in invalid.'))
            return

        # validate port number
        port = self.settings.get_port()
        if port is None:
            self.set_error(msg=_('The port number is invalid.'))
            return
        if port < 0 or port > 65535:
            self.set_error(_('The port number is not in the interval from {0} to {1}.').format(1, 65535))
            return

        #print 'connecting to %s:%s' % (host, port)
        self.set_connecting()
        self.thread = VNC(self, self.settings)
        self.thread.start()

    def stop_thread(self, show_message=True):
        if not self.thread is None:
            self.thread.kill()
        self.thread = None
        self.set_disconnected(show_message)


if __name__ == '__main__':
    try:
        # Redirect stdin & stderr into a log file,
        # if the program was started via executable binary.
        stdout = None
        logfile = get_log_file()
        if not logfile is None:
            stdout = open(logfile, 'w', 0)
            sys.stdout = stdout
            sys.stderr = sys.stdout

        #print 'default vnc application: %s' % DEFAULT_VNC_APPLICATION
        if DEFAULT_VNC_APPLICATION is None:
            top = Tkinter.Tk()
            top.option_add('*Dialog.msg.font', FONT_DIALOG)
            top.iconify()
            msg = _('Unfortunately your operating system ({0}) is not supported.').format(sys.platform)
            #print msg
            tkMessageBox.showerror(title=_('Error on startup!'), message=msg)
            sys.exit(1)

        socket.setdefaulttimeout(TIMEOUT)

        #import pprint
        #pp = pprint.PrettyPrinter(indent=4)
        #print ''
        #print '-'*80
        #print ' env'
        #print '-'*80
        #pp.pprint(os.environ.data)
        #print ''
        #print '-'*80
        #print ''

        app = Application()
        app.option_add('*Dialog.msg.font', FONT_DIALOG)

        # Center the application window on the screen.
        center(app)

        # Mac OS X does not put the application window into foreground.
        # As long as we find no better solution, the application is put into foreground via AppleScript.
        if OS_DARWIN:
            pid = os.getpid()
            #print 'PID: %s' % pid
            run_applescript('''
                tell application "System Events"
                  set frontmost of the first process whose unix id is ''' + str(pid) + ''' to true
                end tell''')

        app.mainloop()

    finally:
        if not stdout is None:
            stdout.close()
