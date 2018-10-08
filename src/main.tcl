#!/usr/bin/env tclsh
#
# Copyright (c) 2015-2018 OpenIndex.de
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

# Set application version.
# Make sure to update lib/app-support/pkgIndex.tcl, if the version is changed.
set _APP_VERSION "0.5.1"

# Set type of application.
# If the starkit namespace is available, we're assuming the application was
# launched from a tclkit.
set _APP_WRAPPED [namespace exists starkit]

# Application is launched with tclkit.
if { $_APP_WRAPPED == 1 } {
  #puts "launching application with tclkit"

  # Set application root directory.
  # The application directory is detected from the starkit environment.
  package require starkit
  starkit::startup
  set _APP_DIR $starkit::topdir
}

# Application is launched without tclkit, e.g. via regular tclsh.
if { $_APP_WRAPPED != 1 } {
  #puts "launching application without tclkit"

  # Set application root directory.
  # The application directory is detected from the executed script.
  set _APP_DIR [file dirname [file normalize $argv0]]

  # Put lib directory into auto_path variable.
  set auto_path [linsert $auto_path 0 [file join $_APP_DIR "lib"]]
}

# Load application package.
package require app-support $_APP_VERSION
::support::launch $_APP_DIR $_APP_WRAPPED $_APP_VERSION

# Keep global namespace clean.
unset _APP_DIR
unset _APP_VERSION
unset _APP_WRAPPED
