#!/usr/bin/env tclsh
#
# Helper functions for the build environment.
#
# Copyright 2015-2017 OpenIndex.de.
# Distributed under the MIT License.
# See accompanying LICENSE.txt file or at http://opensource.org/licenses/MIT
#

proc get_machine {} {
  global tcl_platform
  set machine $::tcl_platform(machine)
  if {$machine == "x86_64" || $machine == "amd64"} {
    return "amd64"
  }
  if {$machine == "i686" || $machine == "i586" || $machine == "i386"} {
    return "i386"
  }
  return
}

proc get_tclkit {} {
  global TCLKIT_LINUX_AMD64
  global TCLKIT_LINUX_I386
  global TCLKIT_MAC
  global TCLKIT_WINDOWS

  if {[is_darwin]} {
    return $TCLKIT_MAC
  }
  if {[is_linux]} {
    set machine [get_machine]
    if {$machine == "amd64"} {
      return $TCLKIT_LINUX_AMD64
    }
    if {$machine == "i386"} {
      return $TCLKIT_LINUX_I386
    }
  }
  if {[is_windows]} {
    return $TCLKIT_WINDOWS
  }

  error "There is no tclkit available for your operating system!"
}

proc is_darwin {} {
  global tcl_platform
  set os [string tolower $tcl_platform(os)]
  return [string match "darwin*" $os]
}

proc is_linux {} {
  global tcl_platform
  set os [string tolower $tcl_platform(os)]
  return [string match "linux*" $os]
}

proc is_windows {} {
  global tcl_platform
  set os [string tolower $tcl_platform(os)]
  return [string match "windows*" $os]
}

proc targz {dir archive} {
  cd [file dirname $dir]
  set name [file tail $dir]

  #package require tar
  #set chan [open $archive a]
  #zlib push gzip $chan
  #tar::create $chan {*}[glob -nocomplain "$name/*"] -chan
  #::tar::contents new.tar
  #close $chan

  if {[is_darwin] || [is_linux]} {
    global TAR
    if {[catch {exec $TAR cfz $archive $name} result]} {
      puts "ERROR: Can't create TAR.GZ archive!"
      if {$result != ""} { puts $result }
      puts $::errorInfo
    }
    return
  }
  if {[is_windows]} {
    global SEVENZIP

    #Archive test1.txt and test2.txt into test.tar
    #  7z a -ttar test.tar test1.txt test2.txt
    #Compress test.tar to test.tgz
    #  7z a -tgzip test.tgz test.tar

    set temp "$name.tar"
    if {[catch {exec $SEVENZIP a -ttar $temp $name} result]} {
      puts "ERROR: Can't create TAR archive!"
      if {$result != ""} { puts $result }
      puts $::errorInfo
    }
    if {[catch {exec $SEVENZIP a -tgzip $archive $temp} result]} {
      puts "ERROR: Can't create TAR.GZ archive!"
      if {$result != ""} { puts $result }
      puts $::errorInfo
    }

    #if {[catch {exec $SEVENZIP a -ttar -so temp.tar $name | $SEVENZIP a -si $name} result]} {
    #  puts "ERROR: Can't create TAR.GZ archive!"
    #  if {$result != ""} { puts $result }
    #  puts $::errorInfo
    #}
    return
  }
  error "The targz method is not implemented for your operating system!"
}

proc touch {path} {
  if {[is_darwin] || [is_linux]} {
    if {[catch {exec touch $path} result]} {
      puts "ERROR: Can't execute touch!"
      if {$result != ""} { puts $result }
      puts $::errorInfo
    }
    return
  }
  if {[is_windows]} {
    if {[catch {exec copy "/b" "$path" "+,,"} result]} {
      puts "ERROR: Can't execute touch!"
      if {$result != ""} { puts $result }
      puts $::errorInfo
    }
    return
  }
  error "The touch method is not implemented for your operating system!"
}

proc which {command} {
  if {[is_darwin] || [is_linux]} {
    if {[catch {exec which $command} result]} {
      puts "WARNING: Can't find the \"$command\" application!"
      #if {$result != ""} { puts $result }
      #puts $::errorInfo
      return
    }
    return $result
  }
  if {[is_windows]} {
    if {[catch {exec where $command} result]} {
      puts "WARNING: Can't find the \"$command\" application!"
      #if {$result != ""} { puts $result }
      #puts $::errorInfo
      return
    }
    return $result
  }
  error "The which method is not implemented for your operating system!"
}
