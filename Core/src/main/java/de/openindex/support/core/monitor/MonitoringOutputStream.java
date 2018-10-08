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
package de.openindex.support.core.monitor;

import java.io.FilterOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.Date;
import org.apache.commons.lang3.ObjectUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class MonitoringOutputStream extends FilterOutputStream {
    @SuppressWarnings("unused")
    private final static Logger LOGGER = LoggerFactory.getLogger(MonitoringOutputStream.class);
    private final DataMonitor monitor;

    @SuppressWarnings("unused")
    public MonitoringOutputStream(OutputStream out) {
        this(out, null);
    }

    public MonitoringOutputStream(OutputStream out, DataMonitor monitor) {
        super(out);
        this.monitor = ObjectUtils.defaultIfNull(monitor, new DataMonitor());
    }

    @SuppressWarnings("unused")
    public DataMonitor getMonitor() {
        return monitor;
    }

    public void write(int b) throws IOException {
        Date start = new Date();
        super.write(b);
        monitor.addSample(1, start, new Date());
    }

    public void write(byte data[]) throws IOException {
        Date start = new Date();
        super.write(data);
        monitor.addSample(data.length, start, new Date());
    }

    public void write(byte data[], int off, int len) throws IOException {
        Date start = new Date();
        super.write(data, off, len);
        monitor.addSample(len, start, new Date());
    }
}
