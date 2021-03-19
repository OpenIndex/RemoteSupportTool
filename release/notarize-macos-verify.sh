#!/usr/bin/env bash
#
# Verifies the status of a notarization request.
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
# copy of ".env.example".
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# You can find further information at:
# https://github.com/OpenIndex/RemoteSupportTool/wiki/Development#notarizing-application-bundle-for-macos
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

APPLE_DEVELOPER="--username ${APPLE_DEVELOPER_MAIL}"
if [[ -n "${APPLE_DEVELOPER_PASSWORD}" ]]; then
  APPLE_DEVELOPER="${APPLE_DEVELOPER} --password ${APPLE_DEVELOPER_PASSWORD}"
fi

if [[ -n "${1}" ]]; then
  echo ""
  printf "\e[1m\e[92m=======================================================================\e[0m\n"
  printf "\e[1m\e[92m Verifying notarization %s...\e[0m\n" "${1}"
  printf "\e[1m\e[92m=======================================================================\e[0m\n"
  echo ""

  xcrun altool \
    --notarization-info "${1}" \
    ${APPLE_DEVELOPER}

  echo ""
  printf "\e[1m\e[92m=======================================================================\e[0m\n"
  printf "\e[1m\e[92m Finished verification.\e[0m\n"
  printf "\e[1m\e[92m=======================================================================\e[0m\n"
  echo ""

  echo "The application bundle was successfully notarized, if "
  echo ""
  echo "  \"Status: success\""
  echo "  \"Status Message: Package Approved\""
  echo ""
  echo "is shown in the response. In this case you can finally build the notarized package with:"
  echo ""
  echo "notarize-macos-finish.sh"
  echo ""

else
  echo ""
  printf "\e[1m\e[92m=======================================================================\e[0m\n"
  printf "\e[1m\e[92m Showing notarization history...\e[0m\n"
  printf "\e[1m\e[92m=======================================================================\e[0m\n"
  echo ""

  xcrun altool \
    --notarization-history 0 \
    ${APPLE_DEVELOPER}
fi
