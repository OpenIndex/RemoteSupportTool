#!/bin/bash
#
# Convert PNG icons in the current directory into ICNS format for Mac OS X.
#
# Copyright 2015 OpenIndex.de.
# Distributed under the MIT License.
# See accompanying LICENSE.txt file or at http://opensource.org/licenses/MIT
#

APP="png2icns"

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TARGET=$(readlink -f "$BASE_DIR/../../darwin/Remote-Support-Tool.icns")
$APP "$TARGET" "$BASE_DIR/16.png" "$BASE_DIR/32.png" "$BASE_DIR/48.png" "$BASE_DIR/128.png"
