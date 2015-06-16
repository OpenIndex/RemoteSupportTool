#!/bin/bash
#
# Build application binary on Linux and Mac OS X.
#
# Copyright 2015 OpenIndex.de.
# Distributed under the MIT License.
# See accompanying LICENSE.txt file or at http://opensource.org/licenses/MIT
#

BUILD="pyi-build"

export LANG=en
set -e

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SPEC="$BASE_DIR"/misc/Remote-Support-Tool.spec
TARGET="$BASE_DIR"/target

echo "building application package"
echo "specified by $SPEC"
rm -Rf "$TARGET"
mkdir -p "$TARGET"
cd "$BASE_DIR"
"$BUILD" --distpath="$TARGET" --workpath="target/build" "$SPEC"
echo ".... done."
