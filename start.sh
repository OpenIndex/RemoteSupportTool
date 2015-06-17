#!/bin/bash
#
# Start application directly from source code.
#
# Copyright 2015 OpenIndex.de.
# Distributed under the MIT License.
# See accompanying LICENSE.txt file or at http://opensource.org/licenses/MIT
#

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#export LANG=en
set -e

cd "$BASE_DIR"
PYTHONPATH="$BASE_DIR"
export PYTHONPATH
python src/Support.py
