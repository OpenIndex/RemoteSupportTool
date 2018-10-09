module de.openindex.support.core {
    exports de.openindex.support.core;
    exports de.openindex.support.core.gui;
    exports de.openindex.support.core.io;
    exports de.openindex.support.core.monitor;
    exports org.imgscalr;

    requires transitive java.desktop;
    requires logback.classic;
    requires org.apache.commons.io;
    requires org.apache.commons.lang3;
    requires org.apache.commons.text;
    requires slf4j.api;
}