#!/bin/bash
#
# Merge translations from "misc/Remote-Support-Tool.pot" into PO files.
#
# Copyright 2015-2016 OpenIndex.de.
# Distributed under the MIT License.
# See accompanying LICENSE.txt file or at http://opensource.org/licenses/MIT
#

MSGMERGE="msgmerge"
I18N_DOMAIN="Remote-Support-Tool"

export LANG=en
set -e

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOCALES="$BASE_DIR"/src/locales
POT="$BASE_DIR"/misc/"$I18N_DOMAIN".pot
PO="$I18N_DOMAIN".po

echo "merging $POT"
echo "into $LOCALES"
cd "$LOCALES"
find . -type f -name "$PO" -exec "$MSGMERGE" -U '{}' "$POT" \;
