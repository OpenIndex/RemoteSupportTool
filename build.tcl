#!/usr/bin/env tclsh
#
# Build application bundles.
#
# Copyright (c) 2015-2018 OpenIndex.de
# Distributed under the MIT License.
# See accompanying LICENSE.txt file or at http://opensource.org/licenses/MIT
#

# initialization
source [file join [file normalize [file dirname $argv0]] init.tcl]

puts ""
puts "========================================================================="
puts " $PROJECT $VERSION: build application bundles"
puts "========================================================================="
puts ""


# Create a binary package, that contains tclkit and application sources.
proc create_package {output tclkit arch {archTarget ""}} {
  global BUILD_DIR
  global BUILD_SRC_DIR
  global BUILD_TCLKIT
  global SRC_DIR
  global TCLKIT
  global SDX

  if {$archTarget == ""} {
    set archTarget $arch
  }

  set tclkit_temp [file join $BUILD_DIR [file tail $tclkit]]
  file copy -force $tclkit $tclkit_temp
  file copy -force [file join $SRC_DIR "data" $arch] [file join $BUILD_SRC_DIR "data" $archTarget]

  if { [catch {exec $BUILD_TCLKIT $SDX wrap $output -vfs $BUILD_SRC_DIR -runtime $tclkit_temp} result] } {
    puts "ERROR: Can't create binary package!"
    puts $::errorInfo
  }

  file delete -force [file join $BUILD_SRC_DIR "data" $archTarget]
}

# Modify resources of the created EXE file.
proc postprocess_exe {dir} {
  global RESHACK

  set rc [file join $dir "application.rc"]
  set script [file join $dir "reshack.script"]
  cd $dir

  if {[is_windows]} {

    # Execute ResourceHacker.exe directly on Windows systems.
    if {$rc != "" && [file isfile $rc]} {
      if { [catch {exec $RESHACK -open application.rc -save application.res -action compile -log CONSOLE} result] } {
        puts "ERROR: Can't compile resources in windows binary!"
        puts $::errorInfo
      }
      #puts "ResourceHacker: $result"
    }

    if {$script != "" && [file isfile $script]} {
      if { [catch {exec $RESHACK -script "reshack.script"} result] } {
        puts "ERROR: Can't modify resources in windows binary!"
        puts $::errorInfo
      }
      #puts "ResourceHacker: $result"
    }

  } else {

    # Execute ResourceHacker.exe through WINE on non-Windows systems.
    global WINE
    if {$WINE == "" || ![file executable $WINE]} {
      puts "ERROR: Can't find a WINE installation!"
      puts "Therefore we can't replace icons and resources of the created EXE file."
      puts "The created EXE file is still usable but it will contain a TK icon and references to the TK authors."
      puts "Install WINE on your system or build the application on a Windows system in order to get an EXE file with correct resources."
      return
    }

    if {$rc != "" && [file isfile $rc]} {
      if { [catch {exec $WINE $RESHACK -open application.rc -save application.res -action compile -log CONSOLE} result] } {
        puts "ERROR: Can't compile resources in windows binary!"
        puts $::errorInfo
      }
      #puts "ResourceHacker: $result"
    }

    if {$script != "" && [file isfile $script]} {
      if { [catch {exec $WINE $RESHACK -script "reshack.script"} result] } {
        puts "ERROR: Can't modify resources in windows binary!"
        puts $::errorInfo
      }
      #puts "ResourceHacker: $result"
    }

  }

  return [file join $dir "application-modified.exe"]
}


set BUILD_SRC_DIR [file join $BUILD_DIR "$PROJECT.vfs"]

if {[is_windows]} {
  # Use tclkitsh binary on windows system for packaging.
  set BUILD_TCLKIT $TCLKITSH_WINDOWS
} else {
  # Use tclkit binary on other systems for packaging.
  set BUILD_TCLKIT $TCLKIT
}

puts "cleanup"
if {[file exists $BUILD_DIR]} {
  file delete -force $BUILD_DIR
}
if {[file exists $TARGET_DIR]} {
  file delete -force $TARGET_DIR
}
file mkdir $BUILD_DIR
file mkdir $TARGET_DIR

puts "prepare build"
file copy $SRC_DIR $BUILD_SRC_DIR
foreach log [glob -nocomplain -directory $BUILD_SRC_DIR -type f  "*.log"] {
  file delete $log
}

puts "create $PROJECT-$VERSION.kit"
if { [catch {exec $BUILD_TCLKIT $SDX wrap [file join $TARGET_DIR "$PROJECT-$VERSION.kit"] -vfs $BUILD_SRC_DIR} result] } {
  puts "ERROR: Can't starkit bundle!"
  puts $::errorInfo
}

puts "prepare binary builds"
foreach dir [glob -nocomplain -directory [file join $BUILD_SRC_DIR "data"] -type d  "*"] {
  file delete -force $dir
}

puts "create $PROJECT-$VERSION-linux-amd64"
create_package [file join $TARGET_DIR "$PROJECT-$VERSION-linux-amd64"] $TCLKIT_LINUX_AMD64 "linux-amd64"

puts "create $PROJECT-$VERSION-linux-i386"
create_package [file join $TARGET_DIR "$PROJECT-$VERSION-linux-i386"] $TCLKIT_LINUX_I386 "linux-i386"

puts "create $PROJECT-$VERSION-macosx"
create_package [file join $TARGET_DIR "$PROJECT-$VERSION-macosx"] $TCLKIT_MAC "darwin"

puts "create $PROJECT-$VERSION.app"
set BUILD_BUNDLE [file join $BUILD_DIR "darwin" "$PROJECT-$VERSION.app"]
file mkdir $BUILD_BUNDLE
file mkdir [file join $BUILD_BUNDLE "Contents"]
file mkdir [file join $BUILD_BUNDLE "Contents" "Framework"]
file mkdir [file join $BUILD_BUNDLE "Contents" "MacOS"]
file mkdir [file join $BUILD_BUNDLE "Contents" "Resources"]
file copy [file join $BASE_DIR "misc" "darwin" "Info.plist"] [file join $BUILD_BUNDLE "Contents"]
file copy [file join $BASE_DIR "misc" "darwin" "application.icns"] [file join $BUILD_BUNDLE "Contents" "Resources"]
file copy [file join $TARGET_DIR "$PROJECT-$VERSION-macosx"] [file join $BUILD_BUNDLE "Contents" "MacOS" "application"]
targz $BUILD_BUNDLE [file join $TARGET_DIR "$PROJECT-$VERSION-macosx.app.tar.gz"]

puts "create $PROJECT-$VERSION.exe"
set BUILD_WINDOWS_DIR [file join $BUILD_DIR "windows"]
file mkdir $BUILD_WINDOWS_DIR
create_package [file join $BUILD_WINDOWS_DIR "application.exe"] $TCLKIT_WINDOWS "windows"

puts "post processing $PROJECT-$VERSION.exe"
file copy [file join $BASE_DIR "misc" "windows" "application.ico"] [file join $BUILD_WINDOWS_DIR "application.ico"]
file copy [file join $BASE_DIR "misc" "windows" "application.rc"] [file join $BUILD_WINDOWS_DIR "application.rc"]
file copy [file join $BASE_DIR "misc" "windows" "reshack.script"] [file join $BUILD_WINDOWS_DIR "reshack.script"]
set modifiedExe [postprocess_exe $BUILD_WINDOWS_DIR]
if {$modifiedExe != "" && [file isfile $modifiedExe]} {
  file copy [file join $BUILD_WINDOWS_DIR "application-modified.exe"] [file join $TARGET_DIR "$PROJECT-$VERSION.exe"]
} else {
  file copy [file join $BUILD_WINDOWS_DIR "application.exe"] [file join $TARGET_DIR "$PROJECT-$VERSION.exe"]
}

puts "create $PROJECT-$VERSION-xp.exe"
set BUILD_WINDOWS_DIR [file join $BUILD_DIR "windows-xp"]
file mkdir $BUILD_WINDOWS_DIR
create_package [file join $BUILD_WINDOWS_DIR "application.exe"] $TCLKIT_WINDOWS "windows-xp" "windows"

puts "post processing $PROJECT-$VERSION-xp.exe"
file copy [file join $BASE_DIR "misc" "windows" "application.ico"] [file join $BUILD_WINDOWS_DIR "application.ico"]
file copy [file join $BASE_DIR "misc" "windows" "application.rc"] [file join $BUILD_WINDOWS_DIR "application.rc"]
file copy [file join $BASE_DIR "misc" "windows" "reshack.script"] [file join $BUILD_WINDOWS_DIR "reshack.script"]
set modifiedExe [postprocess_exe $BUILD_WINDOWS_DIR]
if {$modifiedExe != "" && [file isfile $modifiedExe]} {
  file copy [file join $BUILD_WINDOWS_DIR "application-modified.exe"] [file join $TARGET_DIR "$PROJECT-$VERSION-xp.exe"]
} else {
  file copy [file join $BUILD_WINDOWS_DIR "application.exe"] [file join $TARGET_DIR "$PROJECT-$VERSION-xp.exe"]
}

# On Windows systems there is an unusable bat file written into the target folder.
# To avoid any confusions we're deleting this file.
foreach f [glob -nocomplain -directory $TARGET_DIR -type f  "*.bat"] {
  file delete $f
}
