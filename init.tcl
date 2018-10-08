#!/usr/bin/env tclsh
#
# Configurations for the build environment.
#
# Copyright (c) 2015-2018 OpenIndex.de
# Distributed under the MIT License.
# See accompanying LICENSE.txt file or at http://opensource.org/licenses/MIT
#

#
# configurations
#

# project settings
set PROJECT "RemoteSupportTool"
set VERSION "0.5.1"
set AUTHOR_NAME "OpenIndex.de"
set AUTHOR_EMAIL "info@openindex.de"

# preferred applications
set TAR ""
set XGETTEXT ""
set MSGFMT ""
set MSGMERGE ""
set WINE ""

# setup internal pathes
set BASE_DIR [file normalize [file dirname $argv0]]
set SRC_DIR [file join $BASE_DIR src]
set SRC_APP_DIR [file join $SRC_DIR "lib" "app-support"]
set SRC_MSGS_DIR [file join $SRC_APP_DIR "msgs"]
set UTILS_DIR [file join $BASE_DIR "utils"]
set BUILD_DIR [file join $BASE_DIR "build"]
set TARGET_DIR [file join $BASE_DIR "target"]
set I18N_DIR [file join $BASE_DIR "misc" "i18n"]
set I18N_PO_DIR [file join $I18N_DIR "app-support"]
set I18N_POT [file join $I18N_DIR "app-support.pot"]
set SDX [file join $UTILS_DIR "sdx-20110317.kit"]
set RESHACK [file join $UTILS_DIR "ResourceHacker.exe"]
set SEVENZIP [file join $UTILS_DIR "7za.exe"]
set TCLKIT_LINUX_AMD64 [file join $UTILS_DIR "tclkit-8.6.6-linux-amd64"]
set TCLKIT_LINUX_I386 [file join $UTILS_DIR "tclkit-8.6.6-linux-i386"]
set TCLKIT_MAC [file join $UTILS_DIR "tclkit-8.6.6-macosx"]
set TCLKIT_WINDOWS [file join $UTILS_DIR "tclkit-8.6.6-windows.exe"]
set TCLKITSH_WINDOWS [file join $UTILS_DIR "tclkitsh-win32.upx.exe"]



#
# start initialization
#

# import functions
source [file join $UTILS_DIR "utils.tcl"]

# detect application pathes
set TCLKIT [get_tclkit]
if {![info exists XGETTEXT] || $XGETTEXT == ""} {
  set XGETTEXT [which "xgettext"]
}
if {![info exists MSGFMT] || $MSGFMT == ""} {
  set MSGFMT [which "msgfmt"]
}
if {![info exists MSGMERGE] || $MSGMERGE == ""} {
  set MSGMERGE [which "msgmerge"]
}
if {![is_windows]} {
  if {![info exists TAR] || $TAR == ""} {
    set TAR [which "tar"]
  }
  if {![info exists WINE] || $WINE == ""} {
    set WINE [which "wine"]
  }
}
