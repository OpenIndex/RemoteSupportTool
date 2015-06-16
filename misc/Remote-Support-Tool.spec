# -*- mode: python -*-

import glob
import os
import platform
import sys

DEBUG = False
NAME = 'Remote-Support-Tool'
EXCLUCES = []

BASE_DIR = os.getcwd()
SRC_DIR = os.path.join(BASE_DIR, 'src')
RES_DIR = os.path.join(SRC_DIR, 'resources')
I18N_DIR = os.path.join(SRC_DIR, 'locales')

if sys.platform == 'darwin':
    ARCH = 'darwin'
    ARCH_ICON = os.path.join(BASE_DIR, 'misc', 'darwin', 'Remote-Support-Tool.icns')
    ARCH_VERSION = None

elif sys.platform.find('linux') != -1:
    ARCH = 'linux'
    ARCH_ICON = None
    ARCH_VERSION = None
    EXCLUCES.append('numpy')

    m = platform.machine().lower()
    is_amd64 = m == 'x86_64' or m == 'amd64'
    if is_amd64: NAME += '_linux-amd64'
    else: NAME += '_linux-i386'

elif sys.platform == 'win32':
    ARCH = 'windows'
    ARCH_ICON = os.path.join(BASE_DIR, 'misc', 'windows', 'Remote-Support-Tool.ico')
    ARCH_VERSION = os.path.join(BASE_DIR, 'misc', 'windows', 'Version.txt')
    EXCLUCES.append('numpy')
    NAME += '.exe'

else:
    raise RuntimeError('Your operating system is not supported (%s)!' % sys.platform )

ARCH_DIR = os.path.join(SRC_DIR, 'arch', ARCH)

#print 'BASE DIRECTORY : %s' % BASE_DIR
#print 'SOURCE CODES   : %s' % SRC_DIR
#print 'RESOURCES      : %s' % RES_DIR
#print 'LOCALES        : %s' % I18N_DIR
#print 'APPLICATIONS   : %s' % ARCH_DIR


#
# Start Analysis to find the files the program needs.
#

a = Analysis([os.path.join('src', 'Support.py')],
             pathex=[BASE_DIR,],
             hiddenimports=[],
             excludes=EXCLUCES,
             hookspath=None,
             runtime_hooks=None)

# append resources
a.datas += Tree(RES_DIR, prefix='resources')

# append external applications for the current arch
a.datas += Tree(ARCH_DIR, prefix=os.path.join('arch', ARCH))

# append locales
#locales = []
for f in glob.glob(os.path.join(I18N_DIR, '*', 'LC_MESSAGES', '*.mo')):
    lang = os.path.basename(os.path.dirname(os.path.dirname(f)))
    name = os.path.basename(f)
    #print 'FOUND LOCALE FOR %s: %s' % (lang, f)
    #locales.append(('locales/%s/LC_MESSAGES/%s' % (lang,name), f, 'DATA'))
    a.datas += [('locales/%s/LC_MESSAGES/%s' % (lang,name), f, 'DATA')]
#a.datas += locales


#
# Build PYZ archive with required modules.
#

pyz = PYZ(a.pure)


#
# Create an executable.
#

exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          name=NAME,
          debug=DEBUG,
          icon=ARCH_ICON,
          version=ARCH_VERSION,
          strip=None,
          upx=True,
          console=False )

#
# Create an application bundle for OS X.
#

if sys.platform == 'darwin':
    app = BUNDLE(exe,
                 name='%s.app' % NAME,
                 icon=ARCH_ICON)
