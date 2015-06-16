#!/bin/bash
#
# Build application binary on Linux and Mac OS X.
#
# Copyright 2015 OpenIndex.de.
# Distributed under the MIT License.
# See accompanying LICENSE.txt file or at http://opensource.org/licenses/MIT
#

BUILD="pyi-build"

#export LANG=en
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

APP="$( ls -1 "$TARGET" | grep ".app" )"
if [ ! -z "$APP" ]
then
  echo "Post processing OS X application bundle '$APP'."

  echo "Copy customized 'Info.plist'."
  PLIST="$TARGET"/"$APP"/Contents/Info.plist
  cp -f "$BASE_DIR"/misc/darwin/Info.plist "$PLIST"

  echo "Create an archive."
  cd "$TARGET"
  tar cfz "$APP.tar.gz" $APP
fi

echo ".... done."
