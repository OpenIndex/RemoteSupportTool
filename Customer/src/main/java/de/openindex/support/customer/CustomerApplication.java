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
package de.openindex.support.customer;

import ch.qos.logback.classic.LoggerContext;
import de.openindex.support.core.AppUtils;
import de.openindex.support.core.ImageUtils;
import de.openindex.support.core.io.KeyPressRequest;
import de.openindex.support.core.io.KeyReleaseRequest;
import de.openindex.support.core.io.MouseMoveRequest;
import de.openindex.support.core.io.MousePressRequest;
import de.openindex.support.core.io.MouseReleaseRequest;
import de.openindex.support.core.io.MouseWheelRequest;
import de.openindex.support.core.io.PasteTextRequest;
import de.openindex.support.core.io.ResponseFactory;
import de.openindex.support.core.io.ScreenRequest;
import de.openindex.support.core.io.ScreenResponse;
import de.openindex.support.core.io.ScreenTile;
import de.openindex.support.core.io.SocketHandler;
import de.openindex.support.customer.utils.Robot;
import java.awt.AWTException;
import java.awt.Desktop;
import java.awt.GraphicsConfiguration;
import java.awt.GraphicsDevice;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyEvent;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.Serializable;
import java.net.Socket;
import java.net.URL;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.ResourceBundle;
import javax.imageio.ImageIO;
import javax.net.SocketFactory;
import javax.net.ssl.SSLSocketFactory;
import javax.swing.SwingUtilities;
import javax.swing.Timer;
import javax.swing.UIManager;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.CharUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.SystemUtils;
import org.slf4j.ILoggerFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Customer application.
 *
 * @author Andreas Rudolph
 */
@SuppressWarnings("WeakerAccess")
public class CustomerApplication {
    @SuppressWarnings("unused")
    private static Logger LOGGER;
    public final static ResourceBundle SETTINGS;
    public final static String NAME;
    public final static String TITLE;
    public final static String VERSION;
    public final static File WORK_DIR;
    private final static float JPEG_COMPRESSION = 0.6f;
    private final static int SLICE_WIDTH = 100;
    private final static int SLICE_HEIGHT = 100;
    private final static int SCREENSHOT_DELAY = 250;
    private static CustomerOptions options = null;
    private static CustomerFrame frame = null;
    private static Handler handler = null;
    private static Robot robot = null;
    private static GraphicsDevice screen = null;
    private static Timer screenshotTimer = null;

    static {
        SETTINGS = ResourceBundle.getBundle("/de/openindex/support/customer/resources/application");
        NAME = SETTINGS.getString("name");
        TITLE = SETTINGS.getString("title");
        VERSION = SETTINGS.getString("version");

        // get work directory
        // use the AppData folder on Windows systems, if available
        String appDataPath = (SystemUtils.IS_OS_WINDOWS) ?
                SystemUtils.getEnvironmentVariable("APPDATA", null) :
                null;
        WORK_DIR = (StringUtils.isNotBlank(appDataPath)) ?
                new File(appDataPath, NAME) :
                new File(SystemUtils.getUserHome(), "." + NAME);
        if (!WORK_DIR.isDirectory() && !WORK_DIR.mkdirs()) {
            System.err.println("Can't create work directory at: " + WORK_DIR.getAbsolutePath());
            System.exit(1);
        }
        System.setProperty("app.dir", WORK_DIR.getAbsolutePath());

        // init logging
        LOGGER = LoggerFactory.getLogger(CustomerApplication.class);

        // enable debugging for SSL connections
        //System.setProperty("javax.net.debug", "ssl");

        // disable disk based caching for ImageIO
        ImageIO.setUseCache(false);
    }

    public static void main(String[] args) {
        LOGGER.info(StringUtils.repeat("-", 60));
        LOGGER.info("Starting " + TITLE + "...");
        LOGGER.info(StringUtils.repeat("-", 60));
        LOGGER.info("system  : " + SystemUtils.OS_NAME + " (" + SystemUtils.OS_VERSION + ")");
        LOGGER.info("runtime : " + SystemUtils.JAVA_RUNTIME_NAME + " (" + SystemUtils.JAVA_RUNTIME_VERSION + ")");
        LOGGER.info("time    : " + new Date());
        LOGGER.info(StringUtils.repeat("-", 60));

        // configure truststore for SSL connections
        final File truststoreFile = new File(WORK_DIR, "truststore.jks");
        final File truststorePassFile = new File(WORK_DIR, "truststore.jks.txt");
        String truststorePassword = null;
        if (!Boolean.parseBoolean(setting("customTrustStore", "true"))) {
            LOGGER.info("loading internal truststore...");

            // copy internal truststore into the work directory
            // in order to make it usable with system properties
            try (InputStream input = resource("truststore.jks").openStream()) {
                FileUtils.copyToFile(input, truststoreFile);
            } catch (IOException ex) {
                LOGGER.warn("Can't copy internal truststore to work directory!", ex);
            }

            // read password of the internal truststore
            try (InputStream input = resource("truststore.jks.txt").openStream()) {
                truststorePassword = StringUtils.trimToEmpty(IOUtils.toString(input, "UTF-8"));
            } catch (IOException ex) {
                LOGGER.warn("Can't read internal truststore password!", ex);
            }
        } else {
            LOGGER.info("loading external truststore...");

            // copy internal truststore into the work directory,
            // if it is not available yet
            if (!truststoreFile.isFile()) {
                try (InputStream input = resource("truststore.jks").openStream()) {
                    FileUtils.copyToFile(input, truststoreFile);
                } catch (IOException ex) {
                    LOGGER.warn("Can't copy internal truststore to work directory!", ex);
                }
            }

            // copy password of the internal truststore into the work directory,
            // if it is not available yet
            if (!truststorePassFile.isFile()) {
                try (InputStream input = resource("truststore.jks.txt").openStream()) {
                    FileUtils.copyToFile(input, truststorePassFile);
                } catch (IOException ex) {
                    LOGGER.warn("Can't copy internal truststore password to work directory!", ex);
                }
            }

            // read password of the external truststore
            try (InputStream input = new FileInputStream(new File(WORK_DIR, "truststore.jks.txt"))) {
                truststorePassword = StringUtils.trimToEmpty(IOUtils.toString(input, "UTF-8"));
            } catch (IOException ex) {
                LOGGER.warn("Can't read external truststore password!", ex);
            }
        }
        AppUtils.initTruststore(truststoreFile, StringUtils.trimToEmpty(truststorePassword));

        // load options
        options = new CustomerOptions(new File(WORK_DIR, "customer.properties"));
        try {
            options.read();
        } catch (IOException ex) {
            LOGGER.warn("Can't read customer options!", ex);
        }

        // setup look and feel
        try {
            UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
        } catch (Exception ex) {
            LOGGER.warn("Can't set look & feel!", ex);
        }

        // setup desktop environment
        //noinspection Duplicates
        if (Desktop.isDesktopSupported()) {
            Desktop desktop = Desktop.getDesktop();

            // register about dialog
            if (desktop.isSupported(Desktop.Action.APP_ABOUT)) {
                desktop.setAboutHandler(e -> new AboutDialog().createAndShow());
            }
        }

        // start application
        frame = new Frame(options);
        SwingUtilities.invokeLater(() -> frame.createAndShow());

        // register shutdown hook
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            LOGGER.info("Shutdown " + TITLE + "...");

            // write options
            try {
                options.write();
            } catch (IOException ex) {
                LOGGER.warn("Can't write customer options!", ex);
            }

            // shutdown logger
            ILoggerFactory loggerFactory = LoggerFactory.getILoggerFactory();
            if (loggerFactory instanceof LoggerContext) {
                LoggerContext context = (LoggerContext) loggerFactory;
                context.stop();
            }
        }));
    }

    public static URL resource(String file) {
        return CustomerApplication.class.getResource("resources/" + file);
    }

    @SuppressWarnings("Duplicates")
    public static URL resourceBranding() {
        final Locale l = Locale.getDefault();

        URL branding = resource("branding_" + l.getLanguage() + "-" + l.getCountry() + ".png");
        if (branding == null) branding = resource("branding_" + l.getLanguage() + ".png");
        if (branding == null) branding = resource("branding.png");

        return branding;
    }

    public static String setting(String key) {
        return setting(key, StringUtils.EMPTY);
    }

    public static String setting(String key, String defaultValue) {
        return StringUtils.defaultIfBlank(SETTINGS.getString(key), defaultValue);
    }

    private static void start() {
        final String host = frame.getHost();
        final Integer port = frame.getPort();
        final boolean ssl = frame.isSsl();
        screen = frame.getScreen();

        List<String> errors = new ArrayList<>();
        if (host.isEmpty())
            errors.add(setting("i18n.invalid.host"));
        if (port == null || port < 1 || port > 65535)
            errors.add(setting("i18n.invalid.port"));
        if (screen == null)
            errors.add(setting("i18n.invalid.screen"));

        //noinspection Duplicates
        if (!errors.isEmpty()) {
            StringBuilder msg = new StringBuilder(setting("i18n.invalid"));
            msg.append("\n\n");
            for (String error : errors)
                msg.append("- ").append(error).append("\n");

            AppUtils.showError(frame, msg.toString(), setting("i18n.error"));
            return;
        }

        frame.setStatusConnecting();
        frame.setStarted(true);

        try {
            robot = new Robot(screen);
        } catch (AWTException ex) {
            LOGGER.error("Can't create robot!", ex);
            stop(true);
        }

        LOGGER.info("Connecting to " + host + ":" + port + "...");

        try {
            //noinspection ConstantConditions
            Socket socket = (ssl) ?
                    SSLSocketFactory.getDefault().createSocket(host, port) :
                    SocketFactory.getDefault().createSocket(host, port);

            handler = new Handler(socket);
            handler.start();
            frame.setStatusConnected();
        } catch (IOException ex) {
            LOGGER.error("Connection to " + host + ":" + port + " failed!", ex);
            stop(true);

            String message = setting("i18n.error.connectionFailed") + "\n" + ex.getLocalizedMessage();
            AppUtils.showError(frame, message, setting("i18n.error"));
        }
    }

    private static void stop(boolean stopHandler) {
        if (handler != null) {
            if (stopHandler) handler.stop();
            handler = null;
        }
        if (screenshotTimer != null) {
            screenshotTimer.stop();
            screenshotTimer = null;
        }

        robot = null;
        screen = null;
        frame.setStarted(false);
        frame.setStatusDisconnected();
    }

    private static class AboutDialog extends de.openindex.support.core.gui.AboutDialog {
        private AboutDialog() {
            super(frame, SETTINGS, resource("sidebar_about.png"), resourceBranding());
        }

        @Override
        @SuppressWarnings("Duplicates")
        protected String getAboutText() {
            final Locale l = Locale.getDefault();

            URL about = resource("about_" + l.getLanguage() + "-" + l.getCountry() + ".html");
            if (about == null) about = resource("about_" + l.getLanguage() + ".html");
            if (about == null) about = resource("about.html");

            try (InputStream input = about.openStream()) {
                return IOUtils.toString(input, "UTF-8");
            } catch (IOException ex) {
                LOGGER.error("Can't read application information!", ex);
                return StringUtils.EMPTY;
            }
        }
    }

    private static class Frame extends CustomerFrame {
        private Frame(CustomerOptions options) {
            super(options);
        }

        @Override
        protected void doAbout() {
            new CustomerApplication.AboutDialog().createAndShow();
        }

        @Override
        protected void doQuit() {
            stop(true);
            System.exit(0);
        }

        @Override
        protected void doStart() {
            start();
        }

        @Override
        protected void doStop() {
            stop(true);
        }
    }

    private static class Handler extends SocketHandler {

        private Handler(Socket socket) {
            super(socket);
        }

        @Override
        public void processReceivedObject(Serializable object) {
            try {
                if (object instanceof ScreenRequest) {

                    final ScreenRequest request = (ScreenRequest) object;

                    if (screenshotTimer != null) {
                        screenshotTimer.stop();
                        screenshotTimer = null;
                    }

                    //LOGGER.debug("creating screen shooter for " + request.maxWidth + " / " + request.maxHeight);
                    screenshotTimer = new Timer(SCREENSHOT_DELAY, new ScreenShooter(request));
                    screenshotTimer.setRepeats(true);
                    screenshotTimer.start();

                } else if (object instanceof KeyPressRequest) {

                    final KeyPressRequest request = (KeyPressRequest) object;
                    //LOGGER.debug("key pressed: " + request.keyCode + " / " + request.keyChar);

                    if (request.keyCode != KeyEvent.VK_UNDEFINED)
                        robot.keyPress(request.keyCode);
                    else if (request.keyChar != KeyEvent.CHAR_UNDEFINED) {
                        int code = KeyEvent.getExtendedKeyCodeForChar(request.keyChar);
                        //LOGGER.debug("key pressed: " + request.keyChar + " / " + code + " / " + CharUtils.isAsciiPrintable(request.keyChar));
                        if (CharUtils.isAsciiAlphanumeric(request.keyChar) && code != KeyEvent.VK_UNDEFINED) {
                            try {
                                robot.keyPress(code);
                            } catch (IllegalArgumentException ex) {
                                LOGGER.warn("Can't press key '" + request.keyChar + "' (" + code + "): " + ex.getLocalizedMessage());
                            }
                        }
                    }

                } else if (object instanceof KeyReleaseRequest) {

                    final KeyReleaseRequest request = (KeyReleaseRequest) object;
                    //LOGGER.debug("key released: " + request.keyCode + " / " + request.keyChar);

                    if (request.keyCode != KeyEvent.VK_UNDEFINED)
                        robot.keyRelease(request.keyCode);
                    else if (request.keyChar != KeyEvent.CHAR_UNDEFINED) {
                        int code = KeyEvent.getExtendedKeyCodeForChar(request.keyChar);
                        //LOGGER.debug("key released: " + request.keyChar + " / " + code + " / " + CharUtils.isAsciiPrintable(request.keyChar));
                        if (robot.isPressed(code)) {
                            try {
                                robot.keyRelease(code);
                            } catch (IllegalArgumentException ex) {
                                LOGGER.warn("Can't release key '" + request.keyChar + "' (" + code + "): " + ex.getLocalizedMessage());
                            }
                        } else {
                            robot.printCharacter(request.keyChar);
                        }
                    }

                } else if (object instanceof MouseMoveRequest) {

                    final MouseMoveRequest request = (MouseMoveRequest) object;
                    final int x;
                    final int y;

                    // On Windows systems we need to convert the coordinates
                    // according to the current screen scaling factor.
                    if (SystemUtils.IS_OS_WINDOWS) {
                        final GraphicsConfiguration screenConfiguration = screen.getDefaultConfiguration();
                        final AffineTransform transform = screenConfiguration.getDefaultTransform();
                        final double scaleX = (transform != null && transform.getScaleX() > 0) ?
                                transform.getScaleX() : 1;
                        final double scaleY = (transform != null && transform.getScaleY() > 0) ?
                                transform.getScaleY() : 1;

                        x = (int) ((double) request.x / scaleX);
                        y = (int) ((double) request.y / scaleY);
                    } else {
                        x = request.x;
                        y = request.y;
                    }

                    robot.mouseMove(x, y);

                } else if (object instanceof MousePressRequest) {

                    final MousePressRequest request = (MousePressRequest) object;
                    robot.mousePress(request.buttons);

                } else if (object instanceof MouseReleaseRequest) {

                    final MouseReleaseRequest request = (MouseReleaseRequest) object;
                    robot.mouseRelease(request.buttons);

                } else if (object instanceof MouseWheelRequest) {

                    final MouseWheelRequest request = (MouseWheelRequest) object;
                    robot.mouseWheel(request.wheelAmt);

                } else if (object instanceof PasteTextRequest) {

                    final PasteTextRequest request = (PasteTextRequest) object;
                    robot.pasteText(request.text);

                } else {

                    LOGGER.warn("Received an unsupported object (" + object.getClass().getName() + ")!");

                }
            } catch (Exception ex) {
                LOGGER.error("Can't process received object!", ex);
            }
        }

        @Override
        public void send(Object object) {
            if (!outbox.contains(object)) {
                super.send(object);
            }
        }

        @Override
        public void stop() {
            super.stop();
            CustomerApplication.stop(false);
        }
    }

    private static class ScreenShooter implements ActionListener, ResponseFactory {
        private final ScreenRequest request;
        private BufferedImage[] lastSlices = null;
        private int lastMaxWidth = 0;
        private int lastMaxHeight = 0;

        private ScreenShooter(ScreenRequest request) {
            super();
            this.request = request;
        }

        @Override
        public void actionPerformed(ActionEvent e) {
            if (handler != null) handler.send(ScreenShooter.this);
        }

        @Override
        public Serializable create() {
            if (handler == null) return null;
            //LOGGER.debug("creating screenshot");

            final GraphicsConfiguration screenConfiguration = screen.getDefaultConfiguration();
            final BufferedImage image = robot.createScreenCapture(screenConfiguration.getBounds());
            final int w = image.getWidth();
            final int h = image.getHeight();

            final BufferedImage imageToSend;
            if (w <= request.maxWidth && h <= request.maxHeight) {
                imageToSend = image;
            } else {
                imageToSend = ImageUtils.resize(image, request.maxWidth, request.maxHeight);
            }

            if (lastMaxWidth != request.maxWidth) {
                lastMaxWidth = request.maxWidth;
                lastSlices = null;
            }
            if (lastMaxHeight != request.maxHeight) {
                lastMaxHeight = request.maxHeight;
                lastSlices = null;
            }

            BufferedImage[] slices = ImageUtils.getSlices(imageToSend, SLICE_WIDTH, SLICE_HEIGHT);
            BufferedImage[] slicesToSend = null;
            if (lastSlices == null) {
                lastSlices = slices;
                slicesToSend = slices;
            } else {
                for (int i = 0; i < slices.length; i++) {
                    if (!ImageUtils.equals(slices[i], lastSlices[i])) {
                        lastSlices[i] = slices[i];

                        if (slicesToSend == null)
                            slicesToSend = new BufferedImage[slices.length];

                        slicesToSend[i] = slices[i];
                    } else if (slicesToSend != null) {
                        slicesToSend[i] = null;
                    }
                }
            }

            // there a no slices to send in response
            if (slicesToSend == null) {
                //LOGGER.debug("no slices to send");
                return null;
            }

            // create tiles to send in response
            List<ScreenTile> tiles = new ArrayList<>();
            for (BufferedImage slice : slicesToSend) {
                if (slice == null) {
                    tiles.add(null);
                    continue;
                }
                try (ByteArrayOutputStream imageOutput = new ByteArrayOutputStream()) {
                    ImageUtils.write(slice, imageOutput, JPEG_COMPRESSION);
                    tiles.add(new ScreenTile(imageOutput.toByteArray()));
                } catch (IOException ex) {
                    LOGGER.error("Can't create screenshot slice!", ex);
                    return null;
                }
            }

            // send response with modified tiles
            //LOGGER.debug("sending screenshot response");
            return new ScreenResponse(
                    tiles.toArray(new ScreenTile[0]),
                    screen.getDisplayMode().getWidth(),
                    screen.getDisplayMode().getHeight(),
                    imageToSend.getWidth(),
                    imageToSend.getHeight(),
                    SLICE_WIDTH,
                    SLICE_HEIGHT
            );
        }
    }
}
