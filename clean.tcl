#!/usr/bin/env tclsh
#
# Remove files created from previous builds.
#
# Copyright 2015-2017 OpenIndex.de.
# Distributed under the MIT License.
# See accompanying LICENSE.txt file or at http://opensource.org/licenses/MIT
#

# initialization
source [file join [file normalize [file dirname $argv0]] init.tcl]

puts ""
puts "========================================================================="
puts " $PROJECT $VERSION: cleanup"
puts "========================================================================="
puts ""

if {[file exists $BUILD_DIR]} {
  file delete -force $BUILD_DIR
}
if {[file exists $TARGET_DIR]} {
  file delete -force $TARGET_DIR
}

set utilsBuildDir [file join $UTILS_DIR "build"]
if {[file exists $utilsBuildDir]} {
  file delete -force $utilsBuildDir
}

set utilsTargetDir [file join $UTILS_DIR "target"]
if {[file exists $utilsTargetDir]} {
  file delete -force $utilsTargetDir
}
