#!/usr/bin/env bash
#
# Create signed application bundles for macOS systems.
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

# ----------------------------------------------------------------------------
# NOTICE: This script has to be executed on a macOS system with the
# required certificate available. In order to sign the application for
# yourself, you need to obtain a Developer ID from Apple and set the
# KEY variable accordingly.
# ----------------------------------------------------------------------------

KEY="Developer ID Application: Andreas Rudolph (H48THMS543)"
DIR=$( cd $( dirname ${BASH_SOURCE[0]} ) && pwd )
TARGET_DIR="$DIR/target"
SIGNED_DIR="$DIR/signed"
TEMP_DIR="$TARGET_DIR/codesign"
FOUND="0"
set -e

mkdir -p "$SIGNED_DIR"
export LANG="en_US.UTF-8"

for f in ${TARGET_DIR}/*.macos-*.tar.gz; do

    if [[ "$FOUND" == "0" ]]; then
        echo ""
        printf "\e[1m\e[92m=======================================================================\e[0m\n"
        printf "\e[1m\e[92m Unlocking keychain...\e[0m\n"
        printf "\e[1m\e[92m=======================================================================\e[0m\n"
        echo ""
        security unlock-keychain
    fi

    FOUND="1"
    echo ""
    printf "\e[1m\e[92m=======================================================================\e[0m\n"
    printf "\e[1m\e[92m Processing $(basename "$f")...\e[0m\n"
    printf "\e[1m\e[92m=======================================================================\e[0m\n"
    echo ""
    rm -Rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR"
    tar xfz "$f" -C "$TEMP_DIR"
    pkg="$(ls -1 "$TEMP_DIR")"
    codesign --deep -s "$KEY" "$TEMP_DIR/$pkg"
    echo "Verifying signature:"
    codesign -d --verbose=4 "$TEMP_DIR/$pkg"
    echo ""
    echo "Verifying access for Gatekeeper:"
    spctl --assess --verbose=4 --type execute "$TEMP_DIR/$pkg"
    echo ""
    echo "Storing signed application bundle at:"
    echo "$SIGNED_DIR/$(basename "$f")"
    rm -f "$SIGNED_DIR/$(basename "$f")"
    cd "$TEMP_DIR"
    tar cfz "$SIGNED_DIR/$(basename "$f")" "$pkg"
done

if [[ "$FOUND" == "0" ]]; then
    echo "ERROR: No macOS packages were found at:"
    echo "$TARGET_DIR"
fi

rm -Rf "$TEMP_DIR"
