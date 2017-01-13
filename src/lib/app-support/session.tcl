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

namespace eval ::support::session {
  variable PIDS {}
  #variable LOG_FILE

  variable WORK_DIR
  variable WORK_OSXVNC_EXE
  variable WORK_X11VNC_EXE
  variable WORK_TIGHTVNC_EXE
  variable WORK_SSH_EXE
  variable WORK_RUNNING_EXE

  variable VNC_APP_NAME
  variable VNC_APP_VERSION
  variable VNC_APP_LICENSE
  variable VNC_HOST
  variable VNC_PORT
  variable VNC_EXE
  variable VNC_PARAMETERS

  variable SSH_APP_NAME
  variable SSH_APP_VERSION
  variable SSH_APP_LICENSE
  variable SSH_APP_PROVIDED 0
  variable SSH_EXE
  variable SSH_PORT
  variable SSH_USER
  variable SSH_KEY
  variable SSH_KEY_PROVIDED 0
  variable SSH_ENABLED 0

  variable USE_PROVIDED_VNC_APP 0
  variable USE_PROVIDED_SSH_APP 0
  variable USE_PROVIDED_SSH_KEY 0

  # Initialize VNC environment.
  proc init {} {
    if {[::support::utils::is_darwin]} {
      init_darwin
    } elseif {[::support::utils::is_linux]} {
      init_linux
    } elseif {[::support::utils::is_windows]} {
      init_windows
    } else {
      error "Your operating system is not supported!"
    }

    # Get path of the session log file.
    #variable LOG_FILE [file join $::support::APP_DIR [format "%s-session.log" $::support::LOG_NAME]]
    #file delete -force $LOG_FILE

    # Init default vnc settings.
    variable VNC_HOST [::support::Config::getSessionValue "host" ""]
    variable VNC_PORT [::support::Config::getSessionValue "port" "5500"]
    variable VNC_EXE [::support::Config::getSessionValue "vnc-application" ""]
    variable VNC_PARAMETERS [::support::Config::getSessionValue "vnc-parameters" ""]
    if {$VNC_EXE != ""} {
      variable USE_PROVIDED_VNC_APP 0
    } else {
      variable USE_PROVIDED_VNC_APP 1
    }

    # Init default ssh settings.
    variable SSH_PORT [::support::Config::getSessionValue "ssh-port" "22"]
    variable SSH_USER [::support::Config::getSessionValue "ssh-user" ""]
    variable SSH_ENABLED [string tolower [::support::Config::getSessionValue "ssh-enabled" "no"]]
    if {$SSH_ENABLED == "yes" || $SSH_ENABLED == "1" || $SSH_ENABLED == "true"} {
      variable SSH_ENABLED 1
    } else {
      variable SSH_ENABLED 0
    }

    # Detect default ssh key.
    variable SSH_KEY [::support::Config::getSessionValue "ssh-keyfile" ""]
    if {[file isfile [file join $::support::APP_DIR "ssh.key"]]} {
      variable SSH_KEY [file join $::support::APP_DIR "ssh.key"]
    }
    if {[file isfile [file join $::support::DATA_DIR "ssh.key"]]} {
      variable SSH_KEY_PROVIDED 1
      variable USE_PROVIDED_SSH_KEY 1
    }

    # Detect default ssh application.
    variable SSH_EXE [::support::Config::getSessionValue "ssh-application" ""]
    if {[::support::utils::is_darwin] || [::support::utils::is_linux]} {
      if {$SSH_EXE == "" || ![file isfile $SSH_EXE]} {
        set SSH_EXE [::support::utils::get_application ssh]
      }
    }
  }

  # Initialize VNC environment for Mac OS X.
  proc init_darwin {} {
    variable VNC_APP_NAME "OSXvnc"
    variable VNC_APP_VERSION "5.0.1"
    variable VNC_APP_LICENSE "GPLv2"

    variable SSH_APP_NAME "OpenSSH"
    variable SSH_APP_VERSION ""
    variable SSH_APP_LICENSE ""
    variable SSH_APP_PROVIDED 0
    variable USE_PROVIDED_SSH_APP 0

    # Prepare work directory.
    variable WORK_DIR [file join $::support::TEMP_DIR "work"]
    file copy [file join $::support::DATA_DIR "darwin"] $WORK_DIR

    # Get path to OSXvnc-server in work directory.
    variable WORK_OSXVNC_EXE [file join $WORK_DIR "osxvnc" "OSXvnc-server"]
    if {![file isfile $WORK_OSXVNC_EXE]} {
      puts "ERROR: Can't find packaged OSXvnc-server!"
      puts "at $WORK_OSXVNC_EXE"
    } else {
      exec chmod u+x $WORK_OSXVNC_EXE
    }
  }

  # Initialize VNC environment for Linux.
  proc init_linux {} {
    variable VNC_APP_NAME "x11vnc"
    variable VNC_APP_VERSION "0.9.13"
    variable VNC_APP_LICENSE "GPLv2"

    variable SSH_APP_NAME "OpenSSH"
    variable SSH_APP_VERSION ""
    variable SSH_APP_LICENSE ""
    variable SSH_APP_PROVIDED 0
    variable USE_PROVIDED_SSH_APP 0

    # Detect platform (amd64 or i386).
    set platform $::tcl_platform(machine)
    if {$platform == "x86_64" || $platform == "amd64"} {
      set arch "amd64"
    } elseif {$platform == "i686" || $platform == "i586" || $platform == "i386"} {
      set arch "i386"
    } else {
      error "VNC is not supported for the $platform platform!"
    }

    # Prepare work directory.
    variable WORK_DIR [file join $::support::TEMP_DIR "work"]
    file copy [file join $::support::DATA_DIR "linux-$arch"] $WORK_DIR

    # Get path to x11vnc in work directory.
    variable WORK_X11VNC_EXE [file join $WORK_DIR "x11vnc" "x11vnc"]
    if {![file isfile $WORK_X11VNC_EXE]} {
      puts "ERROR: Can't find packaged x11vnc!"
      puts "at $WORK_X11VNC_EXE"
    } else {
      exec chmod u+x $WORK_X11VNC_EXE
    }
  }

  # Initialize VNC environment for Windows.
  proc init_windows {} {
    variable VNC_APP_NAME "TightVNC"
    variable VNC_APP_VERSION "2.8.5"
    variable VNC_APP_LICENSE "GPLv2"

    variable SSH_APP_NAME "OpenSSH"
    variable SSH_APP_VERSION "???"
    variable SSH_APP_LICENSE "BSD"
    variable SSH_APP_PROVIDED 0
    variable USE_PROVIDED_SSH_APP 0

    # Prepare work directory.
    variable WORK_DIR [file join $::support::TEMP_DIR "work"]
    file copy [file join $::support::DATA_DIR "windows"] $WORK_DIR

    # Get path to tvnserver.exe in work directory.
    variable WORK_TIGHTVNC_EXE [file join $WORK_DIR "tightvnc" "tvnserver.exe"]
    if {![file isfile $WORK_TIGHTVNC_EXE]} {
      puts "ERROR: Can't find packaged tvnserver.exe!"
      puts "at $WORK_TIGHTVNC_EXE"
    }

    # Get path to running.bat in work directory.
    variable WORK_RUNNING_EXE [file join $WORK_DIR "running.bat"]
    if {![file isfile $WORK_RUNNING_EXE]} {
      puts "ERROR: Can't find packaged running.bat!"
      puts "at $WORK_RUNNING_EXE"
    }

    # Get path to ssh.exe in work directory.
    variable WORK_SSH_EXE [file join $WORK_DIR "openssh" "bin" "ssh.exe"]
    if {![file isfile $WORK_SSH_EXE]} {
      puts "ERROR: Can't find packaged ssh.exe!"
      puts "at $WORK_SSH_EXE"
    } else {
      # fetch version of packaged ssh
      if {[catch {exec [file nativename $WORK_SSH_EXE] -V 2>@1} result]} {

        puts "ERROR: Can't fetch version of packaged ssh.exe!"
        puts $::errorInfo

      } else {

        if {$result != "" && [string first "OpenSSH_" $result] == 0} {
          set version [lindex [split $result ","] 0]
          set SSH_APP_VERSION [string range $version 8 end]
          set SSH_APP_PROVIDED 1
          set USE_PROVIDED_SSH_APP 1
        } else {
          puts "ERROR: Can't fetch version of packaged ssh.exe!"
          puts "> from response: $result"
        }

      }
    }
  }

  # Test, if VNC session is currently running.
  proc is_running {} {
    if {[::support::utils::is_darwin]} {
      return [is_running_darwin]
    }
    if {[::support::utils::is_linux]} {
      return [is_running_linux]
    }
    if {[::support::utils::is_windows]} {
      return [is_running_windows]
    }
    return 0
  }

  # Test for Mac OS X, if VNC session is currently running.
  proc is_running_darwin {} {
    variable PIDS

    # Check process ids.
    if {[llength $PIDS] < 1} {
      return 0
    }
    foreach processId $PIDS {

      # Check main process.
      if {![::support::utils::process_is_running_darwin $processId]} {
        return 0
      }

      # Check child processes.
      foreach childProcessId [::support::utils::process_children_darwin $processId] {
        if {![::support::utils::process_is_running $childProcessId]} {
          return 0
        }
      }
    }

    return 1
  }

  # Test for Linux, if VNC session is currently running.
  proc is_running_linux {} {
    variable PIDS

    # Check process ids.
    if {[llength $PIDS] < 1} {
      return 0
    }
    foreach processId $PIDS {

      # Check main process.
      if {![::support::utils::process_is_running_linux $processId]} {
        return 0
      }

      # Check child processes.
      foreach childProcessId [::support::utils::process_children_linux $processId] {
        if {![::support::utils::process_is_running_linux $childProcessId]} {
          return 0
        }
      }
    }

    return 1
  }

  # Test for Windows, if VNC session is currently running.
  proc is_running_windows {} {
    variable PIDS
    variable WORK_RUNNING_EXE

    # Check for a running tvnserver.exe.
    if {[catch {exec $WORK_RUNNING_EXE "tvnserver.exe"} result]} {
      puts "Can't check if TightVNC is running!"
      puts $::errorInfo
      return 0
    }
    set result [string trim $result]
    if {$result != "1"} {
      puts "TightVNC is not running anymore ($result)."
      return 0
    }

    return 1
  }

  # Start VNC session.
  proc start {} {
    if {[::support::utils::is_darwin]} {
      return [start_darwin]
    }
    if {[::support::utils::is_linux]} {
      return [start_linux]
    }
    if {[::support::utils::is_windows]} {
      return [start_windows]
    }
    error "VNC is not supported for the operating system!"
  }

  # Start VNC session for Mac OS X.
  proc start_darwin {} {
    variable PIDS
    #variable LOG_FILE
    variable VNC_EXE
    variable VNC_HOST
    variable VNC_PORT
    variable VNC_PARAMETERS
    variable SSH_ENABLED
    variable WORK_OSXVNC_EXE
    variable USE_PROVIDED_VNC_APP

    # Stop currently running VNC session.
    if {[is_running_darwin]} {
      stop_darwin
    }

    puts [string repeat "-" 50]
    puts "Start VNC session for Mac OS X."
    set commands {}

    # Get command for SSH tunneling.
    if {$SSH_ENABLED != 1} {
      set vncHost $VNC_HOST
    } else {
      set vncHost "127.0.0.1"
      lappend commands [join [openssh_prepare] " "]
    }

    # Detect path to OSXvnc-server application.
    if {$USE_PROVIDED_VNC_APP == 1} {
      set vncExe $WORK_OSXVNC_EXE
    } else {
      set vncExe $VNC_EXE
    }
    if {$vncExe == "" || ![file isfile $vncExe] || ![file executable $vncExe]} {
      error "Can't find OSXvnc-server application!"
    }

    # Build command for VNC connection.
    lappend commands [format "%s -connectHost %s -connectPort %s -localhost %s" $vncExe $vncHost $VNC_PORT $VNC_PARAMETERS ]

    # Create VNC command.
    #set command [join $commands "; "]
    set command [join $commands " && "]
    puts $command

    # Execute VNC command.
    #set PIDS [exec bash << $command >>& $LOG_FILE &]
    set PIDS [exec bash << $command >@ stdout &]

    puts "Established VNC connection with process id: $PIDS"
    puts [string repeat "-" 50]
    return 1
  }

  # Start VNC session for Linux.
  proc start_linux {} {
    variable PIDS
    #variable LOG_FILE
    variable VNC_EXE
    variable VNC_HOST
    variable VNC_PORT
    variable VNC_PARAMETERS
    variable SSH_ENABLED
    variable WORK_X11VNC_EXE
    variable USE_PROVIDED_VNC_APP

    # Stop currently running VNC session.
    if {[is_running_linux]} {
      stop_linux
    }

    puts [string repeat "-" 50]
    puts "Start VNC session for Linux."
    set commands {}

    # Get command for SSH tunneling.
    if {$SSH_ENABLED != 1} {
      set vncHost $VNC_HOST
    } else {
      set vncHost "127.0.0.1"
      lappend commands [join [openssh_prepare] " "]
    }

    # Detect path to x11vnc application.
    if {$USE_PROVIDED_VNC_APP == 1} {
      set vncExe $WORK_X11VNC_EXE
    } else {
      set vncExe $VNC_EXE
    }
    if {$vncExe == "" || ![file isfile $vncExe] || ![file executable $vncExe]} {
      error "Can't find x11vnc application!"
    }

    # Build command for VNC connection.
    lappend commands [format "%s -connect_or_exit %s:%s -nopw -nocmds -nevershared -rfbport 0 %s" $vncExe $vncHost $VNC_PORT $VNC_PARAMETERS]

    # Create VNC command.
    #set command [join $commands "; "]
    set command [join $commands " && "]
    puts $command

    # Execute VNC command.
    set PIDS [exec bash << $command >@ stdout &]

    puts "Established VNC connection with process id: $PIDS"
    puts [string repeat "-" 50]
    return 1
  }

  # Start VNC session for Windows.
  proc start_windows {} {
    variable PIDS
    variable VNC_EXE
    variable VNC_HOST
    variable VNC_PORT
    #variable VNC_PARAMETERS
    variable SSH_ENABLED
    variable WORK_TIGHTVNC_EXE
    variable USE_PROVIDED_VNC_APP

    # Stop currently running VNC session.
    if {[is_running_windows]} {
      stop_windows
    }

    puts [string repeat "-" 50]
    puts "Start VNC session for Windows."

    # Detect path to TightVNC application.
    if {$USE_PROVIDED_VNC_APP == 1} {
      set vncExe $WORK_TIGHTVNC_EXE
    } else {
      set vncExe $VNC_EXE
    }
    if {$vncExe == "" || ![file isfile $vncExe] || ![file executable $vncExe]} {
      error "Can't find TightVNC application!"
    }
    set vncExe [file nativename $vncExe]

    # Setup windows registry for TightVNC.
    set registryKey "HKEY_CURRENT_USER\\SOFTWARE\\TightVNC\\Server"
    registry set $registryKey "AcceptHttpConnections" 0 dword
    registry set $registryKey "AcceptRfbConnections" 0 dword
    registry set $registryKey "AllowLoopback" 1 dword
    #registry set $registryKey "GrabTransparentWindows" 0 dword
    registry set $registryKey "RemoveWallpaper" 1 dword
    registry set $registryKey "UseVncAuthentication" 0 dword
    #registry broadcast "Environment"

    # Start TightVNC.
    puts [string repeat "-" 50]
    puts "Start TightVNC"
    puts "$vncExe -run"
    if {[catch {exec $vncExe "-run" &}]} {
      puts "Can't start TightVNC!"
      puts $::errorInfo
      return 0
    }

    # Configure TightVNC.
    puts [string repeat "-" 50]
    puts "Configure TightVNC"
    puts "$vncExe -controlapp -shareprimary"
    if {[catch {exec $vncExe "-controlapp" "-shareprimary"}]} {
      puts "Can't configure TightVNC!"
      puts $::errorInfo
      stop_windows
      return 0
    }

    # Init SSH tunnel.
    if {$SSH_ENABLED != 1} {
      set vncHost $VNC_HOST
    } else {
      set vncHost "127.0.0.1"

      if {[catch {openssh_prepare} sshCommand]} {
        puts "Can't initialize OpenSSH!"
        puts $::errorInfo
        stop_windows
        return 0
      }

      puts [string repeat "-" 50]
      puts "Create SSH tunnel"
      puts [join $sshCommand " "]
      if {[catch {exec {*}$sshCommand &} PIDS]} {
        puts "Can't start OpenSSH!"
        puts $::errorInfo
        stop_windows
        return 0
      }
      puts "Started OpenSSH with process id: $PIDS"

      # Wait until SSH tunnel is available.
      set i 0
      while {1 < 2} {
        puts "Waiting for SSH tunnel to become available."
        after 1000
        if {[tunnel_is_loaded_windows]} {
          puts "SSH tunnel is established."
          break
        }
        incr i
        if {$i > 15} {
          puts "Waited too long for the SSH tunnel to be established."
          stop_windows
          return 0
        }
      }
    }

    # Connect TightVNC.
    set target [format "%s:%s" $vncHost $VNC_PORT]
    puts [string repeat "-" 50]
    puts "Connect TightVNC"
    puts "$vncExe -controlapp -connect $target"
    if {[catch {exec $vncExe "-controlapp" "-connect" $target}]} {
      puts "Can't connect TightVNC!"
      puts $::errorInfo
      stop_windows
      return 0
    }

    puts "Established VNC connection"
    puts [string repeat "-" 50]
    return 1
  }

  # Stop VNC session.
  proc stop {} {
    variable PIDS

    if {[::support::utils::is_darwin]} {
      stop_darwin
    } elseif {[::support::utils::is_linux]} {
      stop_linux
    } elseif {[::support::utils::is_windows]} {
      stop_windows
    }

    set PIDS {}
    return 0
  }

  # Stop VNC session for Mac OS X.
  proc stop_darwin {} {
    variable PIDS

    puts [string repeat "-" 50]
    puts "Stop VNC session for Mac OS X."
    if {[llength $PIDS] < 1} {
      return 0
    }
    foreach processId $PIDS {

      # Kill child processes.
      foreach childProcessId [::support::utils::process_children_darwin $processId] {
        ::support::utils::process_kill_darwin $childProcessId
      }

      # Kill main process.
      ::support::utils::process_kill_darwin $processId
    }
    return 1
  }

  # Stop VNC session for Linux.
  proc stop_linux {} {
    variable PIDS

    puts [string repeat "-" 50]
    puts "Stop VNC session for Linux."
    if {[llength $PIDS] < 1} {
      return 0
    }
    foreach processId $PIDS {

      # Kill child processes.
      foreach childProcessId [::support::utils::process_children_linux $processId] {
        ::support::utils::process_kill_linux $childProcessId
      }

      # Kill main process.
      ::support::utils::process_kill_linux $processId
    }
    return 1
  }

  # Stop VNC session for Windows.
  proc stop_windows {} {
    variable PIDS
    variable VNC_EXE
    variable WORK_TIGHTVNC_EXE
    variable USE_PROVIDED_VNC_APP

    puts [string repeat "-" 50]
    puts "Stop VNC session for Windows."

    # Detect path to TightVNC application.
    if {$USE_PROVIDED_VNC_APP == 1} {
      set vncExe $WORK_TIGHTVNC_EXE
    } else {
      set vncExe $VNC_EXE
    }
    if {$vncExe == "" || ![file isfile $vncExe] || ![file executable $vncExe]} {
      error "Can't find TightVNC application!"
    }
    set vncExe [file nativename $vncExe]

    # Disconnect TightVNC.
    puts [string repeat "-" 50]
    puts "Disconnect TightVNC"
    puts "$vncExe -controlapp -disconnectall"
    if {[catch {exec $vncExe -controlapp -disconnectall}]} {
      puts "Can't disconnect TightVNC!"
      puts $::errorInfo
      return 0
    }

    # Shutdown TightVNC.
    puts [string repeat "-" 50]
    puts "Shutdown TightVNC"
    puts "$vncExe -controlapp -shutdown"
    if {[catch {exec $vncExe -controlapp -shutdown}]} {
      puts "Can't shutdown TightVNC!"
      puts $::errorInfo
      return 0
    }

    return 1
  }

  # Prepare SSH tunneling via OpenSSH and return the command for execution.
  proc openssh_prepare {} {
    variable WORK_DIR
    variable WORK_SSH_EXE
    variable VNC_HOST
    variable VNC_PORT
    variable SSH_EXE
    variable SSH_PORT
    variable SSH_USER
    variable SSH_KEY
    variable SSH_KEY_PROVIDED
    variable USE_PROVIDED_SSH_KEY
    variable USE_PROVIDED_SSH_APP

    # Copy ssh key into work directory.
    set sshKey [file join $WORK_DIR "ssh.key"]
    if {$SSH_KEY_PROVIDED == 1 && $USE_PROVIDED_SSH_KEY == 1} {
      file copy -force [file join $::support::DATA_DIR "ssh.key"] $sshKey
    } elseif {$SSH_KEY != "" && [file isfile $SSH_KEY]}  {
      file copy -force $SSH_KEY $sshKey
    }

    # Set permissions on ssh.key on non Windows systems.
    if {![::support::utils::is_windows] && $sshKey!= "" && [file exists $sshKey]} {
      exec chmod 600 $sshKey
    }

    set command {}

    # Set ssh application.
    if {$USE_PROVIDED_SSH_APP == 1} {
      lappend command [file nativename $WORK_SSH_EXE]
    } elseif {$SSH_EXE != "" && [file isfile $SSH_EXE]} {
      lappend command [file nativename $SSH_EXE]
    } else {
      error "Can't find ssh!"
    }

    # Set tunneling options.
    lappend command "-L"
    lappend command [format "%s:127.0.0.1:%s" $VNC_PORT $VNC_PORT]
    lappend command "-f"
    lappend command "-o"
    lappend command "ExitOnForwardFailure=yes"

    # Set SSH port.
    lappend command "-p"
    lappend command $SSH_PORT

    # Set compression.
    lappend command "-C"

    # Disable X11 forwarding.
    lappend command "-x"

    # Set authentication via keyfile.
    if {$sshKey != "" && [file isfile $sshKey]} {
      lappend command "-i"
      lappend command [file nativename $sshKey]
      lappend command "-o"
      lappend command "PreferredAuthentications=publickey"
    } else {
      error "No ssh keyfile was specified!"
    }

    # Disable host checks
    lappend command "-o"
    lappend command "StrictHostKeyChecking=no"
    lappend command "-o"
    lappend command "GlobalKnownHostsFile=/dev/null"
    lappend command "-o"
    lappend command "UserKnownHostsFile=/dev/null"
    lappend command "-o"
    lappend command "CheckHostIP=no"

    # Set user and hostname.
    lappend command [format "%s@%s" $SSH_USER $VNC_HOST]

    # Set remote command.
    lappend command "sleep"
    lappend command "15"

    return $command
  }

  # Test for Windows systems, if a SSH tunnel is available.
  proc tunnel_is_loaded_windows {} {
    variable VNC_PORT

    set expectedLocalAddress "127.0.0.1:$VNC_PORT"

    # fetch available connections through netstat.exe
    if {[catch {exec "netstat.exe" "-a" "-n" "-p" "TCP"} result]} {
      puts "Can't test if Plink is loaded!"
      puts $::errorInfo
      return 0
    }

    # parse lines from the response by netstat.exe
    set lines [split [string trim $result] "\n"]
    foreach line $lines {
      set line [string trim $line]
      #puts "> NETSTAT: $line"

      # replace double spaces with single spaces
      set pos [string first "  " $line]
      while {$pos > -1} {
        set line [string replace $line $pos [expr {$pos + 1}] " "]
        set pos [string first "  " $line]
      }

      # split netstat result into separate values
      set values [split $line " "]
      if {[llength $values] < 2} {
        continue
      }

      # make sure, that the lines starts with TCP
      set protocol [string toupper [lindex $values 0]]
      if {$protocol != "TCP"} {
        continue
      }

      # the ssh tunnel is available, if its local address is present right after TCP
      set localAddress [string toupper [lindex $values 1]]
      if {$localAddress == $expectedLocalAddress} {
        return 1
      }
    }

    return 0
  }

  # Validate session settings.
  proc validate {} {
    set errors {}

    # VNC host address needs to be available.
    variable VNC_HOST
    if {$VNC_HOST == ""} {
      lappend errors [_ "An invalid address was specified."]
    }

    # VNC port number needs to be available.
    variable VNC_PORT
    if {![string is integer -strict $VNC_PORT] || $VNC_PORT < 1 || $VNC_PORT > 65535} {
      lappend errors [_ "An invalid port number was specified."]
    }

    # Custom VNC application needs to be available.
    variable USE_PROVIDED_VNC_APP
    if {$USE_PROVIDED_VNC_APP != 1} {
      variable VNC_EXE
      if {$VNC_EXE == "" || ![file isfile $VNC_EXE] || ![file executable $VNC_EXE]} {
        lappend errors [_ "An invalid VNC application was specified."]
      }
    }

    # Validate SSH settings, if SSH is enabled.
    variable SSH_ENABLED
    if {$SSH_ENABLED == 1} {

      # SSH application needs to be available.
      variable USE_PROVIDED_SSH_APP
      if {$USE_PROVIDED_SSH_APP == 1} {

        # Provided SSH application needs to be available.
        variable SSH_APP_PROVIDED
        if {$SSH_APP_PROVIDED != 1} {
          lappend errors [_ "There is no provided SSH application available."]
        }

      } else {

        # Custom SSH application needs to be available.
        variable SSH_EXE
        if {$SSH_EXE == "" || ![file isfile $SSH_EXE] || ![file executable $SSH_EXE]} {
          lappend errors [_ "An invalid SSH application was specified."]
        }

      }

      # SSH user needs to be available.
      variable SSH_USER
      if {$SSH_USER == ""} {
        lappend errors [_ "An invalid SSH user was specified."]
      }

      # SSH port number needs to be available.
      variable SSH_PORT
      if {![string is integer -strict $SSH_PORT] || $SSH_PORT < 1 || $SSH_PORT > 65535} {
        lappend errors [_ "An invalid SSH port number was specified."]
      }

      # SSH key needs to be available.
      variable USE_PROVIDED_SSH_KEY
      if {$USE_PROVIDED_SSH_KEY == 1} {

        # Provided SSH key needs to be available.
        variable SSH_KEY_PROVIDED
        if {$SSH_KEY_PROVIDED != 1} {
          lappend errors [_ "There is no provided SSH key available."]
        }

      } else {

        # Custom SSH key needs to be available.
        variable SSH_KEY
        if {$SSH_KEY == "" || ![file isfile $SSH_KEY]} {
          lappend errors [_ "An invalid SSH key was specified."]
        }

      }

    }

    return $errors
  }
}
