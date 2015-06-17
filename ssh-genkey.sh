#!/bin/bash
#
# Generate a SSH keypair and save its files into "misc/ssh.key" and "misc/ssh.key.pub".
#
# Copyright 2015 OpenIndex.de.
# Distributed under the MIT License.
# See accompanying LICENSE.txt file or at http://opensource.org/licenses/MIT
#

KEYGEN="ssh-keygen"

export LANG=en
set -e

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SSH_KEY="$BASE_DIR"/misc/ssh.key

echo ""
echo "Generate a SSH keypair for encrypted remote maintenance."
echo ""

$KEYGEN -t rsa -b 4096 -f "$SSH_KEY"

echo ""
echo -en "\e[1m"
echo "--------------------------------------------------------------------"
echo " Your SSH keypair was saved at"
echo " $SSH_KEY"
echo " $SSH_KEY.pub"
echo "--------------------------------------------------------------------"
echo -en "\e[0m"
echo ""
echo "Provide 'ssh.key' together with the application in order to allow"
echo "encrypted connections through SSH."
echo ""
echo "Put 'ssh.key.pub' into the 'authorized_keys' file of the user on the"
echo "machine of the support staff."
echo ""
