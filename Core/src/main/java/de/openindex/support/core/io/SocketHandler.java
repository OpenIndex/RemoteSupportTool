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
package de.openindex.support.core.io;

import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.OutputStream;
import java.io.Serializable;
import java.net.Socket;
import java.util.concurrent.ConcurrentLinkedQueue;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * General handler on a socket.
 *
 * @author Andreas Rudolph
 */
public abstract class SocketHandler {
    @SuppressWarnings("unused")
    private final static Logger LOGGER = LoggerFactory.getLogger(SocketHandler.class);
    private final Socket socket;
    protected final ConcurrentLinkedQueue<Object> outbox = new ConcurrentLinkedQueue<>();
    private final Object outboxLock = new Object();

    public SocketHandler(Socket socket) {
        super();
        this.socket = socket;
    }

    protected ObjectInputStream createObjectInputStream(InputStream input) throws IOException {
        return new ObjectInputStream(input);
    }

    protected ObjectOutputStream createObjectOutputStream(OutputStream output) throws IOException {
        return new ObjectOutputStream(output);
    }

    public abstract void processReceivedObject(Serializable object);

    public void send(Object object) {
        if (object == null) return;
        this.outbox.add(object);

        try {
            // unblock the socket output thread
            synchronized (outboxLock) {
                outboxLock.notifyAll();
            }
        } catch (Exception ex) {
            LOGGER.warn("Can't unblock socket output!", ex);
        }
    }

    public void stop() {
        this.outbox.clear();
        try {
            this.socket.close();
        } catch (IOException ex) {
            LOGGER.warn("Can't close socket!", ex);
        }
        try {
            // unlock the socket output thread
            synchronized (outboxLock) {
                outboxLock.notifyAll();
            }
        } catch (Exception ex) {
            LOGGER.warn("Can't unblock socket output!", ex);
        }
    }

    public void start() {

        // process socket input
        new Thread(() -> {
            try (ObjectInputStream input = createObjectInputStream(socket.getInputStream())) {
                while (!socket.isClosed() && socket.isConnected()) {
                    try {
                        //LOGGER.debug("processing inbox");
                        processReceivedObject((Serializable) input.readObject());
                    } catch (ClassNotFoundException ex) {
                        LOGGER.error("Received an unsupported object!", ex);
                    }
                }
                //LOGGER.debug("finished inbox thread");
            } catch (Exception ex) {
                LOGGER.error("Can't process socket input!", ex);
            }
            stop();
        }).start();

        // process socket output
        new Thread(() -> {
            try (ObjectOutputStream output = createObjectOutputStream(socket.getOutputStream())) {
                while (!socket.isClosed() && socket.isConnected()) {
                    synchronized (outboxLock) {
                        // might have changed while waiting to synchronize on outbox lock
                        if (socket.isClosed() || !socket.isConnected())
                            break;

                        // send this thread into pause until new requests occur in the outbox
                        if (outbox.isEmpty()) {
                            //LOGGER.debug("pausing outbox");
                            outboxLock.wait();
                        }
                    }

                    // running might have changed since we paused
                    if (socket.isClosed() || !socket.isConnected())
                        break;

                    //LOGGER.debug("processing outbox");
                    Object item = outbox.poll();
                    if (item instanceof ResponseFactory) {
                        try {
                            item = ((ResponseFactory) item).create();
                        } catch (Exception ex) {
                            LOGGER.error("Can't create response item!", ex);
                            continue;
                        }
                    }
                    if (item != null) {
                        output.writeObject(item);
                        output.flush();
                        output.reset();
                    }
                }
                //LOGGER.debug("finished outbox thread");
            } catch (Exception ex) {
                LOGGER.error("Can't process socket output!", ex);
            }
            stop();
        }).start();
    }
}
