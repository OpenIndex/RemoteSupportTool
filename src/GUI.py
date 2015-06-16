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
import Tkinter
import tkFileDialog
import tkMessageBox
import traceback
import webbrowser

from src import _
from src import COLOR_BG
from src import COLOR_STATUS
from src import FONT_FAMILY
from src import FONT_TITLE
from src import FONT_SUBTITLE
from src import FONT_SMALL
from src import FONT_BASE
from src import FONT_BUTTON
from src import OS_DARWIN
from src import OS_WINDOWS
from src import TITLE
from src import VERSION
from src import VNC_LAUNCHER
from src import VNC_NAME
from src import resource_path
from src.Imaging import open_photoimage
from src.Settings import Settings
from src.SSH import read_private_key_from_file


class AboutDialog(Tkinter.Toplevel):
    def __init__(self, parent):
        Tkinter.Toplevel.__init__(self, parent)
        self.parent = parent
        self.transient(parent)
        self.initialize()

    def initialize(self):
        from src import VERSION_GETTEXT_WINDOWS
        from src import VERSION_NUMPY
        from src import VERSION_PARAMIKO
        from src import VERSION_PILLOW
        from src import VERSION_PSUTIL
        from src import VERSION_PYCRYPTO
        from src import VERSION_PYTHON
        from src import VERSION_TCL
        from src import VERSION_TIGHTVNC
        from src import VERSION_VINESERVER
        from src import VERSION_X11VNC

        self.title(_('About this program'))
        self.config(background=COLOR_BG)

        # HACK: Programm-Icon setzen
        # siehe http://stackoverflow.com/a/11180300
        #icon = PhotoImage(file=resource_path('resources', 'icon.png'))
        icon = open_photoimage(resource_path('resources', 'icon.png'))
        self.tk.call('wm', 'iconphoto', self._w, icon)

        #self.photo = PhotoImage(file=resource_path('resources', 'about.png'))
        self.photo = open_photoimage(resource_path('resources', 'about.png'), self.winfo_rgb(COLOR_BG))
        Tkinter.Label(self, image=self.photo, background=COLOR_BG, padx=0, pady=0, borderwidth=0)\
            .grid(row=0, column=0, sticky='nw')

        vnc_linux = _('{0} for {1}').format('x11vnc %s (GPLv2)' % VERSION_X11VNC, 'Linux')
        vnc_darwin = _('{0} for {1}').format('VineServer / OSXvnc %s (GPLv2)' % VERSION_VINESERVER, 'Mac OS X')
        vnc_windows = _('{0} for {1}').format('TightVNC %s (GPLv2) ' % VERSION_TIGHTVNC, 'Windows')

        text = Tkinter.Text(self, height=20, width=50, background=COLOR_BG, padx=5, highlightthickness=0, relief=Tkinter.FLAT)
        scroll = Tkinter.Scrollbar(self, command=text.yview)
        text.configure(yscrollcommand=scroll.set)
        text.tag_configure('title', font=FONT_TITLE, wrap=Tkinter.WORD)
        text.tag_configure('subtitle', font=FONT_SUBTITLE, wrap=Tkinter.WORD)
        text.tag_configure('default', font=FONT_BASE, wrap=Tkinter.WORD)
        text.tag_configure('small', font=FONT_SMALL, wrap=Tkinter.WORD)
        text.tag_configure('tiny', font=(FONT_FAMILY, 4), wrap=Tkinter.WORD)
        #text.tag_configure('color', foreground='#476042', font=('Tempus Sans ITC', 12, 'bold'))
        #text.tag_bind('follow', '<1>', lambda e, t=text2: t.insert(Tkinter.END, "Not now, maybe later!"))

        text.insert(Tkinter.END, '%s v%s' % (TITLE, VERSION), 'title')
        text.insert(Tkinter.END, '\n\n', 'tiny')
        text.insert(Tkinter.END, _('This application allows our support staff to access your current desktop.'), 'default')
        text.insert(Tkinter.END, ' ', 'default')
        text.insert(Tkinter.END, _('We will tell you the correct settings in order to build up a connection.'), 'default')
        text.insert(Tkinter.END, '\n\n\n', 'tiny')

        text.insert(Tkinter.END,_('Authors'), 'subtitle')
        text.insert(Tkinter.END, '\n\n', 'tiny')
        text.insert(Tkinter.END, 'Andreas Rudolph & Walter Wagner (OpenIndex.de)', 'default')
        text.insert(Tkinter.END, '\n\n\n', 'tiny')

        text.insert(Tkinter.END, _('Translators'), 'subtitle')
        text.insert(Tkinter.END, '\n\n', 'tiny')
        text.insert(Tkinter.END, _('There are currently no translations available besides the default languages (English and German).'), 'default')
        text.insert(Tkinter.END, '\n\n\n', 'tiny')

        text.insert(Tkinter.END, _('Internal components'), 'subtitle')
        text.insert(Tkinter.END, '\n\n', 'tiny')
        text.insert(Tkinter.END, _('The following third party components were integrated:'), 'default')
        text.insert(Tkinter.END, '\n\n', 'tiny')
        text.insert(Tkinter.END, '• Python %s (PSFL)\n' % VERSION_PYTHON, 'default')
        text.insert(Tkinter.END, '• Tcl/Tk %s (BSD)\n' % VERSION_TCL, 'default')
        text.insert(Tkinter.END, '• PyCrypto %s (Public Domain)\n' % VERSION_PYCRYPTO, 'default')
        text.insert(Tkinter.END, '• Paramiko %s (LGPL)\n' % VERSION_PARAMIKO, 'default')
        text.insert(Tkinter.END, '• Pillow %s (PIL)\n' % VERSION_PILLOW, 'default')
        text.insert(Tkinter.END, '• psutil %s (BSD)\n' % VERSION_PSUTIL, 'default')
        if not VERSION_NUMPY is None:
            text.insert(Tkinter.END, '• NumPy %s (BSD)\n' % VERSION_NUMPY, 'default')
        text.insert(Tkinter.END, '• gettext-py-windows %s (MIT)\n' % VERSION_GETTEXT_WINDOWS, 'default')
        text.insert(Tkinter.END, '• Crystal Clear Icons (LGPL)\n', 'default')
        text.insert(Tkinter.END, '\n\n', 'tiny')

        text.insert(Tkinter.END, _('Integrated VNC applications'), 'subtitle')
        text.insert(Tkinter.END, '\n\n', 'tiny')
        text.insert(Tkinter.END, _('The following third party applications were integrated for VNC connections:'), 'default')
        text.insert(Tkinter.END, '\n\n', 'tiny')
        text.insert(Tkinter.END, u'• %s\n' % vnc_linux, 'default')
        text.insert(Tkinter.END, u'• %s\n' % vnc_darwin, 'default')
        text.insert(Tkinter.END, u'• %s\n' % vnc_windows, 'default')
        text.insert(Tkinter.END, '\n\n', 'tiny')

        text.insert(Tkinter.END, _('Created with'), 'subtitle')
        text.insert(Tkinter.END, '\n\n', 'tiny')
        text.insert(Tkinter.END, _('The application was created with:'), 'default')
        text.insert(Tkinter.END, '\n\n', 'tiny')
        text.insert(Tkinter.END, '• PyCharm Community Edition\n', 'default')
        text.insert(Tkinter.END, '• PyInstaller\n', 'default')
        text.insert(Tkinter.END, '\n\n', 'tiny')

        text.insert(Tkinter.END, _('License'), 'subtitle')
        text.insert(Tkinter.END, '\n\n', 'tiny')
        with open (resource_path('resources', 'license.txt'), 'r') as myfile:
            txt = myfile.read()\
                .replace('\n\n', '$$')\
                .replace('\n', '')\
                .replace('$$', '\n\n')
            text.insert(Tkinter.END, txt, 'default')
        text.insert(Tkinter.END, '\n', 'small')

        #text.insert(Tkinter.END, 'follow-up\n', 'follow')
        #text.pack(side=Tkinter.LEFT, expand=True)

        text.grid(row=0, column=1, rowspan=4, pady=(3,0), sticky='nwes')
        text.config(state=Tkinter.DISABLED)
        scroll.grid(row=0, column=2, rowspan=4, sticky='nes')

        Tkinter.Button(self, text=_('Project at GitHub'), command=self.on_click_github, background=COLOR_BG, font=FONT_BUTTON)\
            .grid(row=1, column=0, padx=6, pady=3, sticky='ews')

        Tkinter.Button(self, text='OpenIndex.de', command=self.on_click_openindex, background=COLOR_BG, font=FONT_BUTTON)\
            .grid(row=2, column=0, padx=6, pady=3, sticky='ews')

        Tkinter.Button(self, text=_('Close'), command=self.on_click_close, background=COLOR_BG, font=FONT_BUTTON)\
            .grid(row=3, column=0, padx=6, pady=3, sticky='ews')

        self.grid_columnconfigure(index=0, weight=0)
        self.grid_columnconfigure(index=1, weight=1)
        self.grid_columnconfigure(index=2, weight=0)
        self.grid_rowconfigure(index=0, weight=1)
        self.grid_rowconfigure(index=1, weight=0)
        self.grid_rowconfigure(index=2, weight=0)
        self.grid_rowconfigure(index=3, weight=0)

        # close dialog with ESC
        self.bind('<Escape>', lambda e: self.destroy())

        # Fokus auf dem Textfeld anfordern
        text.focus_set()

    def on_click_close(self):
        self.destroy()

    def on_click_github(self):
        webbrowser.open_new_tab('https://github.com/OpenIndex')

    def on_click_openindex(self):
        webbrowser.open_new_tab('http://www.openindex.de/')


class AppFrame(Tkinter.Frame):
    def __init__(self, parent):
        Tkinter.Frame.__init__(self, parent)
        self.parent = parent
        self.settings = parent.settings
        self.initialize()

    def initialize(self):
        self.config(background=COLOR_BG)

        # title image
        #self.logo = PhotoImage(file=resource_path('resources', 'logo.png'))
        self.logo = open_photoimage(resource_path('resources', 'logo.png'), self.winfo_rgb(COLOR_BG))
        Tkinter.Label(self, image=self.logo, background=COLOR_BG, padx=0, pady=0, borderwidth=0)\
            .grid(row=0, column=0, rowspan=4, sticky='nw')

        # title text
        Tkinter.Label(self, text='%s v%s' % (TITLE, VERSION), background=COLOR_BG, font=FONT_TITLE, anchor='w', padx=5)\
            .grid(row=0, column=1, pady=(3,0), sticky='nwe')

        # description
        description = _('Use this application in order to allow access on your desktop to our support team.')
        self.description = Tkinter.Label(self, text=description, background=COLOR_BG, font=FONT_SMALL, anchor='w',
                                         padx=5, justify=Tkinter.LEFT)
        self.description.grid(row=1, column=1, sticky='nwe')
        self.description.bind('<Configure>', self.on_resize_description)

        # form fields
        self.connection = AppFrameForm(self)
        self.connection.address.bind('<Return>', self.on_key_enter)
        self.connection.port.bind('<Return>', self.on_key_enter)
        self.connection.grid(row=2, column=1, sticky='we', pady=10, padx=5)

        # some space for separation with dynamic height
        Tkinter.Label(self, background=COLOR_BG).grid(row=3, column=1)

        # form buttons
        self.buttons = AppFrameButtons(self)
        self.buttons.grid(row=4, column=0, columnspan=2, sticky='we')

        # status bar
        self.status = AppFrameStatus(self)
        self.status.grid(row=5, column=0, columnspan=2, sticky='we')
        self.status.set_message(_('Welcome to remote maintenance.'))

        # layout grid
        self.grid_columnconfigure(index=0, weight=0)
        self.grid_columnconfigure(index=1, weight=1)
        self.grid_rowconfigure(index=0, weight=0)
        self.grid_rowconfigure(index=1, weight=0)
        self.grid_rowconfigure(index=2, weight=0)
        self.grid_rowconfigure(index=3, weight=1)
        self.grid_rowconfigure(index=4, weight=0)
        self.grid_rowconfigure(index=5, weight=0)

    def on_click_about(self):
        self.parent.show_about_dialog()

    def on_click_connect(self):
        self.parent.start_thread()

    def on_click_disconnect(self):
        self.parent.stop_thread(True)

    def on_click_settings(self):
        self.parent.show_extended_settings_dialog()

    def on_click_quit(self):
        self.parent.shutdown()

    def on_key_enter(self, event):
        self.parent.start_thread()

    def on_resize_description(self, event):
            pad = 0
            pad += int(str(self.description['bd']))
            pad += int(str(self.description['padx']))
            pad *= 2
            self.description.configure(wraplength=event.width - pad)

    def set_connected(self):
        self.connection.set_disabled()
        self.buttons.set_connected()
        self.status.set_connected()
        self.status.set_message(_('Connection is established.'))

    def set_connecting(self):
        self.connection.set_disabled()
        self.buttons.set_connecting()
        self.status.set_connecting()
        self.status.set_message(_('Establishing a connection...'))

    def set_disconnected(self, show_message=True):
        self.connection.set_enabled()
        self.buttons.set_disconnected()
        self.status.set_disconnected()
        if show_message: self.status.set_message(_('The connection was closed.'))

    def set_error(self, msg=None):
        self.connection.set_enabled()
        self.buttons.set_disconnected()
        self.status.set_error()
        if not msg is None: self.status.set_message(msg)


class AppFrameButtons(Tkinter.Frame):

    def __init__(self, parent):
        Tkinter.Frame.__init__(self, parent)
        self.parent = parent
        self.quit = None
        self.about = None
        self.connect = None
        self.disconnect = None
        self.initialize()
        self.set_disconnected()

    def initialize(self):

        self.quit = Tkinter.Button(self, text=_('Quit'), command=self.parent.on_click_quit, background=COLOR_BG, font=FONT_BUTTON)
        self.quit.grid(row=0, column=0, padx=5, pady=5)

        self.about = Tkinter.Button(self, text=_('About'), command=self.parent.on_click_about, background=COLOR_BG, font=FONT_BUTTON)
        self.about.grid(row=0, column=1, padx=5, pady=5)

        Tkinter.Label(self, background=COLOR_BG)\
            .grid(row=0, column=2, sticky='we')

        self.connect = Tkinter.Button(self, text=_('Connect'), command=self.parent.on_click_connect, background=COLOR_BG, font=FONT_BUTTON)
        self.connect.grid(row=0, column=3, padx=5, pady=5)

        self.disconnect = Tkinter.Button(self, text=_('Disconnect'), command=self.parent.on_click_disconnect, background=COLOR_BG, font=FONT_BUTTON)
        self.disconnect.grid(row=0, column=4, padx=5, pady=5)

        self.grid_columnconfigure(index=0, weight=0)
        self.grid_columnconfigure(index=1, weight=0)
        self.grid_columnconfigure(index=2, weight=1)
        self.grid_columnconfigure(index=3, weight=0)
        self.grid_columnconfigure(index=4, weight=0)
        self.config(background=COLOR_BG, padx=0, pady=0)

    def set_connected(self):
        self.disconnect.config(state=Tkinter.NORMAL)
        self.connect.config(state=Tkinter.DISABLED)
        self.about.config(state=Tkinter.NORMAL)

    def set_connecting(self):
        self.disconnect.config(state=Tkinter.DISABLED)
        self.connect.config(state=Tkinter.DISABLED)
        self.about.config(state=Tkinter.DISABLED)

    def set_disconnected(self):
        self.disconnect.config(state=Tkinter.DISABLED)
        self.connect.config(state=Tkinter.NORMAL)
        self.about.config(state=Tkinter.NORMAL)


class AppFrameForm(Tkinter.Frame):

    def __init__(self, parent):
        Tkinter.Frame.__init__(self, parent)
        self.parent = parent
        self.initialize()

    def initialize(self):

        # Feld für Adresse
        Tkinter.Label(self, text=_('Address'), font=FONT_SMALL, background=COLOR_BG)\
            .grid(row=0, column=0, sticky='e')

        self.address = Tkinter.Entry(self, width=10, textvariable=self.parent.settings.host, font=FONT_BASE, background=COLOR_BG)
        self.address.grid(row=0, column=1, padx=5, sticky='we')
        self.address.focus_set()

        # Feld für Port-Nr
        Tkinter.Label(self, text=_('Port-Nr'), font=FONT_SMALL, background=COLOR_BG)\
            .grid(row=0, column=2, sticky='e')
        self.port = Tkinter.Entry(self, width=5, textvariable=self.parent.settings.port, font=FONT_BASE, background=COLOR_BG)
        self.port.grid(row=0, column=3, padx=5, sticky='we')

        # SSL-Verschlüsselung aktivieren
        self.ssh = Tkinter.Checkbutton(self, text=_('Enable SSH encryption.'), borderwidth=0, highlightthickness=0, relief=Tkinter.FLAT, font=FONT_SMALL, background=COLOR_BG, variable=self.parent.settings.ssh_enabled, offvalue=False, onvalue=True, anchor='w')
        self.ssh.grid(row=1, column=0, columnspan=2, pady=(5,0), sticky='w')

        # Button für erweiterte Optionen
        self.button = Tkinter.Button(self, text=_('Extended...'), command=self.parent.on_click_settings, background=COLOR_BG, font=FONT_BUTTON, pady=0)
        self.button.grid(row=1, column=2, columnspan=2, padx=(0,5), pady=(5,0), sticky='e')

        self.grid_columnconfigure(index=0, weight=0)
        self.grid_columnconfigure(index=1, weight=1)
        self.grid_columnconfigure(index=2, weight=0)
        self.grid_columnconfigure(index=3, weight=0)
        self.config(background=COLOR_BG, padx=0, pady=0)

    def set_enabled(self):
        self.address.config(state=Tkinter.NORMAL)
        self.port.config(state=Tkinter.NORMAL)
        self.ssh.config(state=Tkinter.NORMAL)
        self.button.config(state=Tkinter.NORMAL)
        self.address.focus_set()

    def set_disabled(self):
        self.address.config(state=Tkinter.DISABLED)
        self.port.config(state=Tkinter.DISABLED)
        self.ssh.config(state=Tkinter.DISABLED)
        self.button.config(state=Tkinter.DISABLED)
        self.focus_set()


class AppFrameMenu(Tkinter.Menu):

    def __init__(self, parent):
        Tkinter.Menu.__init__(self, parent)
        self.initialize()

    def initialize(self):
        menu = Tkinter.Menu(self, tearoff=0)
        self.add_cascade(label='File', menu=menu)
        menu.add_command(label='New')


class AppFrameStatus(Tkinter.Frame):

    def __init__(self, parent):
        Tkinter.Frame.__init__(self, parent)
        self.parent = parent
        self.icon = None
        self.icon_connected = open_photoimage(resource_path('resources', 'connect_established.png'), self.winfo_rgb(COLOR_STATUS))
        self.icon_connecting = open_photoimage(resource_path('resources', 'connect_creating.png'), self.winfo_rgb(COLOR_STATUS))
        self.icon_disconnected = open_photoimage(resource_path('resources', 'connect_no.png'), self.winfo_rgb(COLOR_STATUS))
        self.icon_error = open_photoimage(resource_path('resources', 'warning.png'), self.winfo_rgb(COLOR_STATUS))

        #self.icon_connected = PhotoImage(file=resource_path('resources', 'connect_established.png'))
        #self.icon_connecting = PhotoImage(file=resource_path('resources', 'connect_creating.png'))
        #self.icon_disconnected = PhotoImage(file=resource_path('resources', 'connect_no.png'))
        #self.icon_error = PhotoImage(file=resource_path('resources', 'warning.png'))

        self.message = Tkinter.StringVar(value='')
        self.initialize()
        self.set_disconnected()

    def initialize(self):
        self.config(background=COLOR_STATUS)

        Tkinter.Label(self, textvariable=self.message, background=COLOR_STATUS, font=FONT_SMALL, anchor='w', padx=5)\
            .grid(row=0, column=0, sticky='we')

        self.icon = Tkinter.Label(self, background=COLOR_STATUS)
        self.icon.grid(row=0, column=1, sticky='e', padx=5)

        self.grid_columnconfigure(index=0, weight=1)
        self.grid_columnconfigure(index=1, weight=0)

    def set_connected(self):
        self.icon.config(image=self.icon_connected)

    def set_connecting(self):
        self.icon.config(image=self.icon_connecting)

    def set_disconnected(self):
        self.icon.config(image=self.icon_disconnected)

    def set_error(self):
        self.icon.config(image=self.icon_error)

    def set_message(self, message=''):
        self.message.set(message)


class SettingsDialog(Tkinter.Toplevel):
    def __init__(self, parent):
        Tkinter.Toplevel.__init__(self, parent)
        self.parent = parent
        self.settings = Settings()
        self.settings.copy_from(parent.settings)
        self.transient(parent)
        self.initialize()

    def initialize(self):
        self.title(_('Extended Settings'))
        self.config(background=COLOR_BG, padx=0, pady=0)

        #self.photo = PhotoImage(file=resource_path('resources', 'settings.png'))
        self.photo = open_photoimage(resource_path('resources', 'settings.png'), self.winfo_rgb(COLOR_BG))
        Tkinter.Label(self, image=self.photo, background=COLOR_BG, padx=0, pady=0, borderwidth=0)\
            .grid(row=0, column=0, rowspan=11, sticky='nw')

        # settings form
        self.form = SettingsDialogForm(self)
        self.form.grid(row=0, column=1, padx=5, pady=5, sticky='nwe')

        # growing separator
        Tkinter.Label(self, font=FONT_SMALL, background=COLOR_BG)\
            .grid(row=1, column=1, sticky='we')

        # buttons
        buttons = Tkinter.Frame(self, background=COLOR_BG)
        Tkinter.Button(buttons, text=_('Submit'), command=self.on_click_submit, background=COLOR_BG, font=FONT_BUTTON)\
            .grid(row=0, column=1, padx=5, pady=5)
        Tkinter.Button(buttons, text=_('Cancel'), command=self.on_click_cancel, background=COLOR_BG, font=FONT_BUTTON)\
            .grid(row=0, column=2, padx=5, pady=5)
        buttons.grid(row=2, column=1, columnspan=2, sticky='e')

        # layout grid
        self.grid_columnconfigure(index=0, weight=0)
        self.grid_columnconfigure(index=1, weight=1)
        self.grid_rowconfigure(index=1, weight=1)

        # close dialog with ESC
        self.bind('<Escape>', lambda e: self.destroy())

        # Fokus auf dem Textfeld anfordern
        self.form.focus_set()

    def on_click_cancel(self):
        self.destroy()

    def on_click_submit(self):

        messages = []
        self.form.validate(messages)
        if len(messages) > 0:
            txt = _('Incorrect settings!')
            txt += '\n- '
            txt += '\n- '.join(messages)
            tkMessageBox.showerror(title=_('Incorrect settings!'), message=txt, parent=self)
            return

        # copy values into application settings
        self.parent.settings.copy_from(self.settings)

        # unregister VNC application, if the default application is enabled
        if self.form.is_custom_vnc_app():
            self.parent.settings.vnc_application.set('')

        self.destroy()


class SettingsDialogForm(Tkinter.Frame):
    def __init__(self, parent):
        Tkinter.Frame.__init__(self, parent)
        self.parent = parent
        self.settings = parent.settings
        self.custom_vnc_app = Tkinter.BooleanVar(value=self.settings.vnc_application.get() == '')
        self.initialize()
        self.update_form()

    def initialize(self):
        self.config(background=COLOR_BG)
        row = -1

        # VNC settings title
        row += 1
        Tkinter.Label(self, text=_('Settings for VNC') + ' (%s)' % VNC_NAME, font=FONT_TITLE, background=COLOR_BG)\
            .grid(row=row, column=0, columnspan=3, sticky='w')

        # VNC application
        row += 1
        Tkinter.Label(self, text=_('Application file').format(VNC_LAUNCHER), font=FONT_SMALL, background=COLOR_BG)\
            .grid(row=row, column=0, padx=5, sticky='e')
        self.vnc_app = Tkinter.Entry(self, width=10, textvariable=self.settings.vnc_application, font=FONT_BASE, background=COLOR_BG)
        self.vnc_app.grid(row=row, column=1, sticky='we')
        self.vnc_button = Tkinter.Button(self, text=_('Select'), command=self.on_click_vnc_select, background=COLOR_BG, font=FONT_BUTTON, pady=0)
        self.vnc_button.grid(row=row, column=2, sticky='nwes')
        row += 1
        Tkinter.Checkbutton(self, text=_('Use internal program.'), borderwidth=0, highlightthickness=0, relief=Tkinter.FLAT, font=FONT_SMALL, background=COLOR_BG, variable=self.custom_vnc_app, offvalue=False, onvalue=True, command=self.update_form)\
            .grid(row=row, column=1, columnspan=2, sticky='w')

        # VNC options (x11vnc only)
        if not OS_WINDOWS:
            row += 1
            Tkinter.Label(self, text=_('Parameters'), font=FONT_SMALL, background=COLOR_BG)\
                .grid(row=row, column=0, padx=5, pady=1, sticky='e')
            Tkinter.Entry(self, width=10, textvariable=self.settings.vnc_parameters, font=FONT_BASE, background=COLOR_BG)\
                .grid(row=row, column=1, columnspan=2, pady=1, sticky='we')

        # SSH settings title
        row += 1
        Tkinter.Label(self, text=_('Settings for SSH'), font=FONT_TITLE, background=COLOR_BG)\
            .grid(row=row, column=0, columnspan=3, pady=(3,0), sticky='w')

        # SSH port
        row += 1
        Tkinter.Label(self, text=_('SSH Port-Nr'), font=FONT_SMALL, background=COLOR_BG)\
            .grid(row=row, column=0, padx=5, pady=1, sticky='e')
        Tkinter.Entry(self, width=10, textvariable=self.settings.ssh_port, font=FONT_BASE, background=COLOR_BG)\
            .grid(row=row, column=1, columnspan=2, sticky='we')

        # SSH user
        row += 1
        Tkinter.Label(self, text=_('User'), font=FONT_SMALL, background=COLOR_BG)\
            .grid(row=row, column=0, padx=5, pady=1, sticky='e')
        Tkinter.Entry(self, width=10, textvariable=self.settings.ssh_user, font=FONT_BASE, background=COLOR_BG)\
            .grid(row=row, column=1, columnspan=2, pady=1, sticky='we')

        # SSH password
        row += 1
        Tkinter.Label(self, text=_('Password'), font=FONT_SMALL, background=COLOR_BG)\
            .grid(row=row, column=0, padx=5, pady=1, sticky='e')
        Tkinter.Entry(self, width=10, textvariable=self.settings.ssh_password, font=FONT_BASE, background=COLOR_BG)\
            .grid(row=row, column=1, columnspan=2, pady=1, sticky='we')

        # SSH keyfile
        row += 1
        Tkinter.Label(self, text=_('Private Key'), font=FONT_SMALL, background=COLOR_BG)\
            .grid(row=row, column=0, padx=5, pady=1, sticky='e')
        Tkinter.Entry(self, width=10, textvariable=self.settings.ssh_keyfile, font=FONT_BASE, background=COLOR_BG)\
            .grid(row=row, column=1, pady=1, sticky='we')
        Tkinter.Button(self, text=_('Select'), command=self.on_click_ssh_keyfile_select, background=COLOR_BG, font=FONT_BUTTON, pady=0)\
            .grid(row=row, pady=1, column=2, sticky='e')

        # layout grid
        self.grid_columnconfigure(index=0, weight=0)
        self.grid_columnconfigure(index=1, weight=1)
        self.grid_columnconfigure(index=2, weight=0)

    def is_custom_vnc_app(self):
        return self.custom_vnc_app.get() == True

    def on_click_vnc_select(self):

        title = _('Select VNC application \'{0}\'.').format(VNC_LAUNCHER)
        defaultextension = '.exe' if OS_WINDOWS else ''

        # Mac OS X does not support filetype filters in file dialogs.
        # Therefore we need to provide an empty list. Otherwise the file dialog is not properly rendered.
        filetypes = []
        if not OS_DARWIN:
            if OS_WINDOWS: filetypes.append((_('executable files'), '.exe'))
            filetypes.append((_('all files'), '.*'))

        vnc = self.settings.get_vnc_application(default=None)
        if vnc is None:
            initialdir = os.path.expanduser('~')
            initialfile = None
        else:
            initialdir = os.path.dirname(vnc)
            initialfile = os.path.basename(vnc)

        path = tkFileDialog.askopenfilename(title=title, defaultextension=defaultextension, filetypes=filetypes,
                                            initialdir=initialdir, initialfile=initialfile)
        if path:
            #print 'selected vnc app: %s' % path
            self.settings.vnc_application.set(path)

    def on_click_ssh_keyfile_select(self):

        title = _('Select SSH private key file.')
        defaultextension = ''

        # Mac OS X does not support filetype filters in file dialogs.
        # Therefore we need to provide an empty list. Otherwise the file dialog is not properly rendered.
        filetypes = []
        if not OS_DARWIN:
            filetypes = [(_('all files'), '.*')]

        vnc = self.settings.get_ssh_keyfile(default=None)
        if vnc is None:
            initialdir = os.path.expanduser('~')
            initialfile = None
        else:
            initialdir = os.path.dirname(vnc)
            initialfile = os.path.basename(vnc)

        path = tkFileDialog.askopenfilename(title=title, defaultextension=defaultextension, filetypes=filetypes,
                                            initialdir=initialdir, initialfile=initialfile)
        if path:
            #print 'selected ssh keyfile: %s' % path
            self.settings.ssh_keyfile.set(path)

    def update_form(self):
        #print 'update form'
        if self.is_custom_vnc_app():
            self.vnc_app.config(state=Tkinter.DISABLED)
            self.vnc_button.config(state=Tkinter.DISABLED)
        else:
            self.vnc_app.config(state=Tkinter.NORMAL)
            self.vnc_button.config(state=Tkinter.NORMAL)

    def validate(self, messages):
        count = len(messages)

        # validate VNC application
        if not self.is_custom_vnc_app():
            vnc = self.settings.get_vnc_application(default=None)
            if vnc is None or vnc == '':
                messages.append(_('No VNC application was specified.'))
            elif not os.path.isfile(vnc):
                messages.append(_('The VNC application does not point to a file.'))

        # validate SSH user
        user = self.settings.get_ssh_user(default=None)
        if user is None:
            messages.append(_('No SSH user name was specified.'))

        # validate SSH keyfile
        password = self.settings.get_ssh_password()
        keyfile = self.settings.get_ssh_keyfile(default=None)
        if not keyfile is None:
            if not os.path.isfile(keyfile):
                messages.append(_('The private key file is invalid.'))
            else:
                try:
                    read_private_key_from_file(keyfile, password=password)
                except:
                    print(traceback.format_exc())
                    messages.append(_('Can\'t open private key with the provided password.'))

        # validate SSH port
        port = self.settings.get_ssh_port(default=None)
        if port is None:
            messages.append(_('The SSH port number is invalid.'))
        elif port < 0 or port > 65535:
            messages.append(_('The SSH port number is not in the interval from {0} to {1}.').format(1, 65535))

        return len(messages) > count
