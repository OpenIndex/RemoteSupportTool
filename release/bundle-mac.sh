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

DIR=$( cd $( dirname ${BASH_SOURCE[0]} ) && pwd )
TARGET_DIR="$DIR/target"
FOUND="0"
set -e

if [ -d "$TARGET_DIR/Client/mac64" ]; then
    FOUND="1"
    echo ""
    echo "----------------------------------------------------------------"
    echo "Creating $CLIENT-$VERSION.app..."
    echo "----------------------------------------------------------------"
    echo ""
    rm -Rf "$TARGET_DIR/$CLIENT-$VERSION.app"
    rm -f "$TARGET_DIR/$CLIENT-$VERSION.app.tar.gz"
    cp -R "$DIR/src/macos/Client.app" "$TARGET_DIR/$CLIENT-$VERSION.app"
    mkdir -p "$TARGET_DIR/$CLIENT-$VERSION.app/Contents/PlugIns"
    cp -R "$TARGET_DIR/Client/mac64" "$TARGET_DIR/$CLIENT-$VERSION.app/Contents/PlugIns/runtime"
    mv "$TARGET_DIR/$CLIENT-$VERSION.app/Contents/PlugIns/runtime/legal" "$TARGET_DIR/$CLIENT-$VERSION.app/Contents/Resources"
    mv "$TARGET_DIR/$CLIENT-$VERSION.app/Contents/PlugIns/runtime/LICENSE.txt" "$TARGET_DIR/$CLIENT-$VERSION.app/Contents/Resources"
    sed -i -e "s/{VERSION}/$VERSION/g" "$TARGET_DIR/$CLIENT-$VERSION.app/Contents/Info.plist"
    cd "$TARGET_DIR"
    tar cfz "$CLIENT-$VERSION.app.tar.gz" "$CLIENT-$VERSION.app"
    rm -Rf "$TARGET_DIR/$CLIENT-$VERSION.app"
fi

if [ -d "$TARGET_DIR/Server/mac64" ]; then
    FOUND="1"
    echo ""
    echo "----------------------------------------------------------------"
    echo "Creating $SERVER-$VERSION.app..."
    echo "----------------------------------------------------------------"
    echo ""
    rm -Rf "$TARGET_DIR/$SERVER-$VERSION.app"
    rm -f "$TARGET_DIR/$SERVER-$VERSION.app.tar.gz"
    cp -R "$DIR/src/macos/Server.app" "$TARGET_DIR/$SERVER-$VERSION.app"
    mkdir -p "$TARGET_DIR/$SERVER-$VERSION.app/Contents/PlugIns"
    cp -R "$TARGET_DIR/Server/mac64" "$TARGET_DIR/$SERVER-$VERSION.app/Contents/PlugIns/runtime"
    mv "$TARGET_DIR/$SERVER-$VERSION.app/Contents/PlugIns/runtime/legal" "$TARGET_DIR/$SERVER-$VERSION.app/Contents/Resources"
    mv "$TARGET_DIR/$SERVER-$VERSION.app/Contents/PlugIns/runtime/LICENSE.txt" "$TARGET_DIR/$SERVER-$VERSION.app/Contents/Resources"
    sed -i -e "s/{VERSION}/$VERSION/g" "$TARGET_DIR/$SERVER-$VERSION.app/Contents/Info.plist"
    cd "$TARGET_DIR"
    tar cfz "$SERVER-$VERSION.app.tar.gz" "$SERVER-$VERSION.app"
    rm -Rf "$TARGET_DIR/$SERVER-$VERSION.app"
fi

if [ "$FOUND" == "0" ]; then
    echo "ERROR: No macOS packages were found at $TARGET_DIR"
fi
