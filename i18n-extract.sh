#!/bin/bash
#
# Extract translations from the source code into "misc/Remote-Support-Tool.pot".
#
# Copyright 2015-2016 OpenIndex.de.
# Distributed under the MIT License.
# See accompanying LICENSE.txt file or at http://opensource.org/licenses/MIT
#

XGETTEXT="xgettext"
I18N_DOMAIN="Remote-Support-Tool"
PACKAGE="Remote Support Tool"
PACKAGE_VERSION="0.4"
COPYRIGHT="OpenIndex"
MAIL="info@openindex.de"

export LANG=en
set -e

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SRC="$BASE_DIR"/src
POT="$BASE_DIR"/misc/"$I18N_DOMAIN".pot

echo "extracting translations from $SRC"
rm -f "$POT"
touch "$POT"
cd "$SRC"
find . -type f -name "*.py" -exec "$XGETTEXT" -j -d "$I18N_DOMAIN" -o "$POT" \
  --copyright-holder="$COPYRIGHT" --msgid-bugs-address="$MAIL" \
  --package-name="$PACKAGE" --package-version="$PACKAGE_VERSION" \
  '{}' \;
echo "saved to $POT"
echo ".... done."
