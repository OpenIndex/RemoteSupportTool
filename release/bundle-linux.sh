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
VERSION="1.0-SNAPSHOT"

MAKESELF="makeself"
DIR=$( cd $( dirname ${BASH_SOURCE[0]} ) && pwd )
TARGET_DIR="$DIR/target"
FOUND="0"
set -e

if [ -d "$TARGET_DIR/Staff/linux32" ]; then
    FOUND="1"
    echo ""
    echo "----------------------------------------------------------------"
    echo "Creating $STAFF_TOOL-$VERSION-linux32.sh..."
    echo "----------------------------------------------------------------"
    echo ""
    rm -f "$TARGET_DIR/$STAFF_TOOL-$VERSION-linux32.sh"
    cd "$TARGET_DIR/Staff/linux32"
    "$MAKESELF" --tar-quietly \
        . \
        "$TARGET_DIR/$STAFF_TOOL-$VERSION-linux32.sh" \
        "$STAFF_TOOL $VERSION" \
        bin/Start.sh
fi

if [ -d "$TARGET_DIR/Staff/linux64" ]; then
    FOUND="1"
    echo ""
    echo "----------------------------------------------------------------"
    echo "Creating $STAFF_TOOL-$VERSION-linux64.sh..."
    echo "----------------------------------------------------------------"
    echo ""
    rm -f "$TARGET_DIR/$STAFF_TOOL-$VERSION-linux64.sh"
    cd "$TARGET_DIR/Staff/linux64"
    "$MAKESELF" --tar-quietly \
        . \
        "$TARGET_DIR/$STAFF_TOOL-$VERSION-linux64.sh" \
        "$STAFF_TOOL $VERSION" \
        bin/Start.sh
fi

if [ -d "$TARGET_DIR/Customer/linux32" ]; then
    FOUND="1"
    echo ""
    echo "----------------------------------------------------------------"
    echo "Creating $CUSTOMER_TOOL-$VERSION-linux32.sh..."
    echo "----------------------------------------------------------------"
    echo ""
    rm -f "$TARGET_DIR/$CUSTOMER_TOOL-$VERSION-linux32.sh"
    cd "$TARGET_DIR/Customer/linux32"
    "$MAKESELF" --tar-quietly \
        . \
        "$TARGET_DIR/$CUSTOMER_TOOL-$VERSION-linux32.sh" \
        "$CUSTOMER_TOOL $VERSION" \
        bin/Start.sh
fi

if [ -d "$TARGET_DIR/Customer/linux64" ]; then
    FOUND="1"
    echo ""
    echo "----------------------------------------------------------------"
    echo "Creating $CUSTOMER_TOOL-$VERSION-linux64.sh..."
    echo "----------------------------------------------------------------"
    echo ""
    rm -f "$TARGET_DIR/$CUSTOMER_TOOL-$VERSION-linux64.sh"
    cd "$TARGET_DIR/Customer/linux64"
    "$MAKESELF" --tar-quietly \
        . \
        "$TARGET_DIR/$CUSTOMER_TOOL-$VERSION-linux64.sh" \
        "$CUSTOMER_TOOL $VERSION" \
        bin/Start.sh
fi

if [ "$FOUND" == "0" ]; then
    echo "ERROR: No Linux packages were found at $TARGET_DIR"
fi
