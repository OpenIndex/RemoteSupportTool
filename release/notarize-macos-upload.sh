#!/usr/bin/env bash
#
# Uploads a signed application bundle to start notarization.
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
# NOTICE: This script has to be executed on a macOS system with the
# required certificate available. In order to sign the application for
# yourself, you need to obtain a Developer ID from Apple and set some
# environment variables in the ".env" file. If it is not available, create a
# copy from ".env.example".
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Further information about notarization:
# https://successfulsoftware.net/2018/11/16/how-to-notarize-your-software-on-macos/
# https://developer.apple.com/documentation/xcode/notarizing_macos_software_before_distribution/customizing_the_notarization_workflow
# ----------------------------------------------------------------------------

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SIGNED_DIR="${DIR}/signed"
FOUND="0"
set -e

APPLE_DEVELOPER_MAIL=""
APPLE_DEVELOPER_PASSWORD=""
if [[ -f "${DIR}/.env" ]]; then
  source "${DIR}/.env"
fi

if [[ -z "${APPLE_DEVELOPER_MAIL}" ]]; then
  echo "ERROR: No developer mail was specified!"
  exit 1
fi

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
  echo "Which of these bundles you like to upload for notarization?"
  read -r -p "Enter one of the packages names listed above: " pkg

  PKG_DIR="${SIGNED_DIR}/${pkg}"
fi

if [[ ! -d "${PKG_DIR}" ]]; then
  echo ""
  echo "ERROR: The application bundle does not exist in \"${SIGNED_DIR}\"!"
  exit 1
fi

PKG_NAME="$(basename "${PKG_DIR}")"
PKG_ZIP="${PKG_DIR}/${PKG_NAME}.zip"
if [[ ! -f "${PKG_ZIP}" ]]; then
  echo ""
  echo "ERROR: No uploadable ZIP file found at \"${PKG_ZIP}\"!"
  exit 1
fi

PKG_BUNDLE=$(find "${PKG_DIR}" -maxdepth 1 -type d -name "*.app" | head -1)
if [[ ! -d "${PKG_BUNDLE}" ]]; then
  echo ""
  echo "ERROR: Na application bundle found within \"${SIGNED_DIR}\"!"
  exit 1
fi

PKG_BUNDLE_PLIST="${PKG_BUNDLE}/Contents/Info.plist"
if [[ ! -f "${PKG_BUNDLE_PLIST}" ]]; then
  echo ""
  echo "ERROR: No Info.plist found within \"${PKG_BUNDLE}\"!"
  exit 1
fi

PKG_BUNDLE_ID="$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "${PKG_BUNDLE_PLIST}")"
if [[ -z "${PKG_BUNDLE_ID}" ]]; then
  echo "ERROR: No CFBundleIdentifier was found within \"${PKG_BUNDLE_PLIST}\"!"
  exit 1
fi

echo ""
printf "\e[1m\e[92m=======================================================================\e[0m\n"
printf "\e[1m\e[92m Uploading %s for notarization...\e[0m\n" "$(basename "${PKG_ZIP}")"
printf "\e[1m\e[92m=======================================================================\e[0m\n"
echo ""

APPLE_DEVELOPER="--username ${APPLE_DEVELOPER_MAIL}"
if [[ -n "${APPLE_DEVELOPER_PASSWORD}" ]]; then
  APPLE_DEVELOPER="${APPLE_DEVELOPER} --password ${APPLE_DEVELOPER_PASSWORD}"
fi

xcrun altool \
  --notarize-app --type osx \
  --file "${PKG_ZIP}" \
  --primary-bundle-id "${PKG_BUNDLE_ID}" \
  ${APPLE_DEVELOPER}

echo ""
printf "\e[1m\e[92m=======================================================================\e[0m\n"
printf "\e[1m\e[92m Finished upload.\n"
printf "\e[1m\e[92m=======================================================================\e[0m\n"
echo ""
echo "If the upload finished with the message \"No errors uploading\", you should receive a"
echo "RequestUUID. Remember this ID for the next steps!"
echo ""
echo "Execute the following command with your <RequestUUID> to verify the status of notarization:"
echo ""
echo "notarize-macos-verify.sh <RequestUUID>"
echo ""
