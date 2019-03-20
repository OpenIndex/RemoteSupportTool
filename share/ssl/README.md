This folder contains the key pair and certificate, that was created with the provided `init.sh` script and may be bundled with this application.

In order to create custom builds of this application, you should create your own keystore and truststore by executing `init.sh` in this folder.

-   Copy the created `keystore.jks` and `keystore.jks.txt` into the [Client resources](../Client/src/main/resources/de/openindex/support/client/resources). 
-   Copy the created `truststore.jks` and `truststore.jks.txt` into the [Server resources](../Server/src/main/resources/de/openindex/support/server/resources).

Additionally you may disable the custom keystore / truststore in the application settings:

-   Set `customKeyStore=false` in [client settings](../Client/src/main/resources/de/openindex/support/client/resources/application.properties).
-   Set `customTrustStore=false` in [server settings](../Server/src/main/resources/de/openindex/support/server/resources/application.properties).

These settings enforce usage of the generated keystore / truststore. Otherwise users may replace these files through their application work directory.
