#!/bin/bash
#
# Compile translation files in the "src/locales" directory (from PO to MO).
#
# Copyright 2015-2016 OpenIndex.de.
# Distributed under the MIT License.
# See accompanying LICENSE.txt file or at http://opensource.org/licenses/MIT
#

MSGFMT="msgfmt"
I18N_DOMAIN="Remote-Support-Tool"

export LANG=en
set -e

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOCALES="$BASE_DIR"/src/locales

echo "compiling translations from $LOCALES"
for lang in "$LOCALES"/*
do
  MO="$lang"/LC_MESSAGES/"$I18N_DOMAIN".mo
  PO="$lang"/LC_MESSAGES/"$I18N_DOMAIN".po
  echo "compiling $MO"
  rm -f "$MO"
  "$MSGFMT" -o "$MO" "$PO"
done
echo ".... done."
