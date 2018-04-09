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

package require inifile

namespace eval ::support::Config {
  variable ABOUT
  variable GUI
  variable GUI_FONT_BUTTON
  variable GUI_FONT_CHECKBUTTON
  variable GUI_FONT_ENTRY
  variable GUI_FONT_LABEL
  variable GUI_FONT_TITLE
  variable GUI_FONT_SUBTITLE
  variable GUI_FONT_STATUS
  variable SESSION

  proc configure {filename} {
    variable ABOUT
    variable GUI
    variable SESSION

    if {[array exists ABOUT] == 0} {
      array set ABOUT {}
    }
    if {[array exists GUI] == 0} {
      array set GUI {}
    }
    if {[array exists SESSION] == 0} {
      array set SESSION {}
    }

    set ini [::ini::open $filename -encoding "utf-8" "r"]

    #foreach section [::ini::sections $ini] {
    #  puts "SECTION: $section"
    #  foreach key [::ini::keys $ini $section] {
    #    set value [::ini::value $ini $section $key]
    #    puts "> $key = $value"
    #  }
    #}

    # load global configurations for Mac OS X
    configureSection $ini "about" ABOUT
    configureSection $ini "gui" GUI
    configureSection $ini "session" SESSION

    # load additional configurations for Mac OS X
    if {[::support::utils::is_darwin]} {
      configureSection $ini "about-darwin" ABOUT
      configureSection $ini "gui-darwin" GUI
      configureSection $ini "session-darwin" SESSION
    }

    # load additional configurations for Linux
    if {[::support::utils::is_linux]} {
      configureSection $ini "about-linux" ABOUT
      configureSection $ini "gui-linux" GUI
      configureSection $ini "session-linux" SESSION
    }

    # load additional configurations for Windows
    if {[::support::utils::is_windows]} {
      configureSection $ini "about-windows" ABOUT
      configureSection $ini "gui-windows" GUI
      configureSection $ini "session-windows" SESSION
    }

    ::ini::close $ini
  }

  proc configureSection {ini section target} {
    variable $target
    if {[::ini::exists $ini $section] != 1} {
      return
    }
    #puts $target
    foreach key [::ini::keys $ini $section] {
      set value [::ini::value $ini $section $key]
      #puts "CONFIG $section / $key / $value"
      set var [format "%s(%s)" $target $key]
      #puts $var
      set $var $value

      #set $target($key) $value
      #eval "set $target(\$key) $value"
      #eval "set $var $value"
    }
  }

  proc getAboutValue {key {defaultValue ""}} {
    variable ABOUT
    set value $defaultValue
    if {[info exists ABOUT($key)]} {
      set value [string trim $ABOUT($key)]
      if {$value == ""} {
        set value $defaultValue
      }
    }
    return $value
  }

  proc getGuiButtonFont {} {
    variable GUI_FONT_BUTTON
    if {![info exists GUI_FONT_BUTTON]} {
      set GUI_FONT_BUTTON [font create \
        -family [getGuiValue "button-font-family" "TkDefaultFont"] \
        -size [getGuiValue "button-font-size" "9"] \
        -weight [getGuiValue "button-font-weight" "normal"]]
    }
    return $GUI_FONT_BUTTON
  }

  proc getGuiButtonOptions {} {
    set options {}

    lappend options "-background"
    lappend options [getGuiValue "button-background" "white"]

    lappend options "-activebackground"
    lappend options [getGuiValue "button-background-active" "#eeeeee"]

    lappend options "-foreground"
    lappend options [getGuiValue "button-foreground" "#333333"]

    lappend options "-activeforeground"
    lappend options [getGuiValue "button-foreground-active" "black"]

    lappend options "-disabledforeground"
    lappend options [getGuiValue "button-foreground-disabled" "#cccccc"]

    lappend options "-font"
    lappend options [getGuiButtonFont]

    #lappend options "-cursor"
    #lappend options "hand1"

    return $options
  }

  proc getGuiCheckbuttonFont {} {
    variable GUI_FONT_CHECKBUTTON
    if {![info exists GUI_FONT_CHECKBUTTON]} {
      set GUI_FONT_CHECKBUTTON [font create \
        -family [getGuiValue "checkbutton-font-family" "TkDefaultFont"] \
        -size [getGuiValue "checkbutton-font-size" "9"] \
        -weight [getGuiValue "checkbutton-font-weight" "normal"]]
    }
    return $GUI_FONT_CHECKBUTTON
  }

  proc getGuiCheckbuttonOptions {} {
    set options {}

    lappend options "-background"
    lappend options [getGuiValue "checkbutton-background" "white"]

    lappend options "-activebackground"
    lappend options [getGuiValue "checkbutton-background-active" "#eeeeee"]

    lappend options "-foreground"
    lappend options [getGuiValue "checkbutton-foreground" "#333333"]

    lappend options "-activeforeground"
    lappend options [getGuiValue "checkbutton-foreground-active" "black"]

    lappend options "-font"
    lappend options [getGuiCheckbuttonFont]

    lappend options "-borderwidth"
    lappend options 0

    lappend options "-highlightthickness"
    lappend options 0

    #lappend options "-cursor"
    #lappend options "hand1"

    return $options
  }

  proc getGuiEntryFont {} {
    variable GUI_FONT_ENTRY
    if {![info exists GUI_FONT_ENTRY]} {
      set GUI_FONT_ENTRY [font create \
        -family [getGuiValue "entry-font-family" "TkTextFont"] \
        -size [getGuiValue "entry-font-size" "10"] \
        -weight [getGuiValue "entry-font-weight" "normal"]]
    }
    return $GUI_FONT_ENTRY
  }

  proc getGuiEntryOptions {} {
    set options {}

    lappend options "-background"
    lappend options [getGuiValue "entry-background" "white"]

    lappend options "-disabledbackground"
    lappend options [getGuiValue "entry-background-disabled" "#e0e0e0"]

    lappend options "-readonlybackground"
    lappend options [getGuiValue "entry-background-readonly" "#f0f0f0"]

    lappend options "-foreground"
    lappend options [getGuiValue "entry-foreground" "black"]

    lappend options "-disabledforeground"
    lappend options [getGuiValue "entry-foreground-disabled" "#999999"]

    lappend options "-font"
    lappend options [getGuiEntryFont]

    #lappend options "-cursor"
    #lappend options "hand1"

    return $options
  }

  proc getGuiLabelFont {} {
    variable GUI_FONT_LABEL
    if {![info exists GUI_FONT_LABEL]} {
      set GUI_FONT_LABEL [font create \
        -family [getGuiValue "label-font-family" "TkDefaultFont"] \
        -size [getGuiValue "label-font-size" "9"] \
        -weight [getGuiValue "label-font-weight" "normal"]]
    }
    return $GUI_FONT_LABEL
  }

  proc getGuiLabelOptions {} {
    set options {}

    lappend options "-background"
    lappend options [getGuiValue "label-background" "white"]

    lappend options "-foreground"
    lappend options [getGuiValue "label-foreground" "black"]

    lappend options "-disabledforeground"
    lappend options [getGuiValue "label-foreground-disabled" "#cccccc"]

    lappend options "-font"
    lappend options [getGuiLabelFont]

    #lappend options "-cursor"
    #lappend options "hand1"

    return $options
  }

  proc getGuiStatusFont {} {
    variable GUI_FONT_STATUS
    if {![info exists GUI_FONT_STATUS]} {
      set GUI_FONT_STATUS [font create \
        -family [getGuiValue "status-font-family" "TkDefaultFont"] \
        -size [getGuiValue "status-font-size" "9"] \
        -weight [getGuiValue "status-font-weight" "normal"]]
    }
    return $GUI_FONT_STATUS
  }

  proc getGuiStatusOptions {} {
    set options {}

    lappend options "-background"
    lappend options [getGuiValue "status-background" "#f0f0f0"]

    lappend options "-foreground"
    lappend options [getGuiValue "status-foreground" "black"]

    lappend options "-disabledforeground"
    lappend options [getGuiValue "status-foreground-disabled" "#c0c0c0"]

    lappend options "-font"
    lappend options [getGuiStatusFont]

    #lappend options "-cursor"
    #lappend options "hand1"

    return $options
  }

  proc getGuiSubtitleFont {} {
    variable GUI_FONT_SUBTITLE
    if {![info exists GUI_FONT_SUBTITLE]} {
      set GUI_FONT_SUBTITLE [font create \
        -family [getGuiValue "subtitle-font-family" "TkCaptionFont"] \
        -size [getGuiValue "subtitle-font-size" "10"] \
        -weight [getGuiValue "subtitle-font-weight" "bold"]]
    }
    return $GUI_FONT_SUBTITLE
  }

  proc getGuiSubtitleOptions {} {
    set options {}

    lappend options "-background"
    lappend options [getGuiValue "subtitle-background" "white"]

    lappend options "-foreground"
    lappend options [getGuiValue "subtitle-foreground" "black"]

    lappend options "-disabledforeground"
    lappend options [getGuiValue "subtitle-foreground-disabled" "#cccccc"]

    lappend options "-font"
    lappend options [getGuiSubtitleFont]

    #lappend options "-cursor"
    #lappend options "hand1"

    return $options
  }

  proc getGuiTitleFont {} {
    variable GUI_FONT_TITLE
    if {![info exists GUI_FONT_TITLE]} {
      set GUI_FONT_TITLE [font create \
        -family [getGuiValue "title-font-family" "TkCaptionFont"] \
        -size [getGuiValue "title-font-size" "12"] \
        -weight [getGuiValue "title-font-weight" "bold"]]
    }
    return $GUI_FONT_TITLE
  }

  proc getGuiTitleOptions {} {
    set options {}

    lappend options "-background"
    lappend options [getGuiValue "title-background" "white"]

    lappend options "-foreground"
    lappend options [getGuiValue "title-foreground" "black"]

    lappend options "-disabledforeground"
    lappend options [getGuiValue "title-foreground-disabled" "#cccccc"]

    lappend options "-font"
    lappend options [getGuiTitleFont]

    #lappend options "-cursor"
    #lappend options "hand1"

    return $options
  }

  proc getGuiValue {key {defaultValue ""}} {
    variable GUI
    set value $defaultValue
    if {[info exists GUI($key)]} {
      set value [string trim $GUI($key)]
      if {$value == ""} {
        set value $defaultValue
      }
    }
    return $value
  }

  proc getSessionValue {key {defaultValue ""}} {
    variable SESSION
    set value $defaultValue
    if {[info exists SESSION($key)]} {
      set value [string trim $SESSION($key)]
      if {$value == ""} {
        set value $defaultValue
      }
    }
    return $value
  }
}
