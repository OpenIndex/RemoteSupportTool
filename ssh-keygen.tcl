#!/usr/bin/env tclsh
#
# Generate a keypair for SSH encryption.
#
# Copyright (c) 2015-2018 OpenIndex.de
# Distributed under the MIT License.
# See accompanying LICENSE.txt file or at http://opensource.org/licenses/MIT
#

# initialization
source [file join [file normalize [file dirname $argv0]] init.tcl]

puts ""
puts "========================================================================="
puts " $PROJECT $VERSION: generate SSH keypair"
puts "========================================================================="
puts ""
puts "NOTE: Do not enter a passphrase in order to use the SSH key properly"
puts "within the application!"
puts ""

set KEY_FILE [file join $BASE_DIR "misc" "ssh.key"]

if {[is_windows]} {
  set SSH_KEYGEN [file join $SRC_DIR "data" "windows" "openssh" "bin" "ssh-keygen.exe"]
} else {
  set SSH_KEYGEN [which "ssh-keygen"]
}

if {$SSH_KEYGEN == "" || ![file isfile $SSH_KEYGEN] || ![file executable $SSH_KEYGEN]} {
  puts "ERROR: Can't find the ssh-keygen application!"
  exit 1
}

exec [file nativename $SSH_KEYGEN] -t rsa -b 4096 -f $KEY_FILE >@ stdout

puts ""
puts "-------------------------------------------------------------------------"
puts " Your SSH keypair was saved at"
puts " $KEY_FILE"
puts " $KEY_FILE.pub"
puts "-------------------------------------------------------------------------"
puts ""
puts "Provide 'ssh.key' together with the application in order to allow"
puts "encrypted connections through SSH."
puts ""
puts "Put 'ssh.key.pub' into the 'authorized_keys' file on the machine of the"
puts "support staff."
puts ""
