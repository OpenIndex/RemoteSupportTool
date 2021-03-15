Changelog for Remote Support Tool
=================================

1.1.2 (15 Mar 2021)
-------------------

-   [enhancement #33](https://github.com/OpenIndex/RemoteSupportTool/issues/33): Enable encryption via TLS 1.3
-   [enhancement #46](https://github.com/OpenIndex/RemoteSupportTool/issues/46): Hide connection settings in Customer Tool via configuration
-   update bundled [Java Runtime Environment](https://openjdk.java.net/) to version 11.0.10+9
-   update [Commons Lang](https://commons.apache.org/lang/) library to version 3.12.0
-   update [Commons IO](https://commons.apache.org/io) library to version 2.8.0
-   update [Commons Text](https://commons.apache.org/text/) library to version 1.9
-   update [SLF4J](https://www.slf4j.org/) library to version 1.7.30
-   update [Java Native Access](https://github.com/java-native-access/jna) library to version 5.7.0
-   minor changes, see [Milestone v1.1.2](https://github.com/OpenIndex/RemoteSupportTool/milestone/7)


1.1.1 (22 Mar 2019)
-------------------

-   fixed [issue #28](https://github.com/OpenIndex/RemoteSupportTool/issues/28): Uppercase characters are printed in lowercase for Linux customers
-   fixed [issue #29](https://github.com/OpenIndex/RemoteSupportTool/issues/29): Wrong mouse position on multi monitor setups
-   fixed [issue #30](https://github.com/OpenIndex/RemoteSupportTool/issues/30): Wrong screen information shown in customer tool
-   fixed [issue #31](https://github.com/OpenIndex/RemoteSupportTool/issues/31): Staff tool on macOS doesn't send characters typed with option key


1.1.0 (20 Mar 2019)
-------------------

-   upgrade to Java 11
-   update [Commons Text](https://commons.apache.org/text/) library to version 1.6
-   update [JSch](http://www.jcraft.com/jsch/) library to version 0.1.55
-   update [Simple Logging Facade for Java](https://www.slf4j.org/) library to version 1.7.26
-   provide sh application launcher for macOS ([issue #20](https://github.com/OpenIndex/RemoteSupportTool/issues/20))
-   tab key is not sent to the customer application ([issue #21](https://github.com/OpenIndex/RemoteSupportTool/issues/21))
-   enable / disable transfer of keyboard & mouse inputs ([issue #22](https://github.com/OpenIndex/RemoteSupportTool/issues/22))
-   rework transfer of keyboard inputs ([issue #23](https://github.com/OpenIndex/RemoteSupportTool/issues/23))
-   prefer Nimbus look & feel on Linux ([issue #25](https://github.com/OpenIndex/RemoteSupportTool/issues/25))
-   set awtAppClassName for Gnome / Ubuntu Unity ([issue #26](https://github.com/OpenIndex/RemoteSupportTool/issues/26))


1.0.1 (13 Mar 2019)
-------------------

-   fixed [issue #18](https://github.com/OpenIndex/RemoteSupportTool/issues/18): Mouse is shifted on Windows clients with high resolution screen


1.0.0 (20 Oct 2018)
-------------------

-   migrated from Tcl/Tk to Java
-   implement the whole support session in Java, no need for external applications (x11vnc, OSXvnc, TightVNC, OpenSSH)
-   provide a graphical interface for both sides of a support session (customer & support staff)
-   provided binaries are bundled with a stripped down version of the OpenJDK runtime environment (version 10)
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

-   translated into Italian (thanks to [Sjd-Risca](https://github.com/Sjd-Risca))
-   compatibility fixes for PyInstaller 3 (thanks to [Sjd-Risca](https://github.com/Sjd-Risca))
-   rebuilt with PyInstaller 3 on all supported platforms

0.4 (17 Jun 2015)
-----------------

-   first public release
