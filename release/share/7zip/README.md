We're using [7-Zip](https://www.7-zip.org/) to create self extracting and automatically starting EXE files. 

-   The LZMA SDK of 7-Zip provides the required `7zSD.sfx` file. 
-   We're currently using version 18.05 (2018-04-30), that was downloaded from: 
    <https://www.7-zip.org/a/lzma1805.7z>
-   Documentation about SFX archives: 
    <https://sevenzip.osdn.jp/chm/cmdline/switches/sfx.htm>

The `7zSD.sfx` file was post processed with [Resource Hacker](http://angusj.com/resourcehacker/):

-   Icons and versions for the client application were replaced and stored into 
    [`src/windows/Client.sfx`](../../src/windows/Client.sfx).
-   Icons and versions for the server application were replaced and stored into 
    [`src/windows/Server.sfx`](../../src/windows/Server.sfx).
