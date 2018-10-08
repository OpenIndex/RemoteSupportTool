Changelog for Remote Support Tool
=================================

0.5.1 (08 Oct 2018)
-------------------

-   update to OpenSSH 7.8p1-1 for Windows Vista and newer
-   update to TightVNC 2.8.11
-   update to OSXvnc 5.2.1


0.5 (16 Jan 2017)
-----------------

-   migrated from Python to Tcl/Tk
-   replaced Paramiko with OpenSSH
-   implemented a new build process based on Tclkit
-   updated to OSXvnc 5.0.1, which should fix problems with Retina displays on
    Mac OS X
-   rebuild x11vnc, which should fix problems with a missing libxss library
    on amd64 based Linux systems
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
