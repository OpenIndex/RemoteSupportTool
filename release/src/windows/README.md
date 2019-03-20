Files in this folder are used by the [`bundle-windows.sh`](../../bundle-windows.sh) script in order to create EXE launchers for Windows systems.

EXE launchers are basically self extracting [7-Zip](https://www.7-zip.org/) archives, that automatically start the application after extraction and automatically remove extracted files after the application is closed. Those EXE files are created with the `7zSD.sfx` file, which is part of 7-Zip's LZMA SDK. We're currently using version 19.00 (2019-02-21), that was downloaded from <https://www.7-zip.org/a/lzma1900.7z>. Further documentation about self extracting archives are available at <https://sevenzip.osdn.jp/chm/cmdline/switches/sfx.htm>.

If [Wine](https://www.winehq.org/) is installed on the build environment, the [`bundle-windows.sh`](../../bundle-windows.sh) script automatically does some modifications to the created EXE files by using the Freeware [Resource Hacker](http://angusj.com/resourcehacker/) application:

-   The application icon is replaced - either with a file called `Customer.ico` / `Staff.ico` located in this folder or with the [default icons](../icons).

-   Version information is replaced with the contents of the [`Customer.rc`](Customer.rc) / [`Staff.rc`](Staff.rc) file. You might customize these values but be aware to keep the general file structure intact.

-   The [manifest](https://en.wikipedia.org/wiki/Manifest_file#Application_and_assembly_manifest) defined in the [`manifest.rc`](manifest.rc) file is added. This ensures, that the application does not ask for admin permissions on startup. Of course the user still might run the application as administrator, but it is not strictly necessary.
