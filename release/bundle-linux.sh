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

MAKESELF="makeself"
DIR=$( cd $( dirname ${BASH_SOURCE[0]} ) && pwd )
TARGET_DIR="$DIR/target"
FOUND="0"
set -e

if [ -d "$TARGET_DIR/Client/linux32" ]; then
    FOUND="1"
    echo ""
    echo "----------------------------------------------------------------"
    echo "Creating $CLIENT-$VERSION-linux32.sh..."
    echo "----------------------------------------------------------------"
    echo ""
    #rm -f "$TARGET_DIR/$CLIENT-$VERSION-linux32.tar.gz"
    rm -f "$TARGET_DIR/$CLIENT-$VERSION-linux32.sh"
    cd "$TARGET_DIR/Client/linux32"
    "$MAKESELF" --tar-quietly \
        . \
        "$TARGET_DIR/$CLIENT-$VERSION-linux32.sh" \
        "$CLIENT $VERSION" \
        bin/Start.sh
    #cd "$TARGET_DIR"
    #tar cfz "$CLIENT-$VERSION-linux32.tar.gz" "$CLIENT-$VERSION-linux32.sh"
fi

if [ -d "$TARGET_DIR/Client/linux64" ]; then
    FOUND="1"
    echo ""
    echo "----------------------------------------------------------------"
    echo "Creating $CLIENT-$VERSION-linux64.sh..."
    echo "----------------------------------------------------------------"
    echo ""
    #rm -f "$TARGET_DIR/$CLIENT-$VERSION-linux64.tar.gz"
    rm -f "$TARGET_DIR/$CLIENT-$VERSION-linux64.sh"
    cd "$TARGET_DIR/Client/linux64"
    "$MAKESELF" --tar-quietly \
        . \
        "$TARGET_DIR/$CLIENT-$VERSION-linux64.sh" \
        "$CLIENT $VERSION" \
        bin/Start.sh
    #cd "$TARGET_DIR"
    #tar cfz "$CLIENT-$VERSION-linux64.tar.gz" "$CLIENT-$VERSION-linux64.sh"
fi

if [ -d "$TARGET_DIR/Server/linux32" ]; then
    FOUND="1"
    echo ""
    echo "----------------------------------------------------------------"
    echo "Creating $SERVER-$VERSION-linux32.sh..."
    echo "----------------------------------------------------------------"
    echo ""
    #rm -f "$TARGET_DIR/$SERVER-$VERSION-linux32.tar.gz"
    rm -f "$TARGET_DIR/$SERVER-$VERSION-linux32.sh"
    cd "$TARGET_DIR/Server/linux32"
    "$MAKESELF" --tar-quietly \
        . \
        "$TARGET_DIR/$SERVER-$VERSION-linux32.sh" \
        "$SERVER $VERSION" \
        bin/Start.sh
    #cd "$TARGET_DIR"
    #tar cfz "$SERVER-$VERSION-linux32.tar.gz" "$SERVER-$VERSION-linux32.sh"
fi

if [ -d "$TARGET_DIR/Server/linux64" ]; then
    FOUND="1"
    echo ""
    echo "----------------------------------------------------------------"
    echo "Creating $SERVER-$VERSION-linux64.sh..."
    echo "----------------------------------------------------------------"
    echo ""
    #rm -f "$TARGET_DIR/$SERVER-$VERSION-linux64.tar.gz"
    rm -f "$TARGET_DIR/$SERVER-$VERSION-linux64.sh"
    cd "$TARGET_DIR/Server/linux64"
    "$MAKESELF" --tar-quietly \
        . \
        "$TARGET_DIR/$SERVER-$VERSION-linux64.sh" \
        "$SERVER $VERSION" \
        bin/Start.sh
    #cd "$TARGET_DIR"
    #tar cfz "$SERVER-$VERSION-linux64.tar.gz" "$SERVER-$VERSION-linux64.sh"
fi

if [ "$FOUND" == "0" ]; then
    echo "ERROR: No Linux packages were found at $TARGET_DIR"
fi
