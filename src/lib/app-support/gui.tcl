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

package require scrolledframe


#
# Main application window.
#

namespace eval ::support::ApplicationWindow {
  variable ID
  variable IMG_SIDEBAR
  variable IMG_STATUS_CONNECTING
  variable IMG_STATUS_CONNECTED
  variable IMG_STATUS_DISCONNECTED
  variable IMG_STATUS_WARNING
  variable ADDRESS
  variable PORT
  variable SSH

  # Create the window.
  proc open {} {
    variable ID "."
    variable ADDRESS $::support::session::VNC_HOST
    variable PORT $::support::session::VNC_PORT
    variable SSH $::support::session::SSH_ENABLED

    # Load images.
    variable IMG_SIDEBAR [::support::utils::load_image_file sidebar.png]
    variable IMG_STATUS_CONNECTING [::support::utils::load_image_file icon_connect_creating.png]
    variable IMG_STATUS_CONNECTED [::support::utils::load_image_file icon_connect_established.png]
    variable IMG_STATUS_DISCONNECTED [::support::utils::load_image_file icon_connect_no.png]
    variable IMG_STATUS_WARNING [::support::utils::load_image_file icon_warning.png]

    # Load settings.
    set windowWidth [::support::Config::getGuiValue "application-window-width" 500]
    set windowHeight [::support::Config::getGuiValue "application-window-height" 300]
    set windowMinWidth [::support::Config::getGuiValue "application-window-min-width" 450]
    set windowMinHeight [::support::Config::getGuiValue "application-window-min-height" 250]
    set background [::support::Config::getGuiValue "background" "white"]
    set statusBackground [::support::Config::getGuiValue "status-background" "#f0f0f0"]
    set buttonOptions [::support::Config::getGuiButtonOptions]
    set checkbuttonOptions [::support::Config::getGuiCheckbuttonOptions]
    set entryOptions [::support::Config::getGuiEntryOptions]
    set labelOptions [::support::Config::getGuiLabelOptions]
    set titleOptions [::support::Config::getGuiTitleOptions]
    set statusOptions [::support::Config::getGuiStatusOptions]
    set companyName [::support::Config::getAboutValue "company-name"]

    # Init window.
    wm title $ID $::support::TITLE
    wm iconphoto $ID $::support::ICON
    wm minsize $ID $windowMinWidth $windowMinHeight

    # Center the window on the screen.
    ::support::utils::center_window $ID $windowWidth $windowHeight

    # Create main frame.
    frame .frm -background $background
    pack .frm -fill both -expand 1
    grid rowconfigure .frm 3 -weight 1
    grid columnconfigure .frm 1 -weight 1

    # Create sidebar.
    canvas .frm.sidebar -borderwidth 0 -highlightthickness 0 -background $background -width [image width $IMG_SIDEBAR]
    .frm.sidebar create image 0 0 -image $IMG_SIDEBAR -anchor nw
    grid .frm.sidebar -in .frm -padx 0 -pady 0 -row 0 -column 0 -rowspan 4 -sticky nw

    # Create title label.
    label .frm.title -text "$::support::TITLE $::support::VERSION" -anchor w {*}$titleOptions
    grid .frm.title -in .frm -row 0 -column 1 -padx {10 10} -pady {10 10} -sticky nwe

    # Create description label.
    if {$companyName != ""} {
      set description [_ "This application provides access to your desktop for the support staff of %s." $companyName]
    } else {
      set description [_ "This application provides access to your desktop for our support staff."]
    }
    label .frm.description -text $description -justify left -anchor w {*}$labelOptions
    grid .frm.description -in .frm -row 1 -column 1 -padx {10 10} -pady {0 10} -sticky nwe
    bind .frm.description <Configure> { %W configure -wraplength [expr { %w - 4 }] }

    # Create options form.
    frame .frm.options -background $background
    grid .frm.options -in .frm -row 2 -column 1 -padx 10 -pady 10 -sticky nwe
    grid columnconfigure .frm.options 1 -weight 1

    # Create address field.
    label .frm.options.addressLabel -text [_ "Address"] -anchor w {*}$labelOptions
    entry .frm.options.address -width 10 -textvariable ::support::ApplicationWindow::ADDRESS {*}$entryOptions
    bind .frm.options.address <Return> "::support::ApplicationWindow::onConnect"
    grid .frm.options.addressLabel -in .frm.options -row 0 -column 0 -padx {0 5} -pady {0 5} -sticky e
    grid .frm.options.address -in .frm.options -row 0 -column 1 -padx {0 5} -pady {0 5} -sticky ew

    # Create port field.
    label .frm.options.portLabel -text [_ "Port"] -anchor w {*}$labelOptions
    entry .frm.options.port -width 5 -textvariable ::support::ApplicationWindow::PORT {*}$entryOptions
    grid .frm.options.portLabel -in .frm.options -row 0 -column 2 -padx {0 5} -pady {0 5} -sticky e
    grid .frm.options.port -in .frm.options -row 0 -column 3 -padx {0 0} -pady {0 5} -sticky ew

    # Create ssh checkbox.
    checkbutton .frm.options.ssh -text [_ "Enable SSH encryption."] -variable ::support::ApplicationWindow::SSH {*}$checkbuttonOptions
    grid .frm.options.ssh -in .frm.options -row 1 -column 0 -columnspan 2 -sticky w

    # Create options button.
    button .frm.options.extended -text [_ "Extended…"] -anchor w -command ::support::ApplicationWindow::onSettingsDialog {*}$buttonOptions
    grid .frm.options.extended -in .frm.options -row 1 -column 2 -columnspan 2 -sticky e

    # Create button bar.
    frame .frm.buttons -background $background
    grid .frm.buttons -in .frm -row 4 -column 0 -columnspan 2 -padx 10 -pady 10 -sticky nwe
    grid columnconfigure .frm.buttons 2 -weight 1

    # Create quit button.
    button .frm.buttons.quit -text [_ "Quit"] -anchor e -command ::support::ApplicationWindow::onClose {*}$buttonOptions
    grid .frm.buttons.quit -in .frm.buttons -row 0 -column 0 -sticky e

    # Create about button.
    button .frm.buttons.about -text [_ "About"] -anchor e -command ::support::ApplicationWindow::onAboutDialog {*}$buttonOptions
    grid .frm.buttons.about -in .frm.buttons -row 0 -column 1 -padx {5 0} -sticky e

    # Create connect button.
    button .frm.buttons.connect -text [_ "Connect"] -anchor w -command ::support::ApplicationWindow::onConnect {*}$buttonOptions
    grid .frm.buttons.connect -in .frm.buttons -row 0 -column 3 -sticky w

    # Create disconnect button.
    button .frm.buttons.disconnect -text [_ "Disconnect"] -anchor w -command ::support::ApplicationWindow::onDisconnect {*}$buttonOptions
    grid .frm.buttons.disconnect -in .frm.buttons -row 0 -column 4 -padx {5 0} -sticky w

    # Create status bar.
    frame .frm.statusBar -padx 5 -pady 5 -background $statusBackground
    grid .frm.statusBar -in .frm -row 5 -column 0 -columnspan 2 -sticky nwe
    grid columnconfigure .frm.statusBar 0 -weight 1

    # Create status label.
    label .frm.statusBar.statusLabel -anchor w {*}$statusOptions
    grid .frm.statusBar.statusLabel -in .frm.statusBar -row 0 -column 0 -sticky w

    # Create status icon.
    label .frm.statusBar.statusIcon -anchor e -background $statusBackground
    grid .frm.statusBar.statusIcon -in .frm.statusBar -row 0 -column 1 -sticky e

    # Register events.
    wm protocol $ID WM_DELETE_WINDOW "::support::ApplicationWindow::onClose"
    bind $ID <Escape> "::support::ApplicationWindow::onClose"

    # Set focus on the address field.
    focus .frm.options.address

    # Create an empty main menu for Mac OS X.
    if {[::support::utils::is_darwin]} {
      $ID configure -menu [menu .menubar]
    }

    # Do final initializations.
    setStatusWelcome
  }

  proc onAboutDialog {} {
    ::support::AboutWindow::open
  }

  proc onClose {} {
    ::support::shutdown
  }

  proc onConnect {} {
    variable ID
    variable ADDRESS
    variable PORT
    variable SSH

    # Validate settings.
    set errors {}
    if {$ADDRESS == ""} {
      lappend errors [_ "An invalid address was specified."]
    }
    if {![string is integer -strict $PORT] || $PORT < 1 || $PORT > 65535} {
      lappend errors [_ "An invalid port number was specified."]
    }
    if {[llength $errors] > 0} {
      tk_messageBox -parent $ID -type ok -icon error -title [_ "Error"] -message [_ "Can't open connection!"] -detail [join $errors "\n"]
      return
    }

    # Put settings into the session.
    set ::support::session::VNC_HOST $ADDRESS
    set ::support::session::VNC_PORT $PORT
    set ::support::session::SSH_ENABLED $SSH

    # Start VNC session.
    ::support::connect
  }

  proc onDisconnect {} {
    .frm.buttons.disconnect configure -state disabled
    ::support::disconnect
  }

  proc onSettingsDialog {} {
    ::support::SettingsWindow::open
  }

  proc setFormDisabled {} {
    .frm.options.addressLabel configure -state disabled
    .frm.options.address configure -state disabled

    .frm.options.portLabel configure -state disabled
    .frm.options.port configure -state disabled

    .frm.options.ssh configure -state disabled
    .frm.options.extended configure -state disabled
  }

  proc setFormEnabled {} {
    .frm.options.addressLabel configure -state  normal
    .frm.options.address configure -state  normal

    .frm.options.portLabel configure -state  normal
    .frm.options.port configure -state  normal

    .frm.options.ssh configure -state  normal
    .frm.options.extended configure -state  normal
  }

  proc setStatusConnected {{txt ""}} {
    variable IMG_STATUS_CONNECTED
    if {$txt == ""} {
      set txt [_ "Connection is established."]
    }
    .frm.statusBar.statusLabel configure -text $txt
    .frm.statusBar.statusIcon configure -image $IMG_STATUS_CONNECTED

    .frm.buttons.connect configure -state disabled
    .frm.buttons.disconnect configure -state normal
    setFormDisabled
  }

  proc setStatusConnecting {{txt ""}} {
    variable IMG_STATUS_CONNECTING
    if {$txt == ""} {
      set txt [_ "Establishing a connection…"]
    }
    .frm.statusBar.statusLabel configure -text $txt
    .frm.statusBar.statusIcon configure -image $IMG_STATUS_CONNECTING

    .frm.buttons.connect configure -state disabled
    .frm.buttons.disconnect configure -state normal
    setFormDisabled
  }

  proc setStatusDisconnected {{txt ""}} {
    variable IMG_STATUS_DISCONNECTED
    if {$txt == ""} {
      set txt [_ "The connection was closed."]
    }
    .frm.statusBar.statusLabel configure -text $txt
    .frm.statusBar.statusIcon configure -image $IMG_STATUS_DISCONNECTED

    .frm.buttons.connect configure -state normal
    .frm.buttons.disconnect configure -state disabled
    setFormEnabled
  }

  proc setStatusError {{txt ""}} {
    variable IMG_STATUS_WARNING
    if {$txt == ""} {
      set txt [_ "An error occured."]
    }
    .frm.statusBar.statusLabel configure -text $txt
    .frm.statusBar.statusIcon configure -image $IMG_STATUS_WARNING

    .frm.buttons.connect configure -state normal
    .frm.buttons.disconnect configure -state disabled
    setFormEnabled
  }

  proc setStatusWelcome {{txt ""}} {
    variable IMG_STATUS_DISCONNECTED
    if {$txt == ""} {
      set txt [_ "Welcome to remote maintenance."]
    }
    .frm.statusBar.statusLabel configure -text $txt
    .frm.statusBar.statusIcon configure -image $IMG_STATUS_DISCONNECTED

    .frm.buttons.connect configure -state normal
    .frm.buttons.disconnect configure -state disabled
    setFormEnabled
  }
}


#
# About dialog window.
#

namespace eval ::support::AboutWindow {
  variable ID
  variable IMG_SIDEBAR ""

  # Create the window.
  proc open {} {
    variable ID ".about"

    # Load images.
    variable IMG_SIDEBAR
    if {$IMG_SIDEBAR == ""} {
      set IMG_SIDEBAR [::support::utils::load_image_file sidebar_about.png]
    }

    # Load settings.
    set windowWidth [::support::Config::getGuiValue "about-window-width" 550]
    set windowHeight [::support::Config::getGuiValue "about-window-height" 350]
    set windowMinWidth [::support::Config::getGuiValue "about-window-min-width" 450]
    set windowMinHeight [::support::Config::getGuiValue "about-window-min-height" 250]
    set background [::support::Config::getGuiValue "background" "white"]
    set companyName [::support::Config::getAboutValue "company-name"]
    set companyWebsite [::support::Config::getAboutValue "company-website"]
    set companyWebsiteTitle [::support::Config::getAboutValue "company-website-title" [_ "Company"]]
    set repository [::support::Config::getAboutValue "repository"]
    set authors [::support::Config::getAboutValue "authors"]
    set buttonOptions [::support::Config::getGuiButtonOptions]

    # Init window.
    toplevel $ID
    wm title $ID [_ "About this program"]
    wm iconphoto $ID $::support::ICON
    wm minsize $ID $windowMinWidth $windowMinHeight

    # Place the window below the application window.
    set x [expr {([winfo rootx $::support::ApplicationWindow::ID] + 20)}]
    set y [expr {([winfo rooty $::support::ApplicationWindow::ID] + 20)}]
    wm geometry $ID ${windowWidth}x${windowHeight}+${x}+${y}

    # Create main frame.
    frame .about.frm -background $background
    pack .about.frm -fill both -expand 1
    grid columnconfigure .about.frm 1 -weight 1
    grid rowconfigure .about.frm 0 -weight 1

    # Create sidebar.
    canvas .about.frm.sidebar -borderwidth 0 -highlightthickness 0 -background $background -width [image width $IMG_SIDEBAR]
    .about.frm.sidebar create image 0 0 -image $IMG_SIDEBAR -anchor nw
    grid .about.frm.sidebar -in .about.frm -padx 0 -pady 0 -row 0 -column 0 -rowspan 4 -sticky nw

    # Create text area.
    set txt ".about.frm.text"
    text $txt -height 20 -width 50 -background $background -padx 10 -pady 10 -highlightthickness 0 -relief flat -wrap word -yscrollcommand ".about.frm.textScroller set"
    grid $txt -in .about.frm -row 0 -column 1 -rowspan 2 -sticky nsew

    # Create text styles.
    $txt tag configure title -font [::support::Config::getGuiTitleFont]
    $txt tag configure subtitle -font [::support::Config::getGuiSubtitleFont]
    $txt tag configure default -font [::support::Config::getGuiLabelFont]
    $txt tag configure tiny -font "TkDefaultFont 4"

    # Insert text into text area.
    $txt insert end "$::support::TITLE $::support::VERSION" "title"
    $txt insert end "\n\n" "tiny"
    $txt insert end [_ "This application provides access to your desktop for our support staff."] "default"
    $txt insert end " " "default"
    $txt insert end [_ "Our support staff will tell you the required settings in order to build up a connection for remote maintenance."] "default"

    # Add notes about the company.
    if {$companyName != ""} {
      $txt insert end "\n\n" "tiny"
      $txt insert end [_ "This software is based on the free and open Remote Support Tool and was modified for %s." $companyName] "default"
      $txt insert end " " "default"
      $txt insert end [_ "Please contact %s for any questions or problems according to this software." $companyName] "default"
    }

    $txt insert end "\n\n\n" "tiny"
    $txt insert end [_ "Authors"] "subtitle"
    $txt insert end "\n\n" "tiny"
    $txt insert end "• Andreas Rudolph & Walter Wagner (OpenIndex.de)" "default"

    # Add further authors.
    if {$authors != ""} {
      foreach author [split $authors ";"] {
        $txt insert end "\n• [string trim $author]" "default"
      }
    }

    $txt insert end "\n\n\n" "tiny"
    $txt insert end [_ "Translators"] "subtitle"
    $txt insert end "\n\n" "tiny"
    $txt insert end [format "• %s: Andreas Rudolph & Walter Wagner" [_ "German"]] "default"

    $txt insert end "\n\n\n" "tiny"
    $txt insert end [_ "Internal components"] "subtitle"
    $txt insert end "\n\n" "tiny"
    $txt insert end [_ "The following third party components were integrated:"] "default"
    $txt insert end "\n\n" "tiny"
    $txt insert end [format "• Tcl/Tk %s (BSD)\n" [info patchlevel]] "default"
    $txt insert end [format "• %s %s (%s)\n" $::support::session::VNC_APP_NAME $::support::session::VNC_APP_VERSION $::support::session::VNC_APP_LICENSE] "default"
    if {$::support::session::SSH_APP_PROVIDED == 1} {
      $txt insert end [format "• %s %s (%s)\n" $::support::session::SSH_APP_NAME $::support::session::SSH_APP_VERSION $::support::session::SSH_APP_LICENSE] "default"
    }
    $txt insert end "• Crystal Clear Icons (LGPL)" "default"

    $txt insert end "\n\n\n" "tiny"
    $txt insert end [_ "Created with"] "subtitle"
    $txt insert end "\n\n" "tiny"
    $txt insert end [_ "The application was created with:"] "default"
    $txt insert end "\n\n" "tiny"
    $txt insert end "• TclKit\n" "default"
    if {[::support::utils::is_windows]} {
      $txt insert end "• Resource Hacker" "default"
    }

    $txt insert end "\n\n\n" "tiny"
    $txt insert end [_ "License"] "subtitle"
    $txt insert end "\n\n" "tiny"

    # Write LICENSE.txt into the text area.
    set fp [::open [file join $::support::DATA_DIR "LICENSE.txt"] r]
    set file_data [read $fp]
    close $fp
    set data [split $file_data "\n"]
    set prevLineEmpty 0
    foreach line $data {

      if {$prevLineEmpty == 1} {
        $txt insert end "\n\n" "tiny"
      }

      $txt insert end $line "default"
      $txt insert end " " "default"

      if {$line == ""} {
        set prevLineEmpty 1
      } else {
        set prevLineEmpty 0
      }
    }

    # Disable text area to avoid further modifications.
    $txt configure -state disabled

    # Create text scroller.
    scrollbar .about.frm.textScroller -command "$txt yview"
    grid .about.frm.textScroller -in .about.frm -row 0 -column 2 -rowspan 2 -sticky nsew

    # Create button bar.
    frame .about.frm.buttons -background $background
    grid .about.frm.buttons -in .about.frm -row 1 -column 0 -padx 10 -pady {0 10} -sticky swe
    grid columnconfigure .about.frm.buttons 0 -weight 1

    if {$companyWebsite != ""} {
      button .about.frm.buttons.company -text $companyWebsiteTitle -anchor center -command ::support::AboutWindow::onOpenCompany {*}$buttonOptions
      grid .about.frm.buttons.company -in .about.frm.buttons -row 0 -column 0 -sticky we
    }

    if {$repository != ""} {
      button .about.frm.buttons.repository -text [_ "Source code"] -anchor center -command ::support::AboutWindow::onOpenRepository {*}$buttonOptions
      grid .about.frm.buttons.repository -in .about.frm.buttons -row 1 -column 0 -pady {5 0} -sticky we
    }

    button .about.frm.buttons.close -text [_ "Close"] -anchor center -command ::support::AboutWindow::onClose {*}$buttonOptions
    grid .about.frm.buttons.close -in .about.frm.buttons -row 2 -column 0 -pady {5 0} -sticky we

    # Register events.
    wm protocol $ID WM_DELETE_WINDOW "::support::AboutWindow::onClose"
    bind $ID <Escape> "::support::AboutWindow::onClose"

    # Make modal window.
    ::support::utils::modal_init $ID
  }

  proc onClose {} {
    variable ID
    ::support::utils::modal_release $ID
  }

  proc onOpenCompany {} {
    set website [::support::Config::getAboutValue "company-website"]
    if {$website != ""} {
      ::support::utils::open_browser $website
    } else {
      puts "No company website was specified!"
    }
  }

  proc onOpenRepository {} {
    set website [::support::Config::getAboutValue "repository"]
    if {$website != ""} {
      ::support::utils::open_browser $website
    } else {
      puts "No repository website was specified!"
    }
  }
}



#
# Settings dialog window.
#

namespace eval ::support::SettingsWindow {
  variable ID
  variable ID_OPTIONS
  variable IMG_SIDEBAR ""
  variable VNC_EXE
  variable VNC_PARAMETERS
  variable SSH_EXE
  variable SSH_PORT
  variable SSH_USER
  variable SSH_KEY
  variable USE_PROVIDED_SSH_APP
  variable USE_PROVIDED_SSH_KEY
  variable USE_PROVIDED_VNC_APP

  # Create the window.
  proc open {} {
    variable ID ".settings"

    variable VNC_EXE $::support::session::VNC_EXE
    variable VNC_PARAMETERS $::support::session::VNC_PARAMETERS

    variable SSH_EXE $::support::session::SSH_EXE
    variable SSH_PORT $::support::session::SSH_PORT
    variable SSH_USER $::support::session::SSH_USER
    variable SSH_KEY $::support::session::SSH_KEY

    variable USE_PROVIDED_SSH_APP $::support::session::USE_PROVIDED_SSH_APP
    variable USE_PROVIDED_SSH_KEY $::support::session::USE_PROVIDED_SSH_KEY
    variable USE_PROVIDED_VNC_APP $::support::session::USE_PROVIDED_VNC_APP

    # Load images.
    variable IMG_SIDEBAR
    if {$IMG_SIDEBAR == ""} {
      set IMG_SIDEBAR [::support::utils::load_image_file sidebar_settings.png]
    }

    # Load settings.
    set windowWidth [::support::Config::getGuiValue "settings-window-width" 550]
    set windowHeight [::support::Config::getGuiValue "settings-window-height" 350]
    set windowMinWidth [::support::Config::getGuiValue "settings-window-min-width" 450]
    set windowMinHeight [::support::Config::getGuiValue "settings-window-min-height" 250]
    set background [::support::Config::getGuiValue "background" "white"]
    set buttonOptions [::support::Config::getGuiButtonOptions]
    set checkbuttonOptions [::support::Config::getGuiCheckbuttonOptions]
    set entryOptions [::support::Config::getGuiEntryOptions]
    set labelOptions [::support::Config::getGuiLabelOptions]
    set subtitleOptions [::support::Config::getGuiSubtitleOptions]

    # Init window.
    toplevel $ID
    wm title $ID [_ "Extended Settings"]
    wm iconphoto $ID $::support::ICON
    wm minsize $ID $windowMinWidth $windowMinHeight

    # Place the window below the application window.
    set x [expr {([winfo rootx $::support::ApplicationWindow::ID] + 20)}]
    set y [expr {([winfo rooty $::support::ApplicationWindow::ID] + 20)}]
    wm geometry $ID ${windowWidth}x${windowHeight}+${x}+${y}

    # Create main frame.
    frame .settings.frm -background $background
    pack .settings.frm -fill both -expand 1
    grid columnconfigure .settings.frm 1 -weight 1
    grid rowconfigure .settings.frm 1 -weight 1

    # Create sidebar.
    canvas .settings.frm.sidebar -borderwidth 0 -highlightthickness 0 -background $background -width [image width $IMG_SIDEBAR]
    .settings.frm.sidebar create image 0 0 -image $IMG_SIDEBAR -anchor nw
    grid .settings.frm.sidebar -in .settings.frm -padx 0 -pady 0 -row 0 -column 0 -rowspan 4 -sticky nw

    # Create options frame.
    #variable ID_OPTIONS ".settings.frm.options"
    #frame $ID_OPTIONS -background $background
    #grid $ID_OPTIONS -in .settings.frm -row 0 -column 1 -rowspan 2 -padx {10 10} -pady {10 5} -sticky nsew
    #grid columnconfigure $ID_OPTIONS 1 -weight 1

    # Create scrolling options frame.
    ::scrolledframe::scrolledframe .settings.frm.options -height 150 -width 100 -background $background -yscrollcommand {.settings.frm.vs set} -fill x
    scrollbar .settings.frm.vs -command {.settings.frm.options yview}
    #scrollbar .settings.frm.hs -command {.settings.frm.options xview} -orient horizontal
    grid .settings.frm.options -in .settings.frm -row 0 -column 1 -rowspan 2 -padx {10 10} -pady {10 5} -sticky nsew
    grid .settings.frm.vs -in .settings.frm -row 0 -column 2 -rowspan 2 -sticky ns
    variable ID_OPTIONS .settings.frm.options.scrolled
    $ID_OPTIONS configure -background $background
    grid columnconfigure $ID_OPTIONS 1 -weight 1

    # Create VNC title.
    label $ID_OPTIONS.vncTitle -text [format "%s (%s)" [_ "Settings for VNC"] $::support::session::VNC_APP_NAME] -anchor w {*}$subtitleOptions
    grid $ID_OPTIONS.vncTitle -in $ID_OPTIONS -row 0 -column 0 -columnspan 3 -padx {0 0} -pady {0 5} -sticky nwe

    # Create VNC application field.
    label $ID_OPTIONS.vncAppLabel -text [_ "Application"] -anchor w {*}$labelOptions
    entry $ID_OPTIONS.vncApp -width 10 -state readonly -textvariable ::support::SettingsWindow::VNC_EXE {*}$entryOptions
    button $ID_OPTIONS.vncAppButton -text [_ "Select"] -padx 0 -pady 0 -anchor center -command ::support::SettingsWindow::onSelectVncPath {*}$buttonOptions
    grid $ID_OPTIONS.vncAppLabel -in $ID_OPTIONS -row 1 -column 0 -padx {0 5} -pady {0 3} -sticky e
    grid $ID_OPTIONS.vncApp -in $ID_OPTIONS -row 1 -column 1 -padx {0 5} -pady {0 3} -sticky ew
    grid $ID_OPTIONS.vncAppButton -in $ID_OPTIONS -row 1 -column 2 -padx {0 0} -pady {0 3} -sticky ew

    # Create VNC parameters field for non Windows systems.
    if {![::support::utils::is_windows]} {
      label $ID_OPTIONS.vncParamsLabel -text [_ "Parameters"] -anchor w {*}$labelOptions
      entry $ID_OPTIONS.vncParams -width 10 -textvariable ::support::SettingsWindow::VNC_PARAMETERS {*}$entryOptions
      grid $ID_OPTIONS.vncParamsLabel -in $ID_OPTIONS -row 2 -column 0 -padx {0 5} -pady {0 3} -sticky e
      grid $ID_OPTIONS.vncParams -in $ID_OPTIONS -row 2 -column 1 -columnspan 2 -padx {0 3} -pady {0 3} -sticky ew
    }

    # Create internal VNC application field.
    checkbutton $ID_OPTIONS.vncAppInternal -text [_ "Use provided VNC application."] -variable ::support::SettingsWindow::USE_PROVIDED_VNC_APP -command ::support::SettingsWindow::onUpdateVncPath {*}$checkbuttonOptions
    grid $ID_OPTIONS.vncAppInternal -in $ID_OPTIONS -row 3 -column 1 -columnspan 2 -padx {0 0} -pady {0 3} -sticky w

    # Create SSH title.
    label $ID_OPTIONS.sshTitle -text [format "%s (%s)" [_ "Settings for SSH"] $::support::session::SSH_APP_NAME] -anchor w {*}$subtitleOptions
    grid $ID_OPTIONS.sshTitle -in $ID_OPTIONS -row 4 -column 0 -columnspan 3 -padx {0 0} -pady {7 5} -sticky nwe

    # Create SSH application field.
    label $ID_OPTIONS.sshAppLabel -text [_ "Application"] -anchor w {*}$labelOptions
    entry $ID_OPTIONS.sshApp -width 10 -state readonly -textvariable ::support::SettingsWindow::SSH_EXE {*}$entryOptions
    button $ID_OPTIONS.sshAppButton -text [_ "Select"] -padx 3 -pady 0 -anchor center -command ::support::SettingsWindow::onSelectSshPath {*}$buttonOptions
    grid $ID_OPTIONS.sshAppLabel -in $ID_OPTIONS -row 5 -column 0 -padx {0 5} -pady {0 3} -sticky e
    grid $ID_OPTIONS.sshApp -in $ID_OPTIONS -row 5 -column 1 -padx {0 5} -pady {0 3} -sticky ew
    grid $ID_OPTIONS.sshAppButton -in $ID_OPTIONS -row 5 -column 2 -padx {0 0} -pady {0 3} -sticky ew

    # Create SSH key field.
    label $ID_OPTIONS.sshKeyLabel -text [_ "Key"] -anchor w {*}$labelOptions
    entry $ID_OPTIONS.sshKey -width 10 -state readonly -textvariable ::support::SettingsWindow::SSH_KEY {*}$entryOptions
    button $ID_OPTIONS.sshKeyButton -text [_ "Select"] -padx 3 -pady 0 -anchor center -command ::support::SettingsWindow::onSelectSshKey {*}$buttonOptions
    grid $ID_OPTIONS.sshKeyLabel -in $ID_OPTIONS -row 6 -column 0 -padx {0 5} -pady {0 3} -sticky e
    grid $ID_OPTIONS.sshKey -in $ID_OPTIONS -row 6 -column 1 -padx {0 5} -pady {0 3} -sticky ew
    grid $ID_OPTIONS.sshKeyButton -in $ID_OPTIONS -row 6 -column 2 -padx {0 0} -pady {0 3} -sticky ew

    # Create SSH user field.
    label $ID_OPTIONS.sshUserLabel -text [_ "User"] -anchor w {*}$labelOptions
    entry $ID_OPTIONS.sshUser -width 10 -textvariable ::support::SettingsWindow::SSH_USER {*}$entryOptions
    grid $ID_OPTIONS.sshUserLabel -in $ID_OPTIONS -row 7 -column 0 -padx {10 5} -pady {0 3} -sticky e
    grid $ID_OPTIONS.sshUser -in $ID_OPTIONS -row 7 -column 1 -columnspan 2 -padx {0 0} -pady {0 3} -sticky ew

    # Create SSH port field.
    label $ID_OPTIONS.sshPortLabel -text [_ "SSH Port"] -anchor w {*}$labelOptions
    entry $ID_OPTIONS.sshPort -width 10 -textvariable ::support::SettingsWindow::SSH_PORT {*}$entryOptions
    grid $ID_OPTIONS.sshPortLabel -in $ID_OPTIONS -row 8 -column 0 -padx {10 5} -pady {0 3} -sticky e
    grid $ID_OPTIONS.sshPort -in $ID_OPTIONS -row 8 -column 1 -columnspan 2 -padx {0 0} -pady {0 3} -sticky ew

    # Create internal SSH application field.
    if {$::support::session::SSH_APP_PROVIDED == 1} {
      checkbutton $ID_OPTIONS.sshAppInternal -text [_ "Use provided SSH application."] -variable ::support::SettingsWindow::USE_PROVIDED_SSH_APP -command ::support::SettingsWindow::onUpdateSshPath {*}$checkbuttonOptions
      grid $ID_OPTIONS.sshAppInternal -in $ID_OPTIONS -row 9 -column 1 -columnspan 2 -padx {0 0} -pady {0 3} -sticky w
    }

    # Create internal SSH key field.
    if {$::support::session::SSH_KEY_PROVIDED == 1} {
      checkbutton $ID_OPTIONS.sshKeyInternal -text [_ "Use provided key."] -variable ::support::SettingsWindow::USE_PROVIDED_SSH_KEY -command ::support::SettingsWindow::onUpdateSshKey {*}$checkbuttonOptions
      grid $ID_OPTIONS.sshKeyInternal -in $ID_OPTIONS -row 10 -column 1 -columnspan 2 -padx {0 0} -pady {0 3} -sticky w
    }

    # Create button bar.
    frame .settings.frm.buttons -background $background
    grid .settings.frm.buttons -in .settings.frm -row 1 -column 0 -padx {10 10} -pady {0 10} -sticky swe
    grid columnconfigure .settings.frm.buttons 0 -weight 1

    # Create submit button.
    button .settings.frm.buttons.submit -text [_ "Submit"] -anchor center -command ::support::SettingsWindow::onSubmit {*}$buttonOptions
    grid .settings.frm.buttons.submit -in .settings.frm.buttons -row 0 -column 0 -sticky we

    # Create cancel button.
    button .settings.frm.buttons.cancel -text [_ "Cancel"] -anchor center -command ::support::SettingsWindow::onClose {*}$buttonOptions
    grid .settings.frm.buttons.cancel -in .settings.frm.buttons -row 1 -column 0 -pady {5 0} -sticky we

    # Register events.
    wm protocol .settings WM_DELETE_WINDOW "::support::SettingsWindow::onClose"
    bind .settings <Escape> "::support::SettingsWindow::onClose"

    # Make modal window.
    ::support::utils::modal_init $ID

    # Do final initializations.
    onUpdateVncPath
    onUpdateSshPath
    onUpdateSshKey
  }

  proc onClose {} {
    variable ID
    ::support::utils::modal_release $ID
  }

  proc onSelectSshKey {} {
    variable ID
    variable SSH_KEY

    set name ""
    set dir $::env(HOME)
    if {$SSH_KEY != ""} {
      set name [file tail $SSH_KEY]
      set dir [file dirname $SSH_KEY]
    }

    set path [tk_getOpenFile -parent $ID -initialdir $dir -initialfile $name -title [_ "Select your SSH key."]]
    if {$path != ""} {
      if {![file isfile $path]} {
        tk_messageBox -parent $ID -type ok -icon error -title [_ "Error"] -message [_ "Can't select SSH key!"] -detail [_ "The selected file is invalid."]
      } else {
        set SSH_KEY $path
      }
    }
  }

  proc onSelectSshPath {} {
    variable ID
    variable SSH_EXE

    set name ""
    set dir $::env(HOME)
    if {$SSH_EXE != ""} {
      set name [file tail $SSH_EXE]
      set dir [file dirname $SSH_EXE]
    }

    set path [tk_getOpenFile -parent $ID -initialdir $dir -initialfile $name -title [_ "Select your SSH application."]]
    if {$path != ""} {
      if {![file isfile $path] || ![file executable $path]} {
        tk_messageBox -parent $ID -type ok -icon error -title [_ "Error"] -message [_ "Can't select SSH application!"] -detail [_ "The selected file is not an executable program."]
      } else {
        set SSH_EXE $path
      }
    }
  }

  proc onSelectVncPath {} {
    variable ID
    variable VNC_EXE

    set name ""
    set dir $::env(HOME)
    if {$VNC_EXE != ""} {
      set name [file tail $VNC_EXE]
      set dir [file dirname $VNC_EXE]
    }

    set path [tk_getOpenFile -parent $ID -initialdir $dir -initialfile $name -title [_ "Select your VNC application."]]
    if {$path != ""} {
      if {![file isfile $path] || ![file executable $path]} {
        tk_messageBox -parent $ID -type ok -icon error -title [_ "Error"] -message [_ "Can't select VNC application!"] -detail [_ "The selected file is not an executable program."]
      } else {
        set VNC_EXE $path
      }
    }
  }

  proc onSubmit {} {
    variable ID
    variable VNC_EXE
    variable VNC_PARAMETERS
    variable SSH_EXE
    variable SSH_PORT
    variable SSH_USER
    variable SSH_KEY
    variable USE_PROVIDED_SSH_APP
    variable USE_PROVIDED_SSH_KEY
    variable USE_PROVIDED_VNC_APP

    # Validate settings.
    set errors {}
    if {$USE_PROVIDED_VNC_APP != 1} {
      if {$VNC_EXE == "" || ![file executable $VNC_EXE]} {
        lappend errors [_ "An invalid VNC application was specified."]
      }
    }
    if {$USE_PROVIDED_SSH_APP != 1} {
      if {$SSH_EXE == "" || ![file executable $SSH_EXE]} {
        lappend errors [_ "An invalid SSH application was specified."]
      }
    }
    if {![string is integer -strict $SSH_PORT] || $SSH_PORT < 1 || $SSH_PORT > 65535} {
      lappend errors [_ "An invalid port number was specified."]
    }
    if {$USE_PROVIDED_SSH_KEY != 1} {
      if {$SSH_KEY == "" || ![file isfile $SSH_KEY]} {
        lappend errors [_ "An invalid SSH keyfile was specified."]
      }
    }

    if {[llength $errors] > 0} {
      tk_messageBox -parent $ID -type ok -icon error -title [_ "Error"] -message [_ "Can't submit settings!"] -detail [join $errors "\n"]
      return
    }

    # Put settings into the session.
    set ::support::session::VNC_EXE $VNC_EXE
    set ::support::session::VNC_PARAMETERS $VNC_PARAMETERS
    set ::support::session::SSH_EXE $SSH_EXE
    set ::support::session::SSH_PORT $SSH_PORT
    set ::support::session::SSH_USER $SSH_USER
    set ::support::session::SSH_KEY $SSH_KEY
    set ::support::session::USE_PROVIDED_SSH_APP $USE_PROVIDED_SSH_APP
    set ::support::session::USE_PROVIDED_SSH_KEY $USE_PROVIDED_SSH_KEY
    set ::support::session::USE_PROVIDED_VNC_APP $USE_PROVIDED_VNC_APP

    # Close settings dialog.
    onClose
  }

  proc onUpdateSshKey {} {
    variable ID_OPTIONS
    variable USE_PROVIDED_SSH_KEY

    if {$USE_PROVIDED_SSH_KEY == 1} {
      $ID_OPTIONS.sshKey configure -state disabled
      $ID_OPTIONS.sshKeyButton configure -state disabled
    } else {
      $ID_OPTIONS.sshKey configure -state readonly
      $ID_OPTIONS.sshKeyButton configure -state normal
    }

    if {$::support::session::SSH_KEY_PROVIDED == 1} {
      $ID_OPTIONS.sshKeyInternal configure -state normal
    }
  }

  proc onUpdateSshPath {} {
    variable ID_OPTIONS
    variable USE_PROVIDED_SSH_APP

    if {$USE_PROVIDED_SSH_APP == 1} {
      $ID_OPTIONS.sshApp configure -state disabled
      $ID_OPTIONS.sshAppButton configure -state disabled
    } else {
      $ID_OPTIONS.sshApp configure -state readonly
      $ID_OPTIONS.sshAppButton configure -state normal
    }
  }

  proc onUpdateVncPath {} {
    variable ID_OPTIONS
    variable USE_PROVIDED_VNC_APP

    if {$USE_PROVIDED_VNC_APP == 1} {
      $ID_OPTIONS.vncApp configure -state disabled
      $ID_OPTIONS.vncAppButton configure -state disabled
    } else {
      $ID_OPTIONS.vncApp configure -state readonly
      $ID_OPTIONS.vncAppButton configure -state normal
    }
  }
}
