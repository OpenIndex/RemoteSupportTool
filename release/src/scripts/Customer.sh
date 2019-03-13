#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# RemoteSupportTool for customers
# Copyright 2015-2019 OpenIndex.de
# ----------------------------------------------------------------------------

# Use a specific command to launch the Java Runtime Environment.
JAVA=""

# Set memory settings of the Java Runtime Environment.
JAVA_HEAP_MINIMUM="32m"
JAVA_HEAP_MAXIMUM="512m"

# Set additional parameters for the Java Runtime Environment.
JAVA_OPTS="-Dfile.encoding=UTF-8"

# Set application to start.
APP="de.openindex.support.customer/de.openindex.support.customer.CustomerApplication"

# Detect directories.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$( cd "$( dirname "$SCRIPT_DIR" )" && pwd )"

# OS specific initialization.
SYSTEM="$( uname -s )"
case "$SYSTEM" in

    Darwin)
        echo "Initializing macOS environment..."
        JAVA_OPTS="$JAVA_OPTS -Dapple.laf.useScreenMenuBar=true"
        JAVA_OPTS="$JAVA_OPTS -Xdock:name=CustomerSupportTool"
        JAVA_OPTS="$JAVA_OPTS -Xdock:icon=./share/icon.icns"
        ;;

    Linux)
        echo "Initializing Linux environment..."
        ;;

    *)
        echo "Initializing unknown environment ($SYSTEM)..."
        ;;

esac

# Use bundled Java runtime environment, if no JAVA variable was specified.
if [[ -z "$JAVA" ]] ; then
    JAVA="$BASE_DIR/bin/java"
fi

# Launch the application.
cd "$BASE_DIR"
exec "$JAVA" \
    -Xms${JAVA_HEAP_MINIMUM} \
    -Xmx${JAVA_HEAP_MAXIMUM} \
    "$JAVA_OPTS" \
    -p "modules" \
    -m "$APP" \
    "$@"
