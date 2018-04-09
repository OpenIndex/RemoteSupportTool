#!/usr/bin/env tclsh
#
# Copyright (c) 2015-2018 OpenIndex.de
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

namespace eval ::support::utils {

  # Center a window on screen.
  proc center_window {w {width 640} {height 480}} {
    set x [expr { ( [winfo vrootwidth  $w] - $width  ) / 2 }]
    set y [expr { ( [winfo vrootheight $w] - $height ) / 2 }]
    wm geometry $w ${width}x${height}+${x}+${y}
  }

  # Load an image from application data.
  proc load_image_file {name} {
    set path [file join $::support::DATA_DIR $name]
    if {[file exists $path]} {
      return [image create photo -format png -file $path]
    }
    puts "Can't find an image at '$path'!"
    return
  }

  # Get path to temporary directory.
  proc get_temp_dir {} {
    global env

    if {[info exists env(TMPDIR)]} {
      return $env(TMPDIR)
    }
    if {[info exists env(TEMPDIR)]} {
      return $env(TEMPDIR)
    }
    if {[info exists env(TEMP)]} {
      return $env(TEMP)
    }
    if {[info exists env(TMP)]} {
      return $env(TMP)
    }
    if {![is_windows] && [file writable /usr/tmp]} {
      return /usr/tmp
    }
    if {![is_windows] && [file writable /tmp]} {
      return /tmp
    }
    if {[info exists env(HOME)]} {
      return $env(HOME)
    }
    return $::support::APP_DIR
  }

  # Test, if the program runs on Mac OS X / Darwin.
  proc is_darwin {} {
    global tcl_platform
    set os [string tolower $tcl_platform(os)]
    return [string match "darwin*" $os]
  }

  # Test, if the program runs on Linux.
  proc is_linux {} {
    global tcl_platform
    set os [string tolower $tcl_platform(os)]
    return [string match "linux*" $os]
  }

  # Test, if the program runs on Windows.
  proc is_windows {} {
    global tcl_platform
    set os [string tolower $tcl_platform(os)]
    return [string match "windows*" $os]
  }

  # Get a list of child processes.
  proc process_children {processIds} {

    if {[is_windows]} {
      error "Windows is not supported."
    }

    set children [list]
    if {[llength $processIds] < 1} {
      return $children
    }
    foreach processId $processIds {
      if {[is_darwin]} {
        lappend children {*}[process_children_darwin $processId]
      } elseif {[is_linux]} {
        lappend children {*}[process_children_linux $processId]
      }
    }
    return $children
  }

  # Get a list of child processes on Mac OS X.
  proc process_children_darwin {processId} {
    if {[catch {exec bash << "ps -o ppid= -o pid= -A | awk '\$1 == $processId\{print \$2\}'"} result]} {
      puts "Can't fetch children of process '$processId'!"
      puts $::errorInfo
      return [list]
    }
    return [split [string trim $result] "\n"]
  }

  # Get a list of child processes on Linux.
  proc process_children_linux {processId} {
    if {[catch {exec bash << "ps -o ppid= -o pid= -A | awk '\$1 == $processId\{print \$2\}'"} result]} {
      puts "Can't fetch children of process '$processId'!"
      puts $::errorInfo
      return [list]
    }
    return [split [string trim $result] "\n"]
  }

  # Test, if a certain process is running.
  proc process_is_running {processId} {
    if {[is_darwin] && [process_is_running_darwin $processId]} {
      return 1
    }
    if {[is_linux] && [process_is_running_linux $processId]} {
      return 1
    }
    if {[is_windows] && [process_is_running_windows $processId]} {
      return 1
    }
    return 0
  }

  # Test, if a certain process is running on Mac OS X.
  proc process_is_running_darwin {processId} {

    if {[catch {exec bash << "ps -p $processId -o state="} result]} {
      puts "Can't fetch process '$processId'!"
      puts $::errorInfo
      return 0
    }

    set state [lindex [split [string trim $result] "\n"] end]
    puts "Checking process $processId: $state"
    set s [string index  $state 0]
    if {$s=="I" || $s=="R" || $s=="S" || $s=="U"} {
      return 1
    }
    return 0
  }

  # Test, if a certain process is running on Linux.
  proc process_is_running_linux {processId} {
    if {[catch {exec bash << "ps -p $processId -o state="} result]} {
      puts "Can't fetch process '$processId'!"
      puts $::errorInfo
      return 0
    }

    set state [lindex [split [string trim $result] "\n"] end]
    puts "Checking process $processId: $state"
    set s [string index  $state 0]
    if {$s=="D" || $s=="R" || $s=="S" || $s=="W"} {
      return 1
    }
    return 0
  }

  # Test, if a certain process is running on Windows.
  proc process_is_running_windows {processId} {
    if {[catch {exec tasklist "/FI" "PID eq $processId" "/FO" "CSV" "/NH"} result]} {
      puts "Can't fetch process '$processId'!"
      puts $::errorInfo
      return 0
    }

    set result [string trim $result]
    puts "Checking process $processId: $result"
    if {[string first "\"$processId\"" $result] > -1} {
      return 1
    }
    return 0
  }

  # Stop a currently running process.
  proc process_kill {processId} {
    if {[is_darwin]} {
      return [process_kill_darwin $processId]
    }
    if {[is_linux]} {
      return [process_kill_linux $processId]
    }
    if {[is_windows]} {
      return [process_kill_windows $processId]
    }
    return 0
  }

  # Stop a currently running process on Mac OS X.
  proc process_kill_darwin {processId} {
    puts "Killing process '$processId'."
    if {[catch {exec bash << "kill $processId"} result]} {
      puts "Can't kill process '$processId'!"
      puts $::errorInfo
      return 0
    }
    return 1
  }

  # Stop a currently running process on Linux.
  proc process_kill_linux {processId} {
    puts "Killing process '$processId'."
    if {[catch {exec bash << "kill $processId"} result]} {
      puts "Can't kill process '$processId'!"
      puts $::errorInfo
      return 0
    }
    return 1
  }

  # Stop a currently running process on Windows.
  proc process_kill_windows {processId} {
    error "Not implemented yet!"
  }

  # Make a modal window.
  proc modal_init {id} {
    wm transient $id $::support::ApplicationWindow::ID
    raise $id
    focus $id
    grab $id
  }

  # Release a modal window.
  proc modal_release {id} {
    grab release $id
    wm withdraw $id
    update
    destroy $id
  }

  # Open a website in the web browser.
  proc open_browser {url} {
    # open is the OS X equivalent to xdg-open on Linux, start is used on Windows
    set commands {xdg-open open start}
    foreach browser $commands {
      if {$browser eq "start"} {
        set command [list {*}[auto_execok start] {}]
      } else {
        set command [auto_execok $browser]
      }
      if {[string length $command]} {
        break
      }
    }

    if {[string length $command] == 0} {
      return -code error "couldn't find browser"
    }
    if {[catch {exec {*}$command $url &} error]} {
      return -code error "couldn't execute '$command': $error"
    }
  }

  # Get the path of a certain application.
  proc get_application {name} {
    if {[is_darwin] || [is_linux]} {
      return [exec which $name]
    }
    if {[is_windows]} {
      return [exec where $name]
    }
    error "Can't get application path for this operating system!"
  }

  # Get a recursive list of files in a directory.
  proc get_files {{dir .}} {
    set res {}
    foreach i [lsort [glob -nocomplain -dir $dir *]] {
      if {[file type $i] eq {directory}} {
        eval lappend res [get_files $i]
      } else {
        lappend res $i
      }
    }
    set res
  }
}
