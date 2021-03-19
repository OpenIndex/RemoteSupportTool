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
package de.openindex.support.core.monitor;

import java.io.FilterInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Date;
import org.apache.commons.lang3.ObjectUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * InputStream, that collects statistical records about data transfer.
 *
 * @author Andreas Rudolph
 */
public class MonitoringInputStream extends FilterInputStream {
    @SuppressWarnings("unused")
    private final static Logger LOGGER = LoggerFactory.getLogger(MonitoringInputStream.class);
    private final DataMonitor monitor;

    @SuppressWarnings("unused")
    public MonitoringInputStream(InputStream in) {
        this(in, null);
    }

    public MonitoringInputStream(InputStream in, DataMonitor monitor) {
        super(in);
        this.monitor = ObjectUtils.defaultIfNull(monitor, new DataMonitor());
    }

    @SuppressWarnings("unused")
    public final DataMonitor getMonitor() {
        return monitor;
    }

    public int read() throws IOException {
        Date start = new Date();
        int b = super.read();
        monitor.addSample(1, start, new Date());
        return b;
    }

    public int read(byte data[]) throws IOException {
        Date start = new Date();
        int cnt = super.read(data);
        monitor.addSample(cnt, start, new Date());
        return cnt;
    }

    public int read(byte data[], int off, int len) throws IOException {
        Date start = new Date();
        int cnt = super.read(data, off, len);
        monitor.addSample(cnt, start, new Date());
        return cnt;
    }
}
