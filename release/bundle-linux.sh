#!/usr/bin/env bash
#
# Create application bundles for Linux systems.
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

if [[ -d "${TARGET_DIR}/Staff/linux-x86" ]]; then
  FOUND="1"
  echo ""
  printf "\e[1m\e[92m=======================================================================\e[0m\n"
  printf "\e[1m\e[92m Creating %s.linux-x86.sh...\e[0m\n" "${STAFF_TOOL}-${VERSION}"
  printf "\e[1m\e[92m=======================================================================\e[0m\n"
  echo ""
  rm -f "${TARGET_DIR}/${STAFF_TOOL}-${VERSION}.linux-x86.sh"
  cd "${TARGET_DIR}/Staff/linux-x86"
  "$MAKESELF" --tar-quietly \
    . \
    "${TARGET_DIR}/${STAFF_TOOL}-${VERSION}.linux-x86.sh" \
    "${STAFF_TOOL} ${VERSION}" \
    bin/Start.sh
fi

if [[ -d "${TARGET_DIR}/Staff/linux-x86-64" ]]; then
  FOUND="1"
  echo ""
  printf "\e[1m\e[92m=======================================================================\e[0m\n"
  printf "\e[1m\e[92m Creating %s.linux-x86-64.sh...\e[0m\n" "${STAFF_TOOL}-${VERSION}"
  printf "\e[1m\e[92m=======================================================================\e[0m\n"
  echo ""
  rm -f "${TARGET_DIR}/${STAFF_TOOL}-${VERSION}.linux-x86-64.sh"
  cd "${TARGET_DIR}/Staff/linux-x86-64"
  "$MAKESELF" --tar-quietly \
    . \
    "${TARGET_DIR}/${STAFF_TOOL}-${VERSION}.linux-x86-64.sh" \
    "${STAFF_TOOL} ${VERSION}" \
    bin/Start.sh
fi

if [[ -d "${TARGET_DIR}/Customer/linux-x86" ]]; then
  FOUND="1"
  echo ""
  printf "\e[1m\e[92m=======================================================================\e[0m\n"
  printf "\e[1m\e[92m Creating %s.linux-x86.sh...\e[0m\n" "${CUSTOMER_TOOL}-${VERSION}"
  printf "\e[1m\e[92m=======================================================================\e[0m\n"
  echo ""
  rm -f "${TARGET_DIR}/${CUSTOMER_TOOL}-${VERSION}.linux-x86.sh"
  cd "${TARGET_DIR}/Customer/linux-x86"
  "$MAKESELF" --tar-quietly \
    . \
    "${TARGET_DIR}/${CUSTOMER_TOOL}-${VERSION}.linux-x86.sh" \
    "${CUSTOMER_TOOL} ${VERSION}" \
    bin/Start.sh
fi

if [[ -d "${TARGET_DIR}/Customer/linux-x86-64" ]]; then
  FOUND="1"
  echo ""
  printf "\e[1m\e[92m=======================================================================\e[0m\n"
  printf "\e[1m\e[92m Creating %s.linux-x86-64.sh...\e[0m\n" "${CUSTOMER_TOOL}-${VERSION}"
  printf "\e[1m\e[92m=======================================================================\e[0m\n"
  echo ""
  rm -f "${TARGET_DIR}/${CUSTOMER_TOOL}-${VERSION}.linux-x86-64.sh"
  cd "${TARGET_DIR}/Customer/linux-x86-64"
  "$MAKESELF" --tar-quietly \
    . \
    "${TARGET_DIR}/${CUSTOMER_TOOL}-${VERSION}.linux-x86-64.sh" \
    "${CUSTOMER_TOOL} ${VERSION}" \
    bin/Start.sh
fi

if [[ "${FOUND}" == "0" ]]; then
  echo "ERROR: No Linux packages were found at:"
  echo "${TARGET_DIR}"
fi
