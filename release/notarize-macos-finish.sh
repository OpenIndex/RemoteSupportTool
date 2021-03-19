#!/usr/bin/env bash
#
# Creates a notarized application bundle after upload and approval.
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
# You can find further information at:
# https://github.com/OpenIndex/RemoteSupportTool/wiki/Development#notarizing-application-bundle-for-macos
# ----------------------------------------------------------------------------

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SIGNED_DIR="${DIR}/signed"
NOTARIZED_DIR="${DIR}/notarized"
FOUND="0"
set -e

if [[ -n "${1}" ]]; then
  # Using application bundle, provided as first command line argument.
  PKG_DIR="${SIGNED_DIR}/$(basename "$1")"
else
  # Otherwise, showing available application bundles and let the user select.
  for f in "${SIGNED_DIR}"/*; do
    if [[ -d "${f}" ]]; then
      n=$(basename "${f}")
      if [[ -f "${f}/${n}.zip" ]]; then
        if [[ "${FOUND}" == "0" ]]; then
          echo ""
          printf "\e[1m\e[92m=======================================================================\e[0m\n"
          printf "\e[1m\e[92m Available signed macOS application bundles:\e[0m\n"
          printf "\e[1m\e[92m=======================================================================\e[0m\n"
          echo ""
        fi
        FOUND="1"
        echo "${n}"
      fi
    fi
  done

  if [[ "${FOUND}" == "0" ]]; then
    echo "ERROR: No signed macOS packages were found at:"
    echo "${SIGNED_DIR}"
    exit 1
  fi

  echo ""
  echo "Which of these bundles were successfully notarized and are ready for release?"
  read -r -p "Enter one of the packages names listed above: " pkg

  PKG_DIR="${SIGNED_DIR}/${pkg}"
fi

if [[ ! -d "${PKG_DIR}" ]]; then
  echo ""
  echo "ERROR: The application bundle does not exist in \"${SIGNED_DIR}\"!"
  exit 1
fi

PKG_NAME="$(basename "${PKG_DIR}")"

PKG_BUNDLE=$(find "${PKG_DIR}" -maxdepth 1 -type d -name "*.app" | head -1)
if [[ ! -d "${PKG_BUNDLE}" ]]; then
  echo ""
  echo "ERROR: Na application bundle found within \"${SIGNED_DIR}\"!"
  exit 1
fi

echo ""
printf "\e[1m\e[92m=======================================================================\e[0m\n"
printf "\e[1m\e[92m Finishing notarization for %s...\e[0m\n" "${PKG_NAME}"
printf "\e[1m\e[92m=======================================================================\e[0m\n"
echo ""

xcrun stapler staple -v "${PKG_BUNDLE}"

mkdir -p "${NOTARIZED_DIR}"
NOTARIZED_ARCHIVE="${NOTARIZED_DIR}/${PKG_NAME}.tar.gz"

echo ""
printf "\e[1m\e[92m=======================================================================\e[0m\n"
printf "\e[1m\e[92m Archiving notarized application bundle...\e[0m\n"
printf "\e[1m\e[92m=======================================================================\e[0m\n"
echo ""
echo "Archiving notarized application bundle to:"
echo "${NOTARIZED_ARCHIVE}"
cd "${PKG_DIR}"
tar cfz "${NOTARIZED_ARCHIVE}" "$(basename "${PKG_BUNDLE}")"

echo ""
echo "It seems, that the notarization process finished successfully!"
echo "Please check the output above for the message:"
echo "  \"The staple and validate action worked!\""
echo ""
