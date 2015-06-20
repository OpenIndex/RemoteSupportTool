Remote Support Tool 0.5
=======================

*Remote Support Tool* is an easy single click solution for remote maintenance via 
[VNC](https://en.wikipedia.org/wiki/Virtual_Network_Computing) inspired by 
[UltraVNC Single Click](http://www.uvnc.com/products/uvnc-sc.html) and [Gitso](https://code.google.com/p/gitso/).


About this program
------------------

[Remote administration](https://en.wikipedia.org/wiki/Remote_administration) is common practice in software support for 
end users. There are a lot of different solutions on the market, that can solve this task. But most of them are lacking 
at least in one of these requirements:

-   The end user should be able to start the remote administration session with as less clicks as possible.

    -   No complex installation procedure should be required. The end user just has to download a single file and start 
        it.
    
    -   The end user often sits behind a router / NAT and should not bother with port forwarding. On one hand this is 
        quite complicated process for an end user and on the other hand it is a possible security risk to open local 
        ports to the internet.
    
-   The remote maintenance session should be completely private and secure.

    -   All transferred data has to be encrypted - especially when it is sent over the internet 

    -   Most commercial solutions are initiating (or even routing) the traffic through their own servers. This can 
        become a privacy problem - especially if the servers are located in countries with loose data privacy policies.

-   All major operating systems for desktop PC's should be supported.

-   Support for different languages - because not all end users speak English.

Because we did not find a solution that fits all of these requirements, we've decided to build our own little 
application based on [VNC](https://en.wikipedia.org/wiki/Virtual_Network_Computing). In general this application behaves 
similar to the [UltraVNC Single Click](http://www.uvnc.com/products/uvnc-sc.html) solution - but it also provides 
encryption and supports Linux and Mac OS X.

In addition we wanted to make this program customizable for other companies. 

-   A company may provide custom configuration files together with the executable binary.

-   A company may compile its configurations directly into the executable binary. This makes it possible to provide a 
    single executable file for the end users, that contains all required configurations by default.
    
In both cases the end user just has to click the *Connect* button and does not have to change any settings.


### Application dialog

![application dialog](misc/screenshots/application-dialog.png)

In the best case the end user will just have to click the *Connect* button. But maybe the support staff will have to 
tell his IP address to the end user. Therefore the user will find the most basic settings directly in the application 
window.


### Extended settings dialog

![extended settings dialog](misc/screenshots/settings-dialog.png)

All relevant settings for a VNC reverse connection (tunneled through SSH) can be modified in the extended settings 
dialog if necessary.


Documentation
-------------

You can find documentations about *Remote Support Tool* in the 
[project wiki](https://github.com/OpenIndex/RemoteSupportTool/wiki).


Bundled VNC servers
-------------------

The following VNC servers are bundled into the application (depending on the operating system):

-   for Linux: [x11vnc](http://www.karlrunge.com/x11vnc/) (GPLv2)
    -   using binaries from [sourceforge.net](http://sourceforge.net/projects/x11vnc/)
    
-   for Mac OS X 10.7+: [Vine server / OSXvnc](http://sourceforge.net/projects/osxvnc/) (GPLv2) 
    -   using binaries from [testplant.com](http://www.testplant.com/dlds/vine/)

-   for Windows: [TightVNC server](http://www.tightvnc.com/) (GPLv2)
    -   using binaries from [tightvnc.com](http://www.tightvnc.com/download.php)


Third party components
----------------------

The following third party components are bundled into the application:

-   [Python](https://www.python.org/) (PSFL)
-   [Tcl/Tk](http://www.tcl.tk/) (BSD)
-   [PyCrypto](http://www.pycrypto.org/) (Public Domain)
-   [Paramiko](http://www.paramiko.org/) (LGPL)
-   [Pillow](http://python-pillow.github.io/) (PIL)
-   [psutil](https://github.com/giampaolo/psutil) (BSD)
-   [NumPy](http://www.numpy.org/) (BSD)
    (only used on Mac OS X)
-   [gettext-py-windows](https://launchpad.net/gettext-py-windows) (MIT)
    (only used on Windows)
-   [Python for Windows Extensions](http://sourceforge.net/projects/pywin32/) (PSFL)
    (only used on Windows)
-   [Crystal Clear Icons](http://www.everaldo.com/) (LGPL)


Created with
------------

-   This repository can be opened directly as a project into 
    [PyCharm Community Edition](https://www.jetbrains.com/pycharm/). But you can use any other Python IDE of course.

-   [PyInstaller](http://www.pyinstaller.org/) is used to create executable binaries for Windows, Mac OS X and Linux.


Supported operating systems
---------------------------

-   Windows (XP or newer)
-   Mac OS X (10.7 or newer)
-   Linux


Translations
------------

*Remote Support Tool* is developed in **English** and is already translated into **German**. The 
[translation documentation](https://github.com/OpenIndex/RemoteSupportTool/wiki/Translation) contains informations 
about how to translate the application for yourself.


License
-------

This application is licensed under the terms of the [MIT License](http://opensource.org/licenses/MIT). Take a look at 
[`LICENSE.txt`](LICENSE.txt) for the license text.


Further informations
--------------------

-   [*Remote Support Tool* at GitHub](https://github.com/OpenIndex/RemoteSupportTool)
-   [Releases of *Remote Support Tool*](https://github.com/OpenIndex/RemoteSupportTool/releases)
-   [Changelog of *Remote Support Tool*](https://github.com/OpenIndex/RemoteSupportTool/blob/develop/CHANGELOG.md)
-   [Documentation of *Remote Support Tool*](https://github.com/OpenIndex/RemoteSupportTool/wiki)
