#!/usr/bin/env tclsh
#
# Copyright (c) 2015-2017 OpenIndex.de
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

package require Tk
package require msgcat

namespace eval ::support {
  variable TITLE
  variable VERSION
  variable ICON
  variable WRAPPED
  variable APP_DIR
  variable DATA_DIR
  variable TEMP_DIR
  variable LOG_NAME
  variable MAC_APPLICATION_BUNDLE 0
  variable FRAME
  variable CONNECTED 0

  # Launch application.
  proc launch {dir wrapped version} {
    global env
    global tcl_platform
    variable MAC_APPLICATION_BUNDLE

    # Get application base path.
    if {$wrapped && [info exists env(MAC_APPLICATION_BUNDLE)]} {
      variable APP_DIR [file dirname [file dirname [file dirname [file dirname $dir]]]]
      variable LOG_NAME [file tail [file dirname [file dirname [file dirname $dir]]]]

      set MAC_APPLICATION_BUNDLE 1
      set pos [string last "." $LOG_NAME]
      if {$pos > 0} {
        set LOG_NAME [string range $LOG_NAME 0 [expr {$pos-1}]]
      }
    } elseif {$wrapped} {
      variable APP_DIR [file dirname $dir]
      variable LOG_NAME [file tail $dir]

      # Remove exe file extension from log name on Windows.
      if {[::support::utils::is_windows]} {
        set pos [string last "." $LOG_NAME]
        if {$pos > 0} {
          set LOG_NAME [string range $LOG_NAME 0 [expr {$pos-1}]]
        }
      }
    } else {
      variable APP_DIR $dir
      variable LOG_NAME "support"
    }

    # Init logging.
    set ::support::logger::FILE [file join $APP_DIR [format "%s.log" $LOG_NAME]]
    fconfigure stdout -buffering line
    fconfigure stderr -buffering line
    chan push stdout ::support::logger
    chan push stderr ::support::logger

    # Init translations.
    ::msgcat::mcload [file join $dir "lib" "app-support" "msgs"]

    # Set application settings.
    variable TITLE [_ "Remote Support Tool"]
    variable VERSION $version
    variable WRAPPED $wrapped
    variable DATA_DIR [file join $dir "data"]

    # Detect temporary directory.
    variable TEMP_DIR [file join [::support::utils::get_temp_dir] "temp-support-[pid]"]
    if {![file exists $TEMP_DIR]} {
      if {[catch {file mkdir $TEMP_DIR}]} {
        puts "ERROR: The temporary directory \"$TEMP_DIR\" was not created!"
      }
    } elseif {![file isdirectory $TEMP_DIR]} {
      puts "ERROR: The temporary directory \"$TEMP_DIR\" is not a directory!"
    }

    # Print some informations.
    puts ""
    puts "-----------------------------------------------------------------------------"
    puts " $TITLE $VERSION"
    puts "-----------------------------------------------------------------------------"
    puts " system         : $tcl_platform(os) $tcl_platform(osVersion)"
    puts " machine        : $tcl_platform(machine) / $tcl_platform(platform)"
    puts " host name      : [info hostname]"
    puts " user name      : $tcl_platform(user)"
    puts " user home      : $env(HOME)"
    puts " tcl version    : [info patchlevel]"
    if {[info exists tcl_platform(threaded)]} {
      puts " tcl threads    : enabled"
    } else {
      puts " tcl threads    : disabled"
    }
    puts " tcl executable : [info nameofexecutable]"
    puts " root directory : $dir"
    puts " work directory : [pwd]"
    puts " temp directory : $TEMP_DIR"
    puts "-----------------------------------------------------------------------------"
    puts "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR"
    puts "IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,"
    puts "FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE"
    puts "AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER"
    puts "LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,"
    puts "OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN"
    puts "THE SOFTWARE."
    puts "-----------------------------------------------------------------------------"
    #parray env
    #puts "-----------------------------------------------------------------------------"

    # Load global configuration.
    set cfgFile [file join $DATA_DIR config_global.ini]
    if {$cfgFile != "" && [file isfile $cfgFile]} {
      ::support::Config::configure $cfgFile
    }

    # Load custom configuration.
    set cfgFile [file join $DATA_DIR config.ini]
    if {$cfgFile != "" && [file isfile $cfgFile]} {
      ::support::Config::configure $cfgFile
    }
    set cfgFile [file join $APP_DIR config.ini]
    if {$cfgFile != "" && [file isfile $cfgFile]} {
      puts "Load custom configuration from '$cfgFile'."
      ::support::Config::configure $cfgFile
    }

    # Load application icon.
    variable ICON [::support::utils::load_image_file icon.png]

    # Initialize VNC session.
    ::support::session::init

    if {[::support::utils::is_darwin]} {

      # Show settings window through the Mac OS X menubar.
      proc ::tk::mac::ShowPreferences {} {
        ::support::SettingsWindow::open
      }

      # Show about window through the Mac OS X menubar.
      proc ::tkAboutDialog {} {
        ::support::AboutWindow::open
      }
    }

    # Create main frame.
    ::support::ApplicationWindow::open

    # Mac OS X does not put the application window into foreground.
    # As long as we find no better solution, the application is put into
    # foreground via AppleScript.
    if {[::support::utils::is_darwin]} {
      set script "tell application \"System Events\"\n \
      set frontmost of the first process whose unix id is [pid] to true\n \
      end tell"

      if { [catch {exec osascript -e $script} result] } {
        puts "Can't put application window into foreground!"
        puts $::errorInfo
      }
    }
  }

  # Shutdown application.
  proc shutdown {} {
    exit
  }

  # Shorthand method for translation.
  proc translate {s args} {
    return [::msgcat::mc $s {*}$args]
  }

  # Create VNC connection.
  proc connect {} {
    variable CONNECTED

    ::support::ApplicationWindow::setStatusConnecting

    # Launch VNC session.
    set result [::support::session::start]
    if {$result != 1} {
      set CONNECTED 0
      puts "VNC connection failed!"
      ::support::ApplicationWindow::setStatusError
      return
    }

    # Register connection.
    set CONNECTED 1

    # Check for valid connection after some seconds.
    after 5000 ::support::ping 1
  }

  # Close VNC connection.
  proc disconnect {{force 0}} {
    variable CONNECTED 0
    if {$force == 1} {
      ::support::session::stop
      ::support::ApplicationWindow::setStatusDisconnected
    }

  }

  # Test, if a VNC session is currently running.
  proc ping {{firstPing 0}} {
    #puts "PING"
    variable CONNECTED
    set running 1

    if {$running == 1 && $CONNECTED != 1} {
      set running 0
      #puts "> VNC connection is closed"
    }

    if {$running == 1 && ![::support::session::is_running]} {
      set running 0
      #puts "> VNC is not running anymore"
    }

    if {$running == 1} {

      if {$firstPing == 1} {
        ::support::ApplicationWindow::setStatusConnected
      }

      # Again check for valid connection after some seconds.
      after 2500 ::support::ping

    } else {
      ::support::disconnect 1
    }
  }
}


# Handler that writes stdout & stderr into a separate file.
namespace eval ::support::logger {
  variable FILE
  variable HANDLE

  proc clear {handle} {
  }

  proc finalize {handle} {
    variable HANDLE
    close $HANDLE
    unset HANDLE
  }

  proc initialize {handle mode} {
    variable FILE
    variable HANDLE
    if {![info exists HANDLE]} {
      set HANDLE [open $FILE w]
    }
    return {clear finalize initialize flush write}
  }

  proc flush {handle} {
    variable HANDLE
    ::flush $HANDLE
  }

  proc write {handle buffer} {
    variable HANDLE
    puts -nonewline $HANDLE $buffer
    flush $handle
    return $buffer
  }

  namespace export *
  namespace ensemble create
}


# Shorthand method for translations.
proc _ {s args} {
  return [::support::translate $s {*}$args]
}

# Override exit method
# to do some cleanups before shutdown.
rename exit __exit
proc exit {} {
  puts "Shutdown application. Have a nice day!"
  if {$::support::CONNECTED == 1} {
    ::support::disconnect 1
  }

  # Remove temporary files explicitly.
  foreach f [::support::utils::get_files $::support::TEMP_DIR] {
    if {[file isfile $f] && [catch {file delete -force $f}]} {
      puts "WARNING: Can't remove temporary file \"$f\"!"
      puts $::errorInfo
    }
  }

  # Remove temporary folder recursively.
  if {[catch {file delete -force $::support::TEMP_DIR}]} {
    puts "WARNING: Can't cleanup temporary directory \"$::support::TEMP_DIR\"!"
    puts $::errorInfo
  }
  __exit
}
