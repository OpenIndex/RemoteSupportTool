#!/usr/bin/env tclsh
#
# Merge translation template (pot file) into translation files (po files).
#
# Copyright 2015-2017 OpenIndex.de.
# Distributed under the MIT License.
# See accompanying LICENSE.txt file or at http://opensource.org/licenses/MIT
#

# initialization
source [file join [file normalize [file dirname $argv0]] init.tcl]

puts ""
puts "========================================================================="
puts " $PROJECT $VERSION: merge translations"
puts "========================================================================="
puts ""

if {$MSGMERGE == "" || ![file isfile $MSGMERGE] || ![file executable $MSGMERGE]} {
  puts "ERROR: Can't find the msgmerge application!"
  exit 1
}

foreach po [glob -nocomplain -directory $I18N_PO_DIR -type f  "*.po"] {
  puts "merge $po"
  if { [catch {exec $MSGMERGE -q -U $po $I18N_POT} result] } {
    puts "ERROR: Can't merge translation!"
    puts "at: $po"
    puts $::errorInfo
  }
}
