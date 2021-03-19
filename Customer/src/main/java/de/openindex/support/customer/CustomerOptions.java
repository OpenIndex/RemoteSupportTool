/*
 * Copyright 2015-2021 OpenIndex.de.
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
package de.openindex.support.customer;

import de.openindex.support.core.AbstractOptions;
import java.io.File;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Options of the customer application.
 *
 * @author Andreas Rudolph
 */
@SuppressWarnings("WeakerAccess")
public class CustomerOptions extends AbstractOptions {
    @SuppressWarnings("unused")
    private final static Logger LOGGER = LoggerFactory.getLogger(CustomerOptions.class);

    public CustomerOptions(File location) {
        super(location, CustomerApplication.SETTINGS);
    }

    public String getHost() {
        String defaultValue = StringUtils.trimToEmpty(
                settings.getString("default.host"));
        return StringUtils.defaultIfBlank(getProperty("host"), defaultValue);
    }

    public void setHost(String value) {
        if (StringUtils.isBlank(value))
            remove("host");
        else
            setProperty("host", StringUtils.trimToEmpty(value));
    }

    public Integer getPort() {
        Integer defaultValue;
        try {
            defaultValue = Integer.valueOf(StringUtils.trimToNull(
                    settings.getString("default.port")));
        } catch (NumberFormatException ex) {
            defaultValue = 5900;
        }
        return getPropertyAsInteger("port", defaultValue);
    }

    public void setPort(Integer value) {
        if (value == null)
            remove("port");
        else
            setProperty("port", value.toString());
    }

    public String getScreenId() {
        return StringUtils.trimToNull(getProperty("screenId"));
    }

    public void setScreenId(String value) {
        if (StringUtils.isBlank(value))
            remove("screenId");
        else
            setProperty("screenId", StringUtils.trimToEmpty(value));
    }

    public Boolean getSsl() {
        Boolean defaultValue = Boolean.valueOf(StringUtils.trimToNull(
                settings.getString("default.ssl")));
        return getPropertyAsBoolean("ssl", defaultValue);
    }

    public boolean isSsl() {
        return Boolean.TRUE.equals(getSsl());
    }

    public void setSsl(Boolean value) {
        if (value == null)
            remove("ssl");
        else
            setProperty("ssl", value.toString());
    }
}
