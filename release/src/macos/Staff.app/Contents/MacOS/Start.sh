#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# Start StaffSupportTool
# Copyright 2015-2019 OpenIndex.de
# ----------------------------------------------------------------------------

SCRIPT_DIR=$( cd $( dirname ${BASH_SOURCE[0]} ) && pwd )
CONTENTS_DIR=$( cd $( dirname ${SCRIPT_DIR} ) && pwd )
START_SH="$CONTENTS_DIR/Resources/bin/Start.sh"
exec ${START_SH}
