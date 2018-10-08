This folder contains *OpenJDK* binaries for the supported target platforms.

Launch `init.sh` in order to download the *OpenJDK* from [AdoptOpenJDK](https://adoptopenjdk.net/) 
and [Azul Systems](https://www.azul.com/downloads/zulu/). After the download the script extracts
the required modules into the `jmods` folder.

Afterwards the `init.sh` script creates a stripped down *OpenJDK* runtime environment for the 
different target platforms in the `runtime` folder. These are used by the bundle scripts 
(`bundle-linux.sh` / `bundle-mac.sh` / `bundle-windows.sh`), that create the runtime environments 
for the application.
