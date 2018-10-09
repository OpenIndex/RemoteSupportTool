This folder contains *OpenJDK* binaries for the supported target platforms.

Launch `init-*.sh` in order to download the *OpenJDK* from [AdoptOpenJDK](https://adoptopenjdk.net/) 
and [Azul Systems](https://www.azul.com/downloads/zulu/) for the different target platforms. After 
downloading these scripts extract the required modules into the `jmods` folder.

In the last step the `init-*.sh` scripts create a stripped down *OpenJDK* runtime environment for the 
different target platforms in the `runtime` folder. These are used by the bundle scripts 
(`bundle-linux.sh` / `bundle-mac.sh` / `bundle-windows.sh`) in order to create the application 
bundles.
