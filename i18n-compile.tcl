#!/usr/bin/env tclsh
#
# Compile messages (msg files) from translation files (po files).
#
# Copyright 2015-2017 OpenIndex.de.
# Distributed under the MIT License.
# See accompanying LICENSE.txt file or at http://opensource.org/licenses/MIT
#

# initialization
source [file join [file normalize [file dirname $argv0]] init.tcl]

puts ""
puts "========================================================================="
puts " $PROJECT $VERSION: compile translations"
puts "========================================================================="
puts ""

if {$MSGFMT == "" || ![file isfile $MSGFMT] || ![file executable $MSGFMT]} {
  puts "ERROR: Can't find the msgfmt application!"
  exit 1
}

# Remove old translation files.
foreach msg [glob -nocomplain -directory $SRC_MSGS_DIR -type f  "*.msg"] {
  puts "remove $msg"
  file delete $msg
}

# Build new translation files.
foreach po [glob -nocomplain -directory $I18N_PO_DIR -type f  "*.po"] {
  puts "compile $po"

  set name [file tail $po]
  set pos [string last "." $name]
  if {$pos<1} {
    puts "ERROR: invalid translation file at $po"
  }
  set lang [string range $name 0 [expr {$pos - 1}]]
  set msg [file join $SRC_MSGS_DIR [concat $name ".msg"]]

  if { [catch {exec $MSGFMT --tcl $po -l $lang -d $SRC_MSGS_DIR} result] } {
    puts "ERROR: Can't compile translation!"
    puts "at: $po"
    puts $::errorInfo
  }
}
