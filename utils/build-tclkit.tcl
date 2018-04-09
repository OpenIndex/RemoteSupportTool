#!/usr/bin/env tclsh
#
# Build tclkit for the current platform.
#
# Copyright (c) 2015-2018 OpenIndex.de
# Distributed under the MIT License.
# See accompanying LICENSE.txt file or at http://opensource.org/licenses/MIT
#
# ------------------------------------------------------------------------------
#
# GENERAL NOTES
#
# - This script is used to create tclkit binaries for Linux and Mac OS X.
#
# - Windows should also work with some modifications to this script. But it
#   will require some preparations beforehand (some kind of MinGW environment).
#

set BASE_DIR [file normalize [file dirname $argv0]]
set BUILD_DIR [file join $BASE_DIR "build"]
set TARGET_DIR [file join $BASE_DIR "target" "tclkit"]
set KITCREATOR_DIR [file join $BUILD_DIR "kitcreator-0.10.0"]
set KITCREATOR_URL "http://www.rkeene.org/devel/kitcreator-0.10.0.tar.gz"

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

fconfigure stdout -buffering none
fconfigure stderr -buffering none

if {![file exists $BUILD_DIR]} {
  file mkdir $BUILD_DIR
}

# download
if {![file exists $KITCREATOR_DIR]} {
  puts ""
  puts [string repeat "-" 50]
  puts " Download kitcreator."
  puts [string repeat "-" 50]

  cd $BUILD_DIR
  download $KITCREATOR_URL
  exec -ignorestderr tar xvfz "kitcreator-0.10.0.tar.gz" >@ stdout
}

cd $KITCREATOR_DIR

# cleanup
puts ""
puts [string repeat "-" 50]
puts " Cleanup tclkit."
puts [string repeat "-" 50]

if {[file exists $TARGET_DIR]} {
  file delete -force $TARGET_DIR
}
exec bash kitcreator clean >@ stdout

# make
puts ""
puts [string repeat "-" 50]
puts " Build tclkit."
puts [string repeat "-" 50]

set ::env(STATICTK) "1"
set options {}
lappend options "--disable-xss"
lappend options "--disable-threads"
if {[is_darwin]} {
  lappend options "--enable-aqua"
}
exec bash kitcreator {*}$options >@ stdout

# finish
puts ""
puts [string repeat "-" 50]
puts " Finish build process."
puts [string repeat "-" 50]

set files {}
foreach f [glob -nocomplain -directory $KITCREATOR_DIR -type f  "tclkit-*"] {
  lappend files $f
}
if {[llength $files] < 1} {
  puts "ERROR: No compiled binary was found!"
  exit 1
}
if {![file exists $TARGET_DIR]} {
  file mkdir $TARGET_DIR
}
foreach f $files {
  file copy $f $TARGET_DIR
}
puts "Compiled binaries were saved to:"
puts "$TARGET_DIR"
puts [string repeat "-" 50]
puts ""
exit 0
