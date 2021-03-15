#!/usr/bin/env bash
#
# Create application bundles for macOS systems.
# Copyright 2015-2021 OpenIndex.de
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
VERSION="1.1.2"

MAKESELF="makeself"
DIR=$( cd $( dirname ${BASH_SOURCE[0]} ) && pwd )
TARGET_DIR="$DIR/target"
FOUND="0"
set -e

if [[ -d "$TARGET_DIR/Staff/macos-x86-64" ]]; then
    FOUND="1"
    echo ""
    printf "\e[1m\e[92m=======================================================================\e[0m\n"
    printf "\e[1m\e[92m Creating $STAFF_TOOL-$VERSION.macos-x86-64.tar.gz...\e[0m\n"
    printf "\e[1m\e[92m=======================================================================\e[0m\n"
    echo ""
    rm -Rf "$TARGET_DIR/$STAFF_TOOL.app"
    rm -f "$TARGET_DIR/$STAFF_TOOL-$VERSION.macos-x86-64.tar.gz"
    cp -R "$DIR/src/macos/Staff.app" "$TARGET_DIR/$STAFF_TOOL.app"
    mkdir -p "$TARGET_DIR/$STAFF_TOOL.app/Contents"
    cp -R "$TARGET_DIR/Staff/macos-x86-64" "$TARGET_DIR/$STAFF_TOOL.app/Contents/Resources"
    sed -i -e "s/{VERSION}/$VERSION/g" "$TARGET_DIR/$STAFF_TOOL.app/Contents/Info.plist"
    cd "$TARGET_DIR"
    tar cfz "$STAFF_TOOL-$VERSION.macos-x86-64.tar.gz" "$STAFF_TOOL.app"
    rm -Rf "$TARGET_DIR/$STAFF_TOOL.app"
    echo "Unsigned archive was created at:"
    echo "target/$STAFF_TOOL-$VERSION.macos-x86-64.tar.gz"
fi

if [[ -d "$TARGET_DIR/Customer/macos-x86-64" ]]; then
    FOUND="1"
    echo ""
    printf "\e[1m\e[92m=======================================================================\e[0m\n"
    printf "\e[1m\e[92m Creating $CUSTOMER_TOOL-$VERSION.macos-x86-64.tar.gz...\e[0m\n"
    printf "\e[1m\e[92m=======================================================================\e[0m\n"
    echo ""
    rm -Rf "$TARGET_DIR/$CUSTOMER_TOOL.app"
    rm -f "$TARGET_DIR/$CUSTOMER_TOOL-$VERSION.macos-x86-64.tar.gz"
    cp -R "$DIR/src/macos/Customer.app" "$TARGET_DIR/$CUSTOMER_TOOL.app"
    mkdir -p "$TARGET_DIR/$CUSTOMER_TOOL.app/Contents"
    cp -R "$TARGET_DIR/Customer/macos-x86-64" "$TARGET_DIR/$CUSTOMER_TOOL.app/Contents/Resources"
    sed -i -e "s/{VERSION}/$VERSION/g" "$TARGET_DIR/$CUSTOMER_TOOL.app/Contents/Info.plist"
    cd "$TARGET_DIR"
    tar cfz "$CUSTOMER_TOOL-$VERSION.macos-x86-64.tar.gz" "$CUSTOMER_TOOL.app"
    rm -Rf "$TARGET_DIR/$CUSTOMER_TOOL.app"
    echo "Unsigned archive was created at:"
    echo "target/$CUSTOMER_TOOL-$VERSION.macos-x86-64.tar.gz"
fi

if [[ -d "$TARGET_DIR/Staff/macos-x86-64" ]]; then
    FOUND="1"
    echo ""
    printf "\e[1m\e[92m=======================================================================\e[0m\n"
    printf "\e[1m\e[92m Creating $STAFF_TOOL-$VERSION.macos-x86-64.sh...\e[0m\n"
    printf "\e[1m\e[92m=======================================================================\e[0m\n"
    echo ""
    rm -f "$TARGET_DIR/$STAFF_TOOL-$VERSION.macos-x86-64.sh"
    cd "$TARGET_DIR/Staff/macos-x86-64"
    "$MAKESELF" --tar-quietly \
        . \
        "$TARGET_DIR/$STAFF_TOOL-$VERSION.macos-x86-64.sh" \
        "$STAFF_TOOL $VERSION" \
        bin/Start.sh
fi

if [[ -d "$TARGET_DIR/Customer/macos-x86-64" ]]; then
    FOUND="1"
    echo ""
    printf "\e[1m\e[92m=======================================================================\e[0m\n"
    printf "\e[1m\e[92m Creating $CUSTOMER_TOOL-$VERSION.macos-x86-64.sh...\e[0m\n"
    printf "\e[1m\e[92m=======================================================================\e[0m\n"
    echo ""
    rm -f "$TARGET_DIR/$CUSTOMER_TOOL-$VERSION.macos-x86-64.sh"
    cd "$TARGET_DIR/Customer/macos-x86-64"
    "$MAKESELF" --tar-quietly \
        . \
        "$TARGET_DIR/$CUSTOMER_TOOL-$VERSION.macos-x86-64.sh" \
        "$CUSTOMER_TOOL $VERSION" \
        bin/Start.sh
fi

if [[ "$FOUND" == "0" ]]; then
    echo "ERROR: No macOS packages were found at:"
    echo "$TARGET_DIR"
fi
