#!/usr/bin/env tclsh
#
# Extract translations from source codes into a translation template (pot file).
#
# Copyright 2015-2017 OpenIndex.de.
# Distributed under the MIT License.
# See accompanying LICENSE.txt file or at http://opensource.org/licenses/MIT
#

# initialization
source [file join [file normalize [file dirname $argv0]] init.tcl]

puts ""
puts "========================================================================="
puts " $PROJECT $VERSION: extract translations"
puts "========================================================================="
puts ""

if {$XGETTEXT == "" || ![file isfile $XGETTEXT] || ![file executable $XGETTEXT]} {
  puts "ERROR: Can't find the xgettext application!"
  exit 1
}

puts "recreate $I18N_POT"
if {[file exists $I18N_POT]} {
  file delete $I18N_POT
}
touch $I18N_POT

cd $SRC_APP_DIR
foreach tcl [glob -nocomplain -directory $SRC_APP_DIR -type f  "*.tcl"] {
  puts "process $tcl"
  set f [file tail $tcl]
  if { [catch {exec $XGETTEXT -j -c -o [file nativename $I18N_POT] -L Tcl -k_ --copyright-holder=$AUTHOR_NAME --msgid-bugs-address=$AUTHOR_EMAIL $f} result] } {
    puts "ERROR: Can't extract translation!"
    puts "from: $tcl"
    puts $::errorInfo
  }
}
