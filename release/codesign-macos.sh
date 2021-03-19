#!/usr/bin/env bash
#
# Create signed application bundles for macOS systems.
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

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
TARGET_DIR="${DIR}/target"
SIGNED_DIR="${DIR}/signed"
FOUND="0"
set -e

APPLE_CODESIGN_KEY=""
if [[ -f "${DIR}/.env" ]]; then
  source "${DIR}/.env"
fi

if [[ -z "${APPLE_CODESIGN_KEY}" ]]; then
  echo "ERROR: No signature key was specified!"
  exit 1
fi

mkdir -p "${SIGNED_DIR}"
export LANG="en_US.UTF-8"

for f in "${TARGET_DIR}"/*.macos-*.tar.gz; do

  if [[ "${FOUND}" == "0" ]]; then
    echo ""
    printf "\e[1m\e[92m=======================================================================\e[0m\n"
    printf "\e[1m\e[92m Unlocking keychain...\e[0m\n"
    printf "\e[1m\e[92m=======================================================================\e[0m\n"
    echo ""
    security unlock-keychain
  fi

  FOUND="1"
  archive="$(basename "${f}")"
  archive_name="$(basename "${archive}" ".tar.gz")"
  signed_dir="${SIGNED_DIR}/${archive_name}"
  rm -Rf "${signed_dir}"
  mkdir -p "${signed_dir}"

  echo ""
  printf "\e[1m\e[92m=======================================================================\e[0m\n"
  printf "\e[1m\e[92m Processing %s...\e[0m\n" "${archive}"
  printf "\e[1m\e[92m=======================================================================\e[0m\n"

  echo ""
  echo "Extracting application bundle."
  tar xfz "${f}" -C "${signed_dir}"
  pkg="$(ls -1 "${signed_dir}")"
  signed_bundle="${signed_dir}/${pkg}"

  echo ""
  echo "Signing application bundle at:"
  echo ""
  echo "${signed_bundle}"
  codesign --deep --force --verify --sign "${APPLE_CODESIGN_KEY}" --options runtime "${signed_bundle}"

  echo ""
  echo "Verifying signature:"
  codesign --verify --verbose=4 "${signed_bundle}"
  #codesign --display --verbose=4 "${signed_bundle}"

  echo ""
  echo "Verifying access for Gatekeeper:"
  spctl --assess --verbose=4 --type execute "${signed_dir}/${pkg}"

  echo ""
  echo "Compressing application bundle to:"
  signed_tar="${signed_dir}/${archive_name}.tar.gz"
  echo "${signed_tar}"
  cd "${signed_dir}"
  rm -f "${signed_tar}"
  tar cfz "${signed_tar}" "$(basename "${signed_bundle}")"

  echo ""
  echo "Compressing application bundle to:"
  signed_zip="${signed_dir}/${archive_name}.zip"
  echo "${signed_zip}"
  cd "${signed_dir}"
  rm -f "${signed_zip}"
  # According to Apples documentation "Customizing the Notarization Workflow" at
  # https://developer.apple.com/documentation/xcode/notarizing_macos_software_before_distribution/customizing_the_notarization_workflow
  # we can't use the ZIP command, as it leads to problems in the notarization process.
  # Therefore we're using ditto instead.
  #zip -r -q "${signed_zip}" "$(basename "${signed_bundle}")"
  ditto -c -k --keepParent "$(basename "${signed_bundle}")" "${signed_zip}"

done

if [[ "${FOUND}" == "0" ]]; then
  echo "ERROR: No macOS packages were found at:"
  echo "${TARGET_DIR}"
  exit 1
fi
