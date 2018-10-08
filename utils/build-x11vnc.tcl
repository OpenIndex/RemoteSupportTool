#!/usr/bin/env tclsh
#
# Build x11vnc for the current platform.
#
# Copyright (c) 2015-2018 OpenIndex.de
# Distributed under the MIT License.
# See accompanying LICENSE.txt file or at http://opensource.org/licenses/MIT
#
# ------------------------------------------------------------------------------
#
# GENERAL NOTES
#
# - This script is currently only used on Linux systems.
#
# - Mac OS X seems to be supported by x11vnc. But we currently did not manage
#   to make the compiled binary work properly. Therefore we're currently using
#   a precompiled OSXvnc for Mac OS X (https://github.com/stweil/OSXvnc).
#
# - Windows is not supported by x11vnc. Therefore this script cannot be used on
#   these systems. Instead we're currently using a precompiled TightVNC for
#   Windows (http://www.tightvnc.com/).
#

set BASE_DIR [file normalize [file dirname $argv0]]
set BUILD_DIR [file join $BASE_DIR "build"]
set TARGET_DIR [file join $BASE_DIR "target" "x11vnc"]
set X11VNC_DIR [file join $BUILD_DIR "x11vnc-0.9.13"]
set X11VNC_URL "http://downloads.sourceforge.net/project/libvncserver/x11vnc/0.9.13/x11vnc-0.9.13.tar.gz"

proc download {url} {
  if {![catch {exec which wget} wget]} {
    exec wget -q $url >@ stdout
    return 1
  }
  if {![catch {exec which curl} curl]} {
    exec curl -L -O -s $url >@ stdout
    return 1
  }
  error "Can't download '$url'! Neither wget nor curl is available."
}

proc is_darwin {} {
  global tcl_platform
  set os [string tolower $tcl_platform(os)]
  return [string match "darwin*" $os]
}

proc is_linux {} {
  global tcl_platform
  set os [string tolower $tcl_platform(os)]
  return [string match "linux*" $os]
}

proc is_windows {} {
  global tcl_platform
  set os [string tolower $tcl_platform(os)]
  return [string match "windows*" $os]
}

if {[is_windows]} {
  error "Building x11vnc for Windows is not supported!"
}

fconfigure stdout -buffering none
fconfigure stderr -buffering none

if {![file exists $BUILD_DIR]} {
  file mkdir $BUILD_DIR
}

# download
if {![file exists $X11VNC_DIR]} {
  puts ""
  puts [string repeat "-" 50]
  puts " Download x11vnc."
  puts [string repeat "-" 50]

  cd $BUILD_DIR
  download $X11VNC_URL
  exec -ignorestderr tar xvfz "x11vnc-0.9.13.tar.gz" >@ stdout
}

cd $X11VNC_DIR

# cleanup
puts ""
puts [string repeat "-" 50]
puts " Cleanup x11vnc."
puts [string repeat "-" 50]

if {[file exists $TARGET_DIR]} {
  file delete -force $TARGET_DIR
}
if {[catch {exec make clean >@ stdout}]} {
  puts "No cleanup was executed."
  puts $::errorInfo
}

# configure
puts ""
puts [string repeat "-" 50]
puts " Configure x11vnc."
puts [string repeat "-" 50]

set options {}
lappend options "--without-avahi"
lappend options "--without-jpeg"
lappend options "--without-macosx-native"
lappend options "--without-ssl"
lappend options "--without-gnutls"
lappend options "--without-crypt"
lappend options "--without-crypto"
lappend options "--without-client-tls"
lappend options "--without-xinerama"
exec bash configure {*}$options >@ stdout

# make
puts ""
puts [string repeat "-" 50]
puts " Build x11vnc."
puts [string repeat "-" 50]

exec -ignorestderr make >@ stdout

# finish
puts ""
puts [string repeat "-" 50]
puts " Finished build process."
puts [string repeat "-" 50]

set output [file join $X11VNC_DIR "x11vnc" "x11vnc"]
if {![file isfile $output]} {
  puts "ERROR: No compiled binary was found!"
  exit 1
}
if {![file exists $TARGET_DIR]} {
  file mkdir $TARGET_DIR
}
file copy $output $TARGET_DIR
puts "Compiled binaries were saved to:"
puts "$TARGET_DIR"
puts [string repeat "-" 50]
puts ""
exit 0
