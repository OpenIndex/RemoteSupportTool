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

import java.util.Date;
import java.util.Vector;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@SuppressWarnings("WeakerAccess")
public class DataMonitor {
    @SuppressWarnings("unused")
    private final static Logger LOGGER = LoggerFactory.getLogger(DataMonitor.class);
    protected Vector<DataSample> samples;
    protected final Date epoch;

    public DataMonitor() {
        samples = new Vector<>();
        epoch = new Date();
    }

    public void addSample(long byteCount, Date start, Date end) {
        samples.addElement(new DataSample(byteCount, start, end));
    }

    public float getAverageRate() {
        long msCount = 0;
        long byteCount = 0;
        Date start;
        Date finish;
        int sampleCount = samples.size();
        for (int i = 0; i < sampleCount; i++) {
            DataSample ds = samples.elementAt(i);

            if (ds.start != null)
                start = ds.start;
            else if (i > 0) {
                //DataSample prev = samples.elementAt(i - 1);
                start = ds.end;
            } else
                start = epoch;

            if (ds.end != null)
                finish = ds.end;
            else if (i < sampleCount - 1) {
                //DataSample next = samples.elementAt(i + 1);
                finish = ds.start;
            } else
                finish = new Date();

            // Only include this sample if we could figure out a start
            // and finish time for it.
            if (start != null && finish != null) {
                byteCount += ds.byteCount;
                msCount += finish.getTime() - start.getTime();
            }
        }

        float rate = 0;
        if (msCount > 0) {
            rate = 1000 * (float) byteCount / (float) msCount;
        }

        return rate;
    }

    @SuppressWarnings("unused")
    public float getLastRate() {
        int sampleCount = samples.size();
        return getRateFor(sampleCount - 1);
    }

    public float getRateFor(int sampleIndex) {
        float rate = 0.0f;
        int sampleCount = samples.size();
        if (sampleCount > sampleIndex && sampleIndex >= 0) {
            DataSample s = samples.elementAt(sampleIndex);
            Date start = s.start;
            Date end = s.end;
            if (start == null && sampleIndex >= 1) {
                DataSample prev = samples.elementAt(sampleIndex - 1);
                start = prev.end;
            }

            if (start != null && end != null) {
                long msec = end.getTime() - start.getTime();
                rate = 1000 * (float) s.byteCount / (float) msec;
            }
        }

        return rate;
    }

    public void removeOldSamples(Date olderThan) {
        Vector<DataSample> oldSamples = samples;
        samples = new Vector<>();
        for (DataSample sample : oldSamples) {
            if (!sample.end.before(olderThan))
                samples.add(sample);
        }
    }
}
