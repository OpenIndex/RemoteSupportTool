#!/bin/bash
#
# Convert PNG icons in the current directory into ICO format for Windows.
#
# Copyright 2015 OpenIndex.de.
# Distributed under the MIT License.
# See accompanying LICENSE.txt file or at http://opensource.org/licenses/MIT
#

APP="png2ico"

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TARGET=$(readlink -f "$BASE_DIR/../../windows/Remote-Support-Tool.ico")
$APP "$TARGET" "$BASE_DIR/16.png" "$BASE_DIR/32.png" "$BASE_DIR/48.png"
echo "Saved ico file to $TARGET"
