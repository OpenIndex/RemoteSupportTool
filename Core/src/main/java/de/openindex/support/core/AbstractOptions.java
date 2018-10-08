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
package de.openindex.support.core;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Properties;
import java.util.ResourceBundle;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class AbstractOptions extends Properties {
    @SuppressWarnings("unused")
    private final static Logger LOGGER = LoggerFactory.getLogger(AbstractOptions.class);
    protected final File location;
    protected final ResourceBundle settings;

    protected AbstractOptions(File location, ResourceBundle settings) {
        super();
        this.location = location;
        this.settings = settings;
    }

    protected Boolean getPropertyAsBoolean(String key, Boolean defaultValue) {
        String value = StringUtils.trimToNull(this.getProperty(key));
        return (value != null) ?
                Boolean.valueOf(value) :
                defaultValue;
    }

    protected Integer getPropertyAsInteger(String key, Integer defaultValue) {
        String value = StringUtils.trimToNull(this.getProperty(key));
        try {
            return (value != null) ?
                    Integer.valueOf(value) :
                    defaultValue;
        } catch (NumberFormatException ex) {
            LOGGER.warn("Can't read client option '" + key + "'!", ex);
            return defaultValue;
        }
    }

    public void read() throws IOException {
        if (!Boolean.parseBoolean(settings.getString("permanentOptions"))) return;
        if (!this.location.isFile()) return;
        try (InputStream input = new FileInputStream(this.location)) {
            this.load(input);
        }
    }

    public void write() throws IOException {
        if (!Boolean.parseBoolean(settings.getString("permanentOptions"))) return;
        try (OutputStream output = new FileOutputStream(this.location)) {
            this.store(output, null);
        }
    }
}
