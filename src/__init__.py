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
__version__ = '0.4'
version_info = tuple([int(num) for num in __version__.split('.')])

import gettext
import os
import platform
import subprocess
import sys
import traceback

from ConfigParser import ConfigParser
from Crypto import __version__ as _pycrypto_version
from paramiko import __version__ as _paramiko_version
from psutil import __version__ as _psutil_version
from PIL import PILLOW_VERSION as _pillow_version
from Tkinter import TclVersion as _tcl_version

OS_DARWIN = sys.platform == 'darwin'
OS_LINUX = sys.platform.find('linux') != -1
OS_WINDOWS = sys.platform == 'win32'
OS_NAME = 'Mac OS X' if OS_DARWIN else 'Windows' if OS_WINDOWS else 'Linux' if OS_LINUX else '???'

if OS_DARWIN:
    from numpy.version import version as _numpy_version


def app_path(*paths):
    """ Get absolute path to the application folder """
    #if getattr(sys, 'frozen', False):
    if is_executed_from_binary():
        path = os.path.dirname(sys.executable)

        if OS_DARWIN:
            # Select application path besides the 'Contents' folder,
            # if the executable was started from a mac application bundle.
            parent = os.path.dirname(path)
            if os.path.basename(path) == 'MacOS' and os.path.basename(parent) == 'Contents':
                path = os.path.dirname(parent)

    else:
        path = os.path.dirname(__file__)

    if len(paths) > 0:
        return os.path.join(path, *paths)
    else:
        return path


def get_configuration(section, option, default=None):
    key = get_configuration_key(section, option)
    if key is None:
        return default
    else:
        return CONFIG.get(key[0], key[1])


def get_configuration_boolean(section, option, default=None):
    key = get_configuration_key(section, option)
    if key is None:
        return default
    else:
        return CONFIG.getboolean(key[0], key[1])


def get_configuration_float(section, option, default=None):
    key = get_configuration_key(section, option)
    if key is None:
        return default
    else:
        return CONFIG.getfloat(key[0], key[1])


def get_configuration_int(section, option, default=None):
    key = get_configuration_key(section, option)
    if key is None:
        return default
    else:
        return CONFIG.getint(key[0], key[1])


def get_configuration_key(section, option):
    if OS_WINDOWS:
        os_section = '%s-windows' % section
    elif OS_DARWIN:
        os_section = '%s-darwin' % section
    elif OS_LINUX:
        os_section = '%s-linux' % section
    else:
        os_section = None

    if CONFIG.has_option(os_section, option):
        return os_section, option
    elif CONFIG.has_option(section, option):
        return section, option
    else:
        return None


def get_default_ssh_keyfile():
    f = get_configuration('settings', 'ssh-keyfile', default=None)
    if not f or not os.path.isfile(f):
        f = os.path.join(app_path(), 'ssh.key')
        if not f or not os.path.isfile(f):
            return None
    return f


def get_default_vnc_application():
    if OS_DARWIN:
        return resource_path('arch', 'darwin', 'vineserver', 'OSXvnc-server')

    elif OS_LINUX:
        if is_x86_64():
            return resource_path('arch', 'linux', 'x11vnc', 'x11vnc-0.9.13_amd64-Linux')
        else:
            return resource_path('arch', 'linux', 'x11vnc', 'x11vnc-0.9.13_i386-none-linux')

    elif OS_WINDOWS:
        return resource_path('arch', 'windows', 'tightvnc', 'tvnserver.exe')

    return None


def get_default_vnc_application_license():
    if OS_DARWIN:
        return 'GPLv2'

    elif OS_LINUX:
        return 'GPLv2'

    elif OS_WINDOWS:
        return 'GPLv2'

    return None


def get_executed_binary():
    if is_executed_from_binary():
        return sys.executable
    else:
        return None


def get_log_file():
    if not is_executed_from_binary():
        return None

    path = os.path.dirname(sys.executable)
    if OS_DARWIN:
        # Write log file besides the 'Contents' folder,
        # if the executable was started from a mac application bundle.
        parent = os.path.dirname(path)
        if os.path.basename(path) == 'MacOS' and os.path.basename(parent) == 'Contents':
            path = os.path.dirname(parent)

    executable = os.path.basename(sys.executable)
    executable = executable.split('.', 2)[0]
    return os.path.join(path, '%s.log' % executable)


def is_executed_from_binary():
    return getattr(sys, 'frozen', False)


def is_x86_64():
    m = platform.machine().lower()
    return m == 'x86_64' or m == 'amd64'


def read_configuration():
    config = ConfigParser()

    # load global configuration file
    global_config = resource_path('resources', 'config_global.ini')
    if os.path.isfile(global_config):
        #print 'load global configuration: %s' % global_config
        with open(global_config, 'r') as f:
            config.readfp(f)

    # load further configuration files
    configs = []

    # The application may provide its own default configuration.
    provided_config = resource_path('resources', 'config.ini')
    if os.path.isfile(provided_config):
        #print 'load provided configuration: %s' % custom_config
        configs.append(provided_config)

    # There may also be a configuration file next to the application binary.
    custom_config = app_path('config.ini')
    if os.path.isfile(custom_config):
        #print 'load custom configuration: %s' % custom_config
        configs.append(custom_config)

    if len(configs) > 0:
        config.read(configs)

    return config


def read_provided_ssh_key():
    from src.SSH import read_private_key_from_file
    #print 'Look for preconfigured SSH key.'

    f = resource_path('resources', 'ssh.key')
    #print '> at %s' % f
    if not f or not os.path.isfile(f):
        #print '> not found'
        return None
    if os.path.getsize(f) < 1:
        #print '> empty'
        return None

    # Read preconfigured SSH key.
    try:
        #print '> read key'
        pwd = get_configuration('settings', 'ssh-provided-key-password', '')
        key = read_private_key_from_file(f, pwd)
    except:
        print 'Preconfigured SSH key is not readable!'
        print traceback.format_exc()
        key = None

    # If the program was started from a binary executable,
    # the SSH key is removed from the temporary application folder after it was read.
    # Hopefully this makes it a bit more difficult to extract the SSH key from an application binary.
    if is_executed_from_binary():
        #print '> remove key file from local disk'
        os.remove(f)

    return key


def resource_path(*paths):
    """ Get absolute path to resource, works for dev and for PyInstaller """
    try:
        # PyInstaller creates a temp folder and stores path in _MEIPASS
        base_path = sys._MEIPASS
    except:
        base_path = os.path.dirname(__file__)

    if len(paths) > 0:
        return os.path.join(base_path, *paths)
    else:
        return base_path


def run_applescript(script):
    if not OS_DARWIN:
        raise RuntimeError('Your operating system does not support AppleScript!')
    return subprocess.check_output(['/usr/bin/osascript', '-e', script])


# initialize internationalization
if OS_WINDOWS:

    # Windows does not provide language environment variables.
    # Therefore the user preferred languages is determined via Windows API.
    from src.thirdparty import gettext_windows
    lang = gettext_windows.get_language()
    t = gettext.translation('Support', resource_path('locales'), fallback=True, languages=lang)
    _ = t.ugettext

else:

    # When the program was started from an application bundle in Mac OS X, the
    # language environment variables are not available. In this case the user
    # preferred languages is determined via AppleScript.
    if OS_DARWIN:
        #language_log = open(app_path('language.log'), 'w', 0)
        is_locale_defined = False
        for var in ('LANGUAGE', 'LC_ALL', 'LC_MESSAGES', 'LANG'):
            lang = os.environ.get(var)
            if not lang is None:
                lang = lang.strip()
            if lang:
                #print 'language found in variable %s = %s' % (var, lang)
                #language_log.write('language found in variable %s = %s\n' % (var, lang))
                is_locale_defined = True
                break

        if not is_locale_defined:
            #print 'no language variable found'
            #language_log.write('no language variable found\n')
            lang = run_applescript('''user locale of (get system info)''')
            if not lang is None:
                lang = lang.strip()
            if lang:
                #print 'found user language %s\n' % lang
                #language_log.write('found user language %s\n' % lang)
                os.environ['LANGUAGE'] = lang

        #language_log.close()

    t = gettext.translation('Remote-Support-Tool', resource_path('locales'), fallback=True)
    _ = t.ugettext


CONFIG = read_configuration()

LOCALHOST = get_configuration('settings', 'localhost', default='127.0.0.1')
TIMEOUT = get_configuration_float('settings', 'timeout', default='30')

COLOR_BG = get_configuration('gui', 'color-background', default='white')
COLOR_BORDER = get_configuration('gui', 'color-border', default='#c0c0c0')
COLOR_STATUS = get_configuration('gui', 'color-status', default='#f0f0f0')

FONT_FAMILY = get_configuration('gui', 'font-family', default='Helvetica')
FONT_TITLE = (FONT_FAMILY, get_configuration_int('gui', 'font-size-title', 12), 'bold')
FONT_SUBTITLE = (FONT_FAMILY, get_configuration_int('gui', 'font-size-subtitle', 10), 'bold')
FONT_SMALL = (FONT_FAMILY, get_configuration_int('gui', 'font-size-small', 9))
FONT_BASE = (FONT_FAMILY, get_configuration_int('gui', 'font-size-base', 10))
FONT_DIALOG = (FONT_FAMILY, get_configuration_int('gui', 'font-size-dialog', 9))
FONT_BUTTON = (FONT_FAMILY, get_configuration_int('gui', 'font-size-button', 9))

TITLE = _('Remote Support Tool')
VERSION = __version__
VERSION_GETTEXT_WINDOWS = '1.0'
VERSION_NUMPY = _numpy_version if OS_DARWIN else None
VERSION_PILLOW = _pillow_version
VERSION_PARAMIKO = _paramiko_version
VERSION_PSUTIL = _psutil_version
VERSION_PYCRYPTO = _pycrypto_version
VERSION_PYTHON = sys.version.split()[0]
VERSION_TCL = _tcl_version
VERSION_TIGHTVNC = '2.7.10'
VERSION_VINESERVER = '4.01'
VERSION_X11VNC = '0.9.13'

VNC_NAME = 'TightVNC' if OS_WINDOWS else 'OSXvnc' if OS_DARWIN else 'x11vnc'
VNC_LAUNCHER = 'tvnserver.exe' if OS_WINDOWS else 'OSXvnc-server' if OS_DARWIN else 'x11vnc'

DEFAULT_VNC_APPLICATION = get_default_vnc_application()
DEFAULT_VNC_APPLICATION_LICENSE = get_default_vnc_application_license()
DEFAULT_SSH_KEYFILE = get_default_ssh_keyfile()
PROVIDED_SSH_KEY = read_provided_ssh_key()
