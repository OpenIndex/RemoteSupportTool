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
FOUND="0"
set -e

mkdir -p "$SIGNED_DIR"
export LANG="en_US.UTF-8"

for f in ${TARGET_DIR}/*-mac.tar.gz; do

    if [ "$FOUND" == "0" ]; then
        echo ""
        echo "----------------------------------------------------------------"
        echo "Unlocking keychain..."
        echo "----------------------------------------------------------------"
        echo ""
        security unlock-keychain
    fi

    FOUND="1"
    pkg="$(basename "$f" | rev | cut -d'-' -f3- | rev)"
    echo ""
    echo "----------------------------------------------------------------"
    echo "Signing $pkg.app..."
    echo "----------------------------------------------------------------"
    echo ""
    rm -Rf "$TARGET_DIR/$pkg.app"
    tar xfz "$f" -C "$TARGET_DIR"
    codesign --deep -s "$KEY" "$TARGET_DIR/$pkg.app"
    echo "Verifying signature:"
    codesign -d --verbose=4 "$TARGET_DIR/$pkg.app"
    echo ""
    echo "Verifying access for Gatekeeper:"
    spctl --assess --verbose=4 --type execute "$TARGET_DIR/$pkg.app"
    echo ""
    echo "Storing signed application bundle at:"
    echo "$SIGNED_DIR/$(basename "$f")"
    rm -f "$SIGNED_DIR/$(basename "$f")"
    cd "$TARGET_DIR"
    tar cfz "$SIGNED_DIR/$(basename "$f")" "$pkg.app"
done

if [ "$FOUND" == "0" ]; then
    echo "ERROR: No macOS packages were found at $DIR"
fi
