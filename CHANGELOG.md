Changelog for Remote Support Tool
=================================

1.1.0 (not released yet)
------------------------

-   upgrade to Java 11
-   update [Commons Text](https://commons.apache.org/text/) library to version 1.6


1.0.0 (20 Oct 2018)
-------------------

-   migrated from Tcl/Tk to Java
-   implement the whole support session in Java, no need for external applications (x11vnc, OSXvnc, TightVNC, OpenSSH)
-   provide a graphical interface for both sides of a support session (customer & support staff)
-   provided binaries are bundles with a stripped down version of the OpenJDK runtime environment (version 10)
-   provide a signed application bundle for macOS
-   switched from MIT to Apache License 2.0


0.5 (16 Jan 2017)
-----------------

-   migrated from Python to Tcl/Tk
-   replaced Paramiko with OpenSSH
-   implemented a new build process based on Tclkit
-   updated to OSXvnc 5.0.1, which should fix problems with Retina displays on Mac OS X
-   rebuild x11vnc, which should fix problems with a missing libxss library on amd64 based Linux systems
-   added some more options for GUI configuration via config.ini


0.4.1 (10 Nov 2015)
-------------------

-   translated into Italian
    (thanks to [Sjd-Risca](https://github.com/Sjd-Risca))
-   compatibility fixes for PyInstaller 3
    (thanks to [Sjd-Risca](https://github.com/Sjd-Risca))
-   rebuilt with PyInstaller 3 on all supported platforms

0.4 (17 Jun 2015)
-----------------

-   first public relase
