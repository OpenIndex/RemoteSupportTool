#!/usr/bin/env bash
#
# Build all supported OpenJDK runtime environments.
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

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
set -e

init() {
  echo ""
  printf "\e[1m\e[92m=================================================\e[0m\n"
  printf "\e[1m\e[92m launching %s\e[0m\n" "$1"
  printf "\e[1m\e[92m=================================================\e[0m\n"
  echo ""
  exec "$1"
}
export -f init

cd "${DIR}"
find "src/openjdk/" \
  -maxdepth 1 \
  -type f \
  -name "init-*.sh" \
  -exec bash -c 'init {}' \;
