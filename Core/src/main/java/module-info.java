/*
 * Copyright 2015-2018 OpenIndex.de.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * General components.
 *
 * @author Andreas Rudolph
 */
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
