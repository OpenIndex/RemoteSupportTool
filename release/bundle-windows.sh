#!/usr/bin/env bash
#
# Copyright 2015-2018 OpenIndex.de
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

CLIENT="RemoteSupportClient"
SERVER="RemoteSupportServer"
VERSION="1.0-SNAPSHOT"

SEVENZIP="7z"
SEVENZIP_OPTIONS="-mx=9"
DIR=$( cd $( dirname ${BASH_SOURCE[0]} ) && pwd )
TARGET_DIR="$DIR/target"
FOUND="0"
set -e

if [ -d "$TARGET_DIR/Client/windows32" ]; then
    FOUND="1"
    echo ""
    echo "----------------------------------------------------------------"
    echo "Creating $CLIENT-$VERSION-win32.exe..."
    echo "----------------------------------------------------------------"
    echo ""
    rm -f "$TARGET_DIR/$CLIENT-$VERSION-win32.exe"
    cd "$TARGET_DIR/Client/windows32"
    "$SEVENZIP" a "$SEVENZIP_OPTIONS" \
        "$TARGET_DIR/$CLIENT-$VERSION-win32.7z" .
    cat "$DIR/src/windows/Client.sfx" > "$TARGET_DIR/$CLIENT-$VERSION-win32.exe"
    cat "$DIR/src/windows/Client.txt" >> "$TARGET_DIR/$CLIENT-$VERSION-win32.exe"
    cat "$TARGET_DIR/$CLIENT-$VERSION-win32.7z" >> "$TARGET_DIR/$CLIENT-$VERSION-win32.exe"
    rm "$TARGET_DIR/$CLIENT-$VERSION-win32.7z"
fi

if [ -d "$TARGET_DIR/Client/windows64" ]; then
    FOUND="1"
    echo ""
    echo "----------------------------------------------------------------"
    echo "Creating $CLIENT-$VERSION-win64.exe..."
    echo "----------------------------------------------------------------"
    echo ""
    rm -f "$TARGET_DIR/$CLIENT-$VERSION-win64.exe"
    cd "$TARGET_DIR/Client/windows64"
    "$SEVENZIP" a "$SEVENZIP_OPTIONS" \
        "$TARGET_DIR/$CLIENT-$VERSION-win64.7z" \
        .
    cat "$DIR/src/windows/Client.sfx" > "$TARGET_DIR/$CLIENT-$VERSION-win64.exe"
    cat "$DIR/src/windows/Client.txt" >> "$TARGET_DIR/$CLIENT-$VERSION-win64.exe"
    cat "$TARGET_DIR/$CLIENT-$VERSION-win64.7z" >> "$TARGET_DIR/$CLIENT-$VERSION-win64.exe"
    rm "$TARGET_DIR/$CLIENT-$VERSION-win64.7z"
fi

if [ -d "$TARGET_DIR/Server/windows32" ]; then
    FOUND="1"
    echo ""
    echo "----------------------------------------------------------------"
    echo "Creating $SERVER-$VERSION-win32.exe..."
    echo "----------------------------------------------------------------"
    echo ""
    rm -f "$TARGET_DIR/$SERVER-$VERSION-win32.exe"
    cd "$TARGET_DIR/Server/windows32"
    "$SEVENZIP" a "$SEVENZIP_OPTIONS" \
        "$TARGET_DIR/$SERVER-$VERSION-win32.7z" \
        .
    cat "$DIR/src/windows/Server.sfx" > "$TARGET_DIR/$SERVER-$VERSION-win32.exe"
    cat "$DIR/src/windows/Server.txt" >> "$TARGET_DIR/$SERVER-$VERSION-win32.exe"
    cat "$TARGET_DIR/$SERVER-$VERSION-win32.7z" >> "$TARGET_DIR/$SERVER-$VERSION-win32.exe"
    rm "$TARGET_DIR/$SERVER-$VERSION-win32.7z"
fi

if [ -d "$TARGET_DIR/Server/windows64" ]; then
    FOUND="1"
    echo ""
    echo "----------------------------------------------------------------"
    echo "Creating $SERVER-$VERSION-win64.exe..."
    echo "----------------------------------------------------------------"
    echo ""
    rm -f "$TARGET_DIR/$SERVER-$VERSION-win64.exe"
    cd "$TARGET_DIR/Server/windows64"
    "$SEVENZIP" a "$SEVENZIP_OPTIONS" \
        "$TARGET_DIR/$SERVER-$VERSION-win64.7z" \
        .
    cat "$DIR/src/windows/Server.sfx" > "$TARGET_DIR/$SERVER-$VERSION-win64.exe"
    cat "$DIR/src/windows/Server.txt" >> "$TARGET_DIR/$SERVER-$VERSION-win64.exe"
    cat "$TARGET_DIR/$SERVER-$VERSION-win64.7z" >> "$TARGET_DIR/$SERVER-$VERSION-win64.exe"
    rm "$TARGET_DIR/$SERVER-$VERSION-win64.7z"
fi

if [ "$FOUND" == "0" ]; then
    echo "ERROR: No Windows packages were found at $TARGET_DIR"
fi
