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

STAFF_TOOL="StaffSupportTool"
CUSTOMER_TOOL="CustomerSupportTool"
VERSION="1.0.1"

DIR=$( cd $( dirname ${BASH_SOURCE[0]} ) && pwd )
TARGET_DIR="$DIR/target"
FOUND="0"
set -e

if [ -d "$TARGET_DIR/Staff/mac64" ]; then
    FOUND="1"
    echo ""
    echo "----------------------------------------------------------------"
    echo "Creating $STAFF_TOOL-$VERSION-mac.tar.gz..."
    echo "----------------------------------------------------------------"
    echo ""
    rm -Rf "$TARGET_DIR/$STAFF_TOOL.app"
    rm -f "$TARGET_DIR/$STAFF_TOOL-$VERSION-mac.tar.gz"
    cp -R "$DIR/src/macos/Staff.app" "$TARGET_DIR/$STAFF_TOOL.app"
    mkdir -p "$TARGET_DIR/$STAFF_TOOL.app/Contents/PlugIns"
    cp -R "$TARGET_DIR/Staff/mac64" "$TARGET_DIR/$STAFF_TOOL.app/Contents/PlugIns/runtime"
    mv "$TARGET_DIR/$STAFF_TOOL.app/Contents/PlugIns/runtime/legal" "$TARGET_DIR/$STAFF_TOOL.app/Contents/Resources"
    mv "$TARGET_DIR/$STAFF_TOOL.app/Contents/PlugIns/runtime/LICENSE.txt" "$TARGET_DIR/$STAFF_TOOL.app/Contents/Resources"
    sed -i -e "s/{VERSION}/$VERSION/g" "$TARGET_DIR/$STAFF_TOOL.app/Contents/Info.plist"
    cd "$TARGET_DIR"
    tar cfz "$STAFF_TOOL-$VERSION-mac.tar.gz" "$STAFF_TOOL.app"
    rm -Rf "$TARGET_DIR/$STAFF_TOOL.app"
fi

if [ -d "$TARGET_DIR/Customer/mac64" ]; then
    FOUND="1"
    echo ""
    echo "----------------------------------------------------------------"
    echo "Creating $CUSTOMER_TOOL-$VERSION-mac.tar.gz..."
    echo "----------------------------------------------------------------"
    echo ""
    rm -Rf "$TARGET_DIR/$CUSTOMER_TOOL.app"
    rm -f "$TARGET_DIR/$CUSTOMER_TOOL-$VERSION-mac.tar.gz"
    cp -R "$DIR/src/macos/Customer.app" "$TARGET_DIR/$CUSTOMER_TOOL.app"
    mkdir -p "$TARGET_DIR/$CUSTOMER_TOOL.app/Contents/PlugIns"
    cp -R "$TARGET_DIR/Customer/mac64" "$TARGET_DIR/$CUSTOMER_TOOL.app/Contents/PlugIns/runtime"
    mv "$TARGET_DIR/$CUSTOMER_TOOL.app/Contents/PlugIns/runtime/legal" "$TARGET_DIR/$CUSTOMER_TOOL.app/Contents/Resources"
    mv "$TARGET_DIR/$CUSTOMER_TOOL.app/Contents/PlugIns/runtime/LICENSE.txt" "$TARGET_DIR/$CUSTOMER_TOOL.app/Contents/Resources"
    sed -i -e "s/{VERSION}/$VERSION/g" "$TARGET_DIR/$CUSTOMER_TOOL.app/Contents/Info.plist"
    cd "$TARGET_DIR"
    tar cfz "$CUSTOMER_TOOL-$VERSION-mac.tar.gz" "$CUSTOMER_TOOL.app"
    rm -Rf "$TARGET_DIR/$CUSTOMER_TOOL.app"
fi

if [ "$FOUND" == "0" ]; then
    echo "ERROR: No macOS packages were found at $TARGET_DIR"
fi
