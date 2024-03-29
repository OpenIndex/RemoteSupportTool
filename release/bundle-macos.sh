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

# ----------------------------------------------------------------------------
# NOTICE: This script requires an ".env" file in the same folder. If it is not
# available, create a copy of ".env.example" and place your settings inside.
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# You can find further information at:
# https://github.com/OpenIndex/RemoteSupportTool/wiki/Development#create-application-bundles
# ----------------------------------------------------------------------------

MAKESELF="makeself"
DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
TARGET_DIR="${DIR}/target"
FOUND="0"
set -e

STAFF_TOOL=""
CUSTOMER_TOOL=""
VERSION=""
if [[ -f "${DIR}/.env" ]]; then
  source "${DIR}/.env"
fi

if [[ -d "${TARGET_DIR}/Staff/macos-x86-64" ]]; then
  FOUND="1"
  echo ""
  printf "\e[1m\e[92m=======================================================================\e[0m\n"
  printf "\e[1m\e[92m Creating %s.macos-x86-64.tar.gz...\e[0m\n" "${STAFF_TOOL}-${VERSION}"
  printf "\e[1m\e[92m=======================================================================\e[0m\n"
  echo ""
  rm -Rf "${TARGET_DIR}/${STAFF_TOOL}.app"
  rm -f "${TARGET_DIR}/${STAFF_TOOL}-${VERSION}.macos-x86-64.tar.gz"
  cp -R "${DIR}/src/macos/Staff.app" "${TARGET_DIR}/${STAFF_TOOL}.app"
  mkdir -p "${TARGET_DIR}/${STAFF_TOOL}.app/Contents"
  mkdir -p "${TARGET_DIR}/${STAFF_TOOL}.app/Contents/MacOS"
  cp "${DIR}/src/macos/JavaMacLauncher" "${TARGET_DIR}/${STAFF_TOOL}.app/Contents/MacOS/JavaMacLauncher"
  chmod ugo+x "${TARGET_DIR}/${STAFF_TOOL}.app/Contents/MacOS/JavaMacLauncher"
  cp -R "${TARGET_DIR}/Staff/macos-x86-64" "${TARGET_DIR}/${STAFF_TOOL}.app/Contents/Resources"
  sed -i -e "s/{VERSION}/${VERSION}/g" "${TARGET_DIR}/${STAFF_TOOL}.app/Contents/Info.plist"
  cd "${TARGET_DIR}"
  tar cfz "${STAFF_TOOL}-${VERSION}.macos-x86-64.tar.gz" "${STAFF_TOOL}.app"
  rm -Rf "${TARGET_DIR}/${STAFF_TOOL}.app"
  echo "Unsigned archive was created at:"
  echo "target/${STAFF_TOOL}-${VERSION}.macos-x86-64.tar.gz"
fi

if [[ -d "${TARGET_DIR}/Customer/macos-x86-64" ]]; then
  FOUND="1"
  echo ""
  printf "\e[1m\e[92m=======================================================================\e[0m\n"
  printf "\e[1m\e[92m Creating %s.macos-x86-64.tar.gz...\e[0m\n" "${CUSTOMER_TOOL}-${VERSION}"
  printf "\e[1m\e[92m=======================================================================\e[0m\n"
  echo ""
  rm -Rf "${TARGET_DIR}/${CUSTOMER_TOOL}.app"
  rm -f "${TARGET_DIR}/${CUSTOMER_TOOL}-${VERSION}.macos-x86-64.tar.gz"
  cp -R "${DIR}/src/macos/Customer.app" "${TARGET_DIR}/${CUSTOMER_TOOL}.app"
  mkdir -p "${TARGET_DIR}/${CUSTOMER_TOOL}.app/Contents"
  mkdir -p "${TARGET_DIR}/${CUSTOMER_TOOL}.app/Contents/MacOS"
  cp "${DIR}/src/macos/JavaMacLauncher" "${TARGET_DIR}/${CUSTOMER_TOOL}.app/Contents/MacOS/JavaMacLauncher"
  chmod ugo+x "${TARGET_DIR}/${CUSTOMER_TOOL}.app/Contents/MacOS/JavaMacLauncher"
  cp -R "${TARGET_DIR}/Customer/macos-x86-64" "${TARGET_DIR}/${CUSTOMER_TOOL}.app/Contents/Resources"
  sed -i -e "s/{VERSION}/${VERSION}/g" "${TARGET_DIR}/${CUSTOMER_TOOL}.app/Contents/Info.plist"
  cd "${TARGET_DIR}"
  tar cfz "${CUSTOMER_TOOL}-${VERSION}.macos-x86-64.tar.gz" "${CUSTOMER_TOOL}.app"
  rm -Rf "${TARGET_DIR}/${CUSTOMER_TOOL}.app"
  echo "Unsigned archive was created at:"
  echo "target/${CUSTOMER_TOOL}-${VERSION}.macos-x86-64.tar.gz"
fi

if [[ -d "${TARGET_DIR}/Staff/macos-x86-64" ]]; then
  FOUND="1"
  echo ""
  printf "\e[1m\e[92m=======================================================================\e[0m\n"
  printf "\e[1m\e[92m Creating %s.macos-x86-64.sh...\e[0m\n" "${STAFF_TOOL}-${VERSION}"
  printf "\e[1m\e[92m=======================================================================\e[0m\n"
  echo ""
  rm -f "${TARGET_DIR}/${STAFF_TOOL}-${VERSION}.macos-x86-64.sh"
  cd "${TARGET_DIR}/Staff/macos-x86-64"
  "$MAKESELF" --tar-quietly \
    . \
    "${TARGET_DIR}/${STAFF_TOOL}-${VERSION}.macos-x86-64.sh" \
    "${STAFF_TOOL} ${VERSION}" \
    bin/Start.sh
fi

if [[ -d "${TARGET_DIR}/Customer/macos-x86-64" ]]; then
  FOUND="1"
  echo ""
  printf "\e[1m\e[92m=======================================================================\e[0m\n"
  printf "\e[1m\e[92m Creating %s.macos-x86-64.sh...\e[0m\n" "${CUSTOMER_TOOL}-${VERSION}"
  printf "\e[1m\e[92m=======================================================================\e[0m\n"
  echo ""
  rm -f "${TARGET_DIR}/${CUSTOMER_TOOL}-${VERSION}.macos-x86-64.sh"
  cd "${TARGET_DIR}/Customer/macos-x86-64"
  "$MAKESELF" --tar-quietly \
    . \
    "${TARGET_DIR}/${CUSTOMER_TOOL}-${VERSION}.macos-x86-64.sh" \
    "${CUSTOMER_TOOL} ${VERSION}" \
    bin/Start.sh
fi

if [[ "${FOUND}" == "0" ]]; then
  echo "ERROR: No macOS packages were found at:"
  echo "${TARGET_DIR}"
fi
