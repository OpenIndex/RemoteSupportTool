#!/usr/bin/env bash
#
# Create application bundles for Windows systems.
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

WINE="$(which "wine")"
WINEPATH="$(which "winepath")"
SEVENZIP="$(which "7z")"
SEVENZIP_OPTIONS="-mx=9"

DIR=$( cd $( dirname ${BASH_SOURCE[0]} ) && pwd )
TARGET_DIR="$DIR/target"
FOUND="0"
set -e

CUSTOMER_SFX="$DIR/src/windows/7zSD.sfx"
STAFF_SFX="$DIR/src/windows/7zSD.sfx"
if [[ -x "$WINE" ]]; then
    echo ""
    printf "\e[1m\e[92m=======================================================================\e[0m\n"
    printf "\e[1m\e[92m Creating custom 7zip sfx files...\e[0m\n"
    printf "\e[1m\e[92m=======================================================================\e[0m\n"
    echo ""

    echo "Preparing build..."
    SEVENZIP_DIR="$TARGET_DIR/7zip"
    SEVENZIP_DIR_WIN="$("$WINEPATH" -w "$SEVENZIP_DIR")"
    rm -Rf "$SEVENZIP_DIR"
    mkdir -p "$SEVENZIP_DIR"
    cd "$DIR/src/windows"
    cp "7zSD.sfx" "$SEVENZIP_DIR"
    "$WINE" "ResourceHacker.exe" -open "manifest.rc" -save "$SEVENZIP_DIR_WIN\manifest.res" -action compile

    echo "Creating Customer.sfx..."
    cp "$DIR/src/windows/Customer.script" "$SEVENZIP_DIR"
    if [[ -f "$DIR/src/windows/Customer.ico" ]]; then
        cp "$DIR/src/windows/Customer.ico" "$SEVENZIP_DIR"
    else
        cp "$DIR/src/icons/desktopshare.ico" "$SEVENZIP_DIR/Customer.ico"
    fi
    "$WINE" "ResourceHacker.exe" -open "Customer.rc" -save "$SEVENZIP_DIR_WIN\Customer.res" -action compile
    "$WINE" "ResourceHacker.exe" -script "$SEVENZIP_DIR_WIN\Customer.script"
    if [[ -f "$SEVENZIP_DIR/Customer.sfx" ]]; then
        CUSTOMER_SFX="$SEVENZIP_DIR/Customer.sfx"
    else
        echo "WARNING: Customer.sfx was not created!"
        echo "Using default 7zSD.sfx instead."
    fi

    echo "Creating Staff.sfx..."
    cp "$DIR/src/windows/Staff.script" "$SEVENZIP_DIR"
    if [[ -f "$DIR/src/windows/Staff.ico" ]]; then
        cp "$DIR/src/windows/Staff.ico" "$SEVENZIP_DIR"
    else
        cp "$DIR/src/icons/help.ico" "$SEVENZIP_DIR/Staff.ico"
    fi
    "$WINE" "ResourceHacker.exe" -open "Staff.rc" -save "$SEVENZIP_DIR_WIN\Staff.res" -action compile
    "$WINE" "ResourceHacker.exe" -script "$SEVENZIP_DIR_WIN\Staff.script"
    if [[ -f "$SEVENZIP_DIR/Staff.sfx" ]]; then
        STAFF_SFX="$SEVENZIP_DIR/Staff.sfx"
    else
        echo "WARNING: Staff.sfx was not created!"
        echo "Using default 7zSD.sfx instead."
    fi
fi

if [[ -d "$TARGET_DIR/Staff/windows-x86" ]]; then
    FOUND="1"
    echo ""
    printf "\e[1m\e[92m=======================================================================\e[0m\n"
    printf "\e[1m\e[92m Creating $STAFF_TOOL-$VERSION.windows-x86.exe...\e[0m\n"
    printf "\e[1m\e[92m=======================================================================\e[0m\n"
    rm -f "$TARGET_DIR/$STAFF_TOOL-$VERSION.windows-x86.exe"
    cd "$TARGET_DIR/Staff/windows-x86"
    "$SEVENZIP" a "$SEVENZIP_OPTIONS" \
        "$TARGET_DIR/$STAFF_TOOL-$VERSION.windows-x86.7z" .
    cat "$STAFF_SFX" > "$TARGET_DIR/$STAFF_TOOL-$VERSION.windows-x86.exe"
    cat "$DIR/src/windows/Staff.txt" >> "$TARGET_DIR/$STAFF_TOOL-$VERSION.windows-x86.exe"
    cat "$TARGET_DIR/$STAFF_TOOL-$VERSION.windows-x86.7z" >> "$TARGET_DIR/$STAFF_TOOL-$VERSION.windows-x86.exe"
    rm "$TARGET_DIR/$STAFF_TOOL-$VERSION.windows-x86.7z"
fi

if [[ -d "$TARGET_DIR/Staff/windows-x86-64" ]]; then
    FOUND="1"
    echo ""
    printf "\e[1m\e[92m=======================================================================\e[0m\n"
    printf "\e[1m\e[92m Creating $STAFF_TOOL-$VERSION.windows-x86-64.exe...\e[0m\n"
    printf "\e[1m\e[92m=======================================================================\e[0m\n"
    rm -f "$TARGET_DIR/$STAFF_TOOL-$VERSION.windows-x86-64.exe"
    cd "$TARGET_DIR/Staff/windows-x86-64"
    "$SEVENZIP" a "$SEVENZIP_OPTIONS" \
        "$TARGET_DIR/$STAFF_TOOL-$VERSION.windows-x86-64.7z" .
    cat "$STAFF_SFX" > "$TARGET_DIR/$STAFF_TOOL-$VERSION.windows-x86-64.exe"
    cat "$DIR/src/windows/Staff.txt" >> "$TARGET_DIR/$STAFF_TOOL-$VERSION.windows-x86-64.exe"
    cat "$TARGET_DIR/$STAFF_TOOL-$VERSION.windows-x86-64.7z" >> "$TARGET_DIR/$STAFF_TOOL-$VERSION.windows-x86-64.exe"
    rm "$TARGET_DIR/$STAFF_TOOL-$VERSION.windows-x86-64.7z"
fi

if [[ -d "$TARGET_DIR/Customer/windows-x86" ]]; then
    FOUND="1"
    echo ""
    printf "\e[1m\e[92m=======================================================================\e[0m\n"
    printf "\e[1m\e[92m Creating $CUSTOMER_TOOL-$VERSION.windows-x86.exe...\e[0m\n"
    printf "\e[1m\e[92m=======================================================================\e[0m\n"
    rm -f "$TARGET_DIR/$CUSTOMER_TOOL-$VERSION.windows-x86.exe"
    cd "$TARGET_DIR/Customer/windows-x86"
    "$SEVENZIP" a "$SEVENZIP_OPTIONS" \
        "$TARGET_DIR/$CUSTOMER_TOOL-$VERSION.windows-x86.7z" .
    cat "$CUSTOMER_SFX" > "$TARGET_DIR/$CUSTOMER_TOOL-$VERSION.windows-x86.exe"
    cat "$DIR/src/windows/Customer.txt" >> "$TARGET_DIR/$CUSTOMER_TOOL-$VERSION.windows-x86.exe"
    cat "$TARGET_DIR/$CUSTOMER_TOOL-$VERSION.windows-x86.7z" >> "$TARGET_DIR/$CUSTOMER_TOOL-$VERSION.windows-x86.exe"
    rm "$TARGET_DIR/$CUSTOMER_TOOL-$VERSION.windows-x86.7z"
fi

if [[ -d "$TARGET_DIR/Customer/windows-x86-64" ]]; then
    FOUND="1"
    echo ""
    printf "\e[1m\e[92m=======================================================================\e[0m\n"
    printf "\e[1m\e[92m Creating $CUSTOMER_TOOL-$VERSION.windows-x86-64.exe...\e[0m\n"
    printf "\e[1m\e[92m=======================================================================\e[0m\n"
    rm -f "$TARGET_DIR/$CUSTOMER_TOOL-$VERSION.windows-x86-64.exe"
    cd "$TARGET_DIR/Customer/windows-x86-64"
    "$SEVENZIP" a "$SEVENZIP_OPTIONS" \
        "$TARGET_DIR/$CUSTOMER_TOOL-$VERSION.windows-x86-64.7z" .
    cat "$CUSTOMER_SFX" > "$TARGET_DIR/$CUSTOMER_TOOL-$VERSION.windows-x86-64.exe"
    cat "$DIR/src/windows/Customer.txt" >> "$TARGET_DIR/$CUSTOMER_TOOL-$VERSION.windows-x86-64.exe"
    cat "$TARGET_DIR/$CUSTOMER_TOOL-$VERSION.windows-x86-64.7z" >> "$TARGET_DIR/$CUSTOMER_TOOL-$VERSION.windows-x86-64.exe"
    rm "$TARGET_DIR/$CUSTOMER_TOOL-$VERSION.windows-x86-64.7z"
fi

if [[ "$FOUND" == "0" ]]; then
    echo "ERROR: No Windows packages were found at:"
    echo "$TARGET_DIR"
fi
