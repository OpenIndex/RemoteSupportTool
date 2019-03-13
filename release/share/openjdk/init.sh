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
# Detect operating system and architecture and select the appropriate
# OpenJDK bundle.
#
# OpenJDK is taken from
# https://adoptopenjdk.net/ or https://www.azul.com/downloads/zulu/
#
# -----------------------------------------------------------------------

SYSTEM="$( uname -s )"
SYSTEM_ARCH="$( arch )"
case "$SYSTEM" in

  Darwin)
    echo "Initializing macOS environment..."
    SYSTEM_JDK="https://github.com/AdoptOpenJDK/openjdk10-releases/releases/download/jdk-10.0.2%2B13/OpenJDK10_x64_Mac_jdk-10.0.2%2B13.tar.gz"
    #SYSTEM_JDK="https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.2%2B9/OpenJDK11U-jdk_x64_mac_hotspot_11.0.2_9.tar.gz"
    ;;

  Linux)
    case "$SYSTEM_ARCH" in
        x86_64)
          echo "Initializing Linux 64bit environment..."
          SYSTEM_JDK="https://github.com/AdoptOpenJDK/openjdk10-releases/releases/download/jdk-10.0.2%2B13/OpenJDK10_x64_Linux_jdk-10.0.2%2B13.tar.gz"
          #SYSTEM_JDK="https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.2%2B9/OpenJDK11U-jdk_x64_linux_hotspot_11.0.2_9.tar.gz"
          ;;
        i686)
          echo "Initializing Linux 32bit environment..."
          SYSTEM_JDK="https://cdn.azul.com/zulu/bin/zulu10.3+5-jdk10.0.2-linux_i686.tar.gz"
          #SYSTEM_JDK="https://github.com/OpenIndex/openjdk-linux-x86/releases/download/jdk-11.0.2%2B9/jdk-11.0.2+9-jre-linux-x86.tar.gz"
          ;;
        *)
          echo "Unsupported Linux environment ($SYSTEM_ARCH)..."
          exit 1
          ;;
    esac
    ;;

  *)
    echo "Unsupported environment ($SYSTEM)..."
    exit 1
    ;;

esac
