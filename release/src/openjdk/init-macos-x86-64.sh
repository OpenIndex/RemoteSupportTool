#!/usr/bin/env bash
#
# Build a runtime environment for macOS 64-bit.
# Copyright 2015-2019 OpenIndex.de
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOWNLOADS_DIR="$DIR/downloads"
LOCAL_DIR="$DIR/local"
TEMP_DIR="$DIR/temp"


#
# initialization
#

set -e
source "$DIR/init.sh"
mkdir -p "$LOCAL_DIR"
rm -Rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

TARGET="macos-x86-64"
TARGET_JDK="$MACOS_X86_64_JDK"


#
# download OpenJDK binaries
#

mkdir -p "$DOWNLOADS_DIR"
cd "$DOWNLOADS_DIR"

if [[ ! -f "$DOWNLOADS_DIR/$(basename ${TARGET_JDK})" ]]; then
    echo "Downloading OpenJDK for $TARGET..."
    #wget -nc "$TARGET_JDK"
    curl -L \
      -o "$(basename ${TARGET_JDK})" \
      "$TARGET_JDK"
fi

if [[ ! -f "$DOWNLOADS_DIR/$(basename ${SYSTEM_JDK})" ]]; then
    echo "Downloading OpenJDK for jlink..."
    #wget -nc "$SYSTEM_JDK"
    curl -L \
      -o "$(basename ${SYSTEM_JDK})" \
      "$SYSTEM_JDK"
fi


#
# extract OpenJDK modules
#

echo "Extracting OpenJDK modules for $TARGET..."
mkdir -p "$TEMP_DIR/jdk"
cd "$TEMP_DIR/jdk"
extract_archive "$DOWNLOADS_DIR/$(basename "$TARGET_JDK")"
find "$(ls -1)" -type f -name "._*" -exec rm {} \;
if [[ -d "$(ls -1)/Contents/Home" ]]; then
    mv "$(ls -1)/Contents/Home/jmods" "$TEMP_DIR"
else
    mv "$(ls -1)/jmods" "$TEMP_DIR"
fi


#
# extract OpenJDK for jlink
#

echo "Extracting OpenJDK for jlink..."
SYSTEM_JDK_DIR="$LOCAL_DIR/$(basename "$SYSTEM_JDK")"
if [[ ! -d "$SYSTEM_JDK_DIR" ]]; then
    mkdir -p "$SYSTEM_JDK_DIR"
    cd "$SYSTEM_JDK_DIR"
    extract_archive "$DOWNLOADS_DIR/$(basename "$SYSTEM_JDK")"
    find "$(ls -1)" -type f -name "._*" -exec rm {} \;
fi
cd "$SYSTEM_JDK_DIR"
if [[ -d "$SYSTEM_JDK_DIR/$(ls -1)/Contents/Home" ]]; then
    JLINK="$SYSTEM_JDK_DIR/$(ls -1)/Contents/Home/bin/jlink"
else
    JLINK="$SYSTEM_JDK_DIR/$(ls -1)/bin/jlink"
fi


#
# build OpenJDK runtime
#

cd "$DIR"
rm -Rf "$DIR/runtime/$TARGET"
mkdir -p "$DIR/runtime"

echo "Building runtime environment for $TARGET..."
"$JLINK" \
    --add-modules "$MODULES" \
    --module-path "$TEMP_DIR/jmods" \
    --output "$DIR/runtime/$TARGET" \
    --compress=1 \
    --strip-debug \
    --no-header-files \
    --no-man-pages

configure_runtime "$DIR/runtime/$TARGET"


#
# cleanup
#

rm -Rf "$TEMP_DIR"
