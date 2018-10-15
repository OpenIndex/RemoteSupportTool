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
package de.openindex.support.client;

import de.openindex.support.core.AbstractOptions;
import de.openindex.support.core.AppUtils;
import java.io.File;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.SystemUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@SuppressWarnings("WeakerAccess")
public class ClientOptions extends AbstractOptions {
    @SuppressWarnings("unused")
    private final static Logger LOGGER = LoggerFactory.getLogger(ClientOptions.class);

    public ClientOptions(File location) {
        super(location, ClientApplication.SETTINGS);
    }

    public Integer getLocalPort() {
        Integer defaultValue;
        try {
            defaultValue = Integer.valueOf(StringUtils.trimToNull(
                    settings.getString("default.localPort")));
        } catch (NumberFormatException ex) {
            defaultValue = 5900;
        }
        return getPropertyAsInteger("localPort", defaultValue);
    }

    public void setLocalPort(Integer value) {
        if (value == null)
            remove("localPort");
        else
            setProperty("localPort", value.toString());
    }

    public Boolean getSsh() {
        Boolean defaultValue = Boolean.valueOf(StringUtils.trimToNull(
                settings.getString("default.ssh")));
        return getPropertyAsBoolean("ssh", defaultValue);
    }

    public boolean isSsh() {
        return Boolean.TRUE.equals(getSsh());
    }

    public void setSsh(Boolean value) {
        if (value == null)
            remove("ssh");
        else
            setProperty("ssh", value.toString());
    }

    public String getSshHost() {
        String defaultValue = StringUtils.trimToEmpty(
                settings.getString("default.sshHost"));
        return StringUtils.defaultIfBlank(getProperty("sshHost"), defaultValue);
    }

    public void setSshHost(String value) {
        if (StringUtils.isBlank(value))
            remove("sshHost");
        else
            setProperty("sshHost", StringUtils.trimToEmpty(value));
    }

    public String getSshKey() {
        String defaultValue = StringUtils.trimToEmpty(
                settings.getString("default.sshKey"));
        return StringUtils.defaultIfBlank(
                getProperty("sshKey"),
                StringUtils.defaultIfBlank(defaultValue, AppUtils.getDefaultSshKey()));
    }

    public void setSshKey(String value) {
        if (StringUtils.isBlank(value))
            remove("sshKey");
        else
            setProperty("sshKey", StringUtils.trimToEmpty(value));
    }

    public Integer getSshPort() {
        Integer defaultValue;
        try {
            defaultValue = Integer.valueOf(StringUtils.trimToNull(
                    settings.getString("default.sshPort")));
        } catch (NumberFormatException ex) {
            defaultValue = 22;
        }
        return getPropertyAsInteger("sshPort", defaultValue);
    }

    public void setSshPort(Integer value) {
        if (value == null)
            remove("sshPort");
        else
            setProperty("sshPort", value.toString());
    }

    public Boolean getSshKeyAuth() {
        Boolean defaultValue = Boolean.valueOf(StringUtils.trimToNull(
                settings.getString("default.sshKeyAuth")));
        return getPropertyAsBoolean("sshKeyAuth", defaultValue);
    }

    public boolean isSshKeyAuth() {
        return Boolean.TRUE.equals(getSshKeyAuth());
    }

    public void setSshKeyAuth(Boolean value) {
        if (value == null)
            remove("sshKeyAuth");
        else
            setProperty("sshKeyAuth", value.toString());
    }

    public Integer getSshRemotePort() {
        Integer defaultValue;
        try {
            defaultValue = Integer.valueOf(StringUtils.trimToNull(
                    settings.getString("default.sshRemotePort")));
        } catch (NumberFormatException ex) {
            defaultValue = 55555;
        }
        return getPropertyAsInteger("sshRemotePort", defaultValue);
    }

    public void setSshRemotePort(Integer value) {
        if (value == null)
            remove("sshRemotePort");
        else
            setProperty("sshRemotePort", value.toString());
    }

    public String getSshUser() {
        String defaultValue = StringUtils.trimToEmpty(
                settings.getString("default.sshUser"));
        return StringUtils.defaultIfBlank(
                getProperty("sshUser"),
                StringUtils.defaultIfBlank(defaultValue, SystemUtils.USER_NAME));
    }

    public void setSshUser(String value) {
        if (StringUtils.isBlank(value))
            remove("sshUser");
        else
            setProperty("sshUser", StringUtils.trimToEmpty(value));
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
