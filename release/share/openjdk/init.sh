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

# -----------------------------------------------------------------------
#
# Get OpenJDK binaries and build a runtime environment with jlink.
#
# OpenJDK for Linux64, Mac64 & Windows64 is provided by
# https://adoptopenjdk.net/
#
# OpenJDK for Linux32 & Windows32 is provided by
# https://www.azul.com/downloads/zulu/
#
# OpenJDK for Windows32 might also be used from
# https://github.com/ojdkbuild/ojdkbuild
#
# -----------------------------------------------------------------------

#JDK_WINDOWS32="https://github.com/ojdkbuild/ojdkbuild/releases/download/10.0.2-1/java-10-openjdk-10.0.2-1.b13.ojdkbuild.windows.x86.zip</jdk.windows32"
JDK_WINDOWS32="https://cdn.azul.com/zulu/bin/zulu10.3+5-jdk10.0.2-win_i686.zip"
JDK_WINDOWS64="https://github.com/AdoptOpenJDK/openjdk10-releases/releases/download/jdk-10.0.2%2B13/OpenJDK10_x64_Windows_jdk-10.0.2.13.zip"
JDK_LINUX32="https://cdn.azul.com/zulu/bin/zulu10.3+5-jdk10.0.2-linux_i686.tar.gz"
JDK_LINUX64="https://github.com/AdoptOpenJDK/openjdk10-releases/releases/download/jdk-10.0.2%2B13/OpenJDK10_x64_Linux_jdk-10.0.2.13.tar.gz"
JDK_MAC64="https://github.com/AdoptOpenJDK/openjdk10-releases/releases/download/jdk-10.0.2%2B13/OpenJDK10_x64_Mac_jdk-10.0.2.13.tar.gz"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOWNLOADS_DIR="$DIR/downloads"
TEMP_DIR="$DIR/temp"
JDK="$JDK_LINUX64"


#
# initialization
#

set -e
rm -Rf "$DIR/jmods"
mkdir -p "$DIR/jmods"


#
# download OpenJDK binaries
#

mkdir -p "$DOWNLOADS_DIR"
cd "$DOWNLOADS_DIR"

echo "Downloading OpenJDK for Windows32..."
wget -nc "$JDK_WINDOWS32"

echo "Downloading OpenJDK for Windows64..."
wget -nc "$JDK_WINDOWS64"

echo "Downloading OpenJDK for Linux32..."
wget -nc "$JDK_LINUX32"

echo "Downloading OpenJDK for Linux64..."
wget -nc "$JDK_LINUX64"

echo "Downloading OpenJDK for Mac64..."
wget -nc "$JDK_MAC64"


#
# extract OpenJDK modules
#

echo "Extracting modules for Windows32..."
rm -Rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"
unzip -q "$DOWNLOADS_DIR/$(basename "$JDK_WINDOWS32")"
mv "$(ls -1)/jmods" "$DIR/jmods/windows32"
find "$DIR/jmods/windows32" -type f -exec chmod ugo-x {} \;

echo "Extracting modules for Windows64..."
rm -Rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"
unzip -q "$DOWNLOADS_DIR/$(basename "$JDK_WINDOWS64")"
mv "$(ls -1)/jmods" "$DIR/jmods/windows64"
find "$DIR/jmods/windows64" -type f -exec chmod ugo-x {} \;

echo "Extracting modules for Linux32..."
rm -Rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"
tar xfz "$DOWNLOADS_DIR/$(basename "$JDK_LINUX32")"
mv "$(ls -1)/jmods" "$DIR/jmods/linux32"

echo "Extracting modules for Linux64..."
rm -Rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"
tar xfz "$DOWNLOADS_DIR/$(basename "$JDK_LINUX64")"
mv "$(ls -1)/jmods" "$DIR/jmods/linux64"

echo "Extracting modules for Mac64..."
rm -Rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"
tar xfz "$DOWNLOADS_DIR/$(basename "$JDK_MAC64")"
find "$(ls -1)" -type f -name "._*" -exec rm {} \;
if [ -d "$(ls -1)/Contents/Home" ]; then
    mv "$(ls -1)/Contents/Home/jmods" "$DIR/jmods/mac64"
else
    mv "$(ls -1)/jmods" "$DIR/jmods/mac64"
fi


#
# extract OpenJDK for jlink
#

echo "Extracting OpenJDK..."
rm -Rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"
tar xfz "$DOWNLOADS_DIR/$(basename "$JDK_LINUX64")"
if [ -d "$(ls -1)/Contents/Home" ]; then
    JLINK="$TEMP_DIR/$(ls -1)/Contents/Home/bin/jlink"
else
    JLINK="$TEMP_DIR/$(ls -1)/bin/jlink"
fi


#
# build OpenJDK runtime
#

rm -Rf "$DIR/runtime"
mkdir -p "$DIR/runtime"

echo "Building runtime environment for Windows32..."
"$JLINK" \
    -p "$DIR/jmods/windows32" \
    --add-modules "java.desktop,java.naming" \
    --output "$DIR/runtime/windows32" \
    --compress=2 \
    --strip-debug \
    --no-header-files \
    --no-man-pages

echo "Building runtime environment for Windows64..."
"$JLINK" \
    -p "$DIR/jmods/windows64" \
    --add-modules "java.desktop,java.naming" \
    --output "$DIR/runtime/windows64" \
    --compress=2 \
    --strip-debug \
    --no-header-files \
    --no-man-pages

echo "Building runtime environment for Linux32..."
"$JLINK" \
    -p "$DIR/jmods/linux32" \
    --add-modules "java.desktop,java.naming" \
    --output "$DIR/runtime/linux32" \
    --compress=2 \
    --strip-debug \
    --no-header-files \
    --no-man-pages

echo "Building runtime environment for Linux64..."
"$JLINK" \
    -p "$DIR/jmods/linux64" \
    --add-modules "java.desktop,java.naming" \
    --output "$DIR/runtime/linux64" \
    --compress=2 \
    --strip-debug \
    --no-header-files \
    --no-man-pages

echo "Building runtime environment for Mac64..."
"$JLINK" \
    -p "$DIR/jmods/mac64" \
    --add-modules "java.desktop,java.naming" \
    --output "$DIR/runtime/mac64" \
    --compress=2 \
    --strip-debug \
    --no-header-files \
    --no-man-pages


#
# cleanup
#

cd "$DIR"
rm -Rf "$TEMP_DIR"
