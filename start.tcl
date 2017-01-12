#!/usr/bin/env tclsh
#
# Start application from source code.
#
# Copyright 2015-2017 OpenIndex.de.
# Distributed under the MIT License.
# See accompanying LICENSE.txt file or at http://opensource.org/licenses/MIT
#

# initialization
source [file join [file normalize [file dirname $argv0]] init.tcl]

puts ""
puts "========================================================================="
puts " $PROJECT $VERSION: start application"
puts "========================================================================="
puts ""

cd $SRC_DIR
exec $TCLKIT "main.tcl" &
