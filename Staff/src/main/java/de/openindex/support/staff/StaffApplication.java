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
package de.openindex.support.staff;

import ch.qos.logback.classic.LoggerContext;
import com.jcraft.jsch.JSch;
import com.jcraft.jsch.JSchException;
import com.jcraft.jsch.Session;
import com.jcraft.jsch.UserInfo;
import de.openindex.support.core.AppUtils;
import de.openindex.support.core.ImageUtils;
import de.openindex.support.core.SwingUtils;
import de.openindex.support.core.io.CopyTextRequest;
import de.openindex.support.core.io.KeyPressRequest;
import de.openindex.support.core.io.KeyReleaseRequest;
import de.openindex.support.core.io.KeyTypeRequest;
import de.openindex.support.core.io.MouseMoveRequest;
import de.openindex.support.core.io.MousePressRequest;
import de.openindex.support.core.io.MouseReleaseRequest;
import de.openindex.support.core.io.MouseWheelRequest;
import de.openindex.support.core.io.ScreenRequest;
import de.openindex.support.core.io.ScreenResponse;
import de.openindex.support.core.io.ScreenTile;
import de.openindex.support.core.io.SocketHandler;
import de.openindex.support.core.monitor.DataMonitor;
import de.openindex.support.core.monitor.MonitoringInputStream;
import de.openindex.support.core.monitor.MonitoringOutputStream;
import java.awt.Desktop;
import java.awt.event.InputEvent;
import java.awt.event.KeyEvent;
import java.awt.event.MouseEvent;
import java.awt.event.MouseWheelEvent;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.OutputStream;
import java.io.Serializable;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.URL;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.ResourceBundle;
import javax.imageio.ImageIO;
import javax.net.ServerSocketFactory;
import javax.net.ssl.SSLServerSocketFactory;
import javax.swing.JTextPane;
import javax.swing.SwingUtilities;
import javax.swing.Timer;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.SystemUtils;
import org.apache.commons.text.StringEscapeUtils;
import org.slf4j.ILoggerFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Staff application.
 *
 * @author Andreas Rudolph
 */
@SuppressWarnings("WeakerAccess")
public class StaffApplication {
    @SuppressWarnings("unused")
    private static Logger LOGGER;
    public final static ResourceBundle SETTINGS;
    public final static String NAME;
    public final static String TITLE;
    public final static String VERSION;
    public final static File WORK_DIR;
    private static StaffOptions options = null;
    private static StaffFrame frame = null;
    private static Session tunnel = null;
    private static ServerSocket serverSocket = null;
    private static Handler handler = null;

    static {
        SETTINGS = ResourceBundle.getBundle("/de/openindex/support/staff/resources/application");
        NAME = setting("name");
        TITLE = setting("title");
        VERSION = setting("version");

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
        LOGGER = LoggerFactory.getLogger(StaffApplication.class);

        // enable debugging for SSL connections
        //System.setProperty("javax.net.debug", "ssl");

        // disable disk based caching for ImageIO
        ImageIO.setUseCache(false);
    }

    @SuppressWarnings("Duplicates")
    public static void main(String[] args) {
        LOGGER.info(StringUtils.repeat("-", 60));
        LOGGER.info("Starting " + TITLE + "...");
        LOGGER.info(StringUtils.repeat("-", 60));
        LOGGER.info("system  : " + SystemUtils.OS_NAME + " (" + SystemUtils.OS_VERSION + ")");
        LOGGER.info("runtime : " + SystemUtils.JAVA_RUNTIME_NAME + " (" + SystemUtils.JAVA_RUNTIME_VERSION + ")");
        LOGGER.info("time    : " + new Date());
        LOGGER.info(StringUtils.repeat("-", 60));

        // configure keystore for SSL connections
        final File keystoreFile = new File(WORK_DIR, "keystore.jks");
        final File keystorePassFile = new File(WORK_DIR, "keystore.jks.txt");
        String keystorePassword = null;
        if (!Boolean.parseBoolean(setting("customKeyStore", "true"))) {
            LOGGER.info("loading internal keystore...");

            // copy internal keystore into the work directory
            // in order to make it usable with system properties
            try (InputStream input = resource("keystore.jks").openStream()) {
                FileUtils.copyToFile(input, keystoreFile);
            } catch (IOException ex) {
                LOGGER.warn("Can't copy internal keystore to work directory!", ex);
            }

            // read password of the internal keystore
            try (InputStream input = resource("keystore.jks.txt").openStream()) {
                keystorePassword = StringUtils.trimToEmpty(IOUtils.toString(input, "UTF-8"));
            } catch (IOException ex) {
                LOGGER.warn("Can't read internal keystore password!", ex);
            }
        } else {
            LOGGER.info("loading external keystore...");

            // copy internal keystore into the work directory,
            // if it is not available yet
            if (!keystoreFile.isFile()) {
                try (InputStream input = resource("keystore.jks").openStream()) {
                    FileUtils.copyToFile(input, keystoreFile);
                } catch (IOException ex) {
                    LOGGER.warn("Can't copy internal keystore to work directory!", ex);
                }
            }

            // copy password of the internal keystore into the work directory,
            // if it is not available yet
            if (!keystorePassFile.isFile()) {
                try (InputStream input = resource("keystore.jks.txt").openStream()) {
                    FileUtils.copyToFile(input, keystorePassFile);
                } catch (IOException ex) {
                    LOGGER.warn("Can't copy internal keystore password to work directory!", ex);
                }
            }

            // read password of the external keystore
            try (InputStream input = new FileInputStream(keystorePassFile)) {
                keystorePassword = StringUtils.trimToEmpty(IOUtils.toString(input, "UTF-8"));
            } catch (IOException ex) {
                LOGGER.warn("Can't read external keystore password!", ex);
            }
        }
        AppUtils.initKeystore(keystoreFile, StringUtils.trimToEmpty(keystorePassword));

        // load options
        options = new StaffOptions(new File(WORK_DIR, "staff.properties"));
        try {
            options.read();
        } catch (IOException ex) {
            LOGGER.warn("Can't read staff options!", ex);
        }

        // setup look and feel
        SwingUtils.installLookAndFeel();

        // set application name for Gnome / Ubuntu
        if (SystemUtils.IS_OS_LINUX)
            SwingUtils.setAwtAppClassName(TITLE);

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
                LOGGER.warn("Can't write staff options!", ex);
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
        return StaffApplication.class.getResource("resources/" + file);
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

    @SuppressWarnings("ConstantConditions")
    private static void start() {
        final Integer localPort = frame.getLocalPort();
        final boolean ssl = frame.isSsl();
        final File sslKeystore = AppUtils.getKeystore();
        final String sslKeystorePassword = AppUtils.getKeystorePassword();
        final boolean ssh = frame.isSsh();
        final Integer sshPort = frame.getSshPort();
        final Integer sshRemotePort = frame.getSshRemotePort();
        final String sshHost = frame.getSshHost();
        final String sshUser = frame.getSshUser();
        final boolean sshKeyAuth = frame.isSshKeyAuth();
        final File sshKey = frame.getSshKey();

        // validation
        List<String> errors = new ArrayList<>();
        if (localPort == null || localPort < 1 || localPort > 65535)
            errors.add(setting("i18n.invalid.port"));
        if (ssl) {
            if (sslKeystore == null)
                errors.add(setting("i18n.invalid.keystoreNotConfigured"));
            else if (!sslKeystore.isFile())
                errors.add(setting("i18n.invalid.keystoreNotFound") + "\n" + sslKeystore.getAbsolutePath());
            if (StringUtils.isBlank(sslKeystorePassword))
                errors.add(setting("i18n.invalid.keystorePasswordMissing"));
        }
        if (ssh) {
            if (sshHost.isEmpty())
                errors.add(setting("i18n.invalid.sshHost"));
            if (sshPort == null || sshPort < 1 || sshPort > 65535)
                errors.add(setting("i18n.invalid.sshPort"));
            if (sshRemotePort == null || sshRemotePort < 1 || sshRemotePort > 65535)
                errors.add(setting("i18n.invalid.sshRemotePort"));
            if (sshUser.isEmpty())
                errors.add(setting("i18n.invalid.sshUser"));
            if (sshKeyAuth && (sshKey == null || !sshKey.isFile()))
                errors.add(setting("i18n.invalid.sshKey"));
        }

        //noinspection Duplicates
        if (!errors.isEmpty()) {
            StringBuilder msg = new StringBuilder(setting("i18n.invalid"));
            msg.append("\n\n");
            for (String error : errors)
                msg.append("- ").append(error).append("\n");

            AppUtils.showError(frame, msg.toString(), setting("i18n.error"));
            return;
        }

        frame.setStarted(true);

        new Thread(() -> {

            if (ssh) {
                try {
                    LOGGER.info("Creating ssh tunnel "
                            + sshHost + ":" + sshRemotePort + " -> "
                            + "localhost:" + localPort + "...");

                    JSch jsch = new JSch();
                    jsch.setKnownHosts(new File(WORK_DIR, "known_hosts.txt").getAbsolutePath());
                    if (sshKeyAuth && sshKey.isFile()) jsch.addIdentity(sshKey.getAbsolutePath());

                    tunnel = jsch.getSession(sshUser, sshHost, sshPort);

                    // setup host key checking
                    if (Boolean.parseBoolean(setting("sshHostKeyCheck", "true")))
                        tunnel.setConfig("StrictHostKeyChecking", "ask");
                    else
                        tunnel.setConfig("StrictHostKeyChecking", "no");

                    // setup packet compression
                    tunnel.setConfig("compression.s2c", "zlib,none");
                    tunnel.setConfig("compression.c2s", "zlib,none");
                    tunnel.setConfig("compression_level", "9");

                    // setup connection info
                    tunnel.setUserInfo(new UserInfo() {
                        private String passphrasePrompt = null;
                        private String passwordPrompt = null;

                        @Override
                        @SuppressWarnings("Duplicates")
                        public String getPassphrase() {
                            String message = StringEscapeUtils.escapeXml11(setting("i18n.sshAuthPassphrase"));
                            if (StringUtils.isNotBlank(passphrasePrompt))
                                message += "\n(" + StringEscapeUtils.escapeXml11(passphrasePrompt) + ")";

                            JTextPane text = new JTextPane();
                            text.setOpaque(false);
                            text.setEditable(false);
                            text.setText(message);

                            return AppUtils.askForPassword(
                                    frame, text, setting("i18n.sshAuth"), setting("i18n.submit"), setting("i18n.cancel"));
                        }

                        @Override
                        @SuppressWarnings("Duplicates")
                        public String getPassword() {
                            String message = StringEscapeUtils.escapeXml11(setting("i18n.sshAuthPassword"));
                            if (StringUtils.isNotBlank(passwordPrompt))
                                message += "\n(" + StringEscapeUtils.escapeXml11(passwordPrompt) + ")";

                            JTextPane text = new JTextPane();
                            text.setOpaque(false);
                            text.setEditable(false);
                            text.setText(message);

                            return AppUtils.askForPassword(
                                    frame, text, setting("i18n.sshAuth"), setting("i18n.submit"), setting("i18n.cancel"));
                        }

                        @Override
                        public boolean promptPassphrase(String message) {
                            passphrasePrompt = StringUtils.trimToNull(message);
                            return sshKeyAuth;
                        }

                        @Override
                        public boolean promptPassword(String message) {
                            passwordPrompt = StringUtils.trimToNull(message);
                            return !sshKeyAuth;
                        }

                        @Override
                        public boolean promptYesNo(String message) {
                            String text = setting("i18n.sshQuestion") + "\n\n" + message;
                            Boolean answer = AppUtils.askQuestion(frame, text, setting("i18n.question"));
                            return Boolean.TRUE.equals(answer);
                        }

                        @Override
                        public void showMessage(String message) {
                            String text = setting("i18n.sshInformation") + "\n\n" + message;
                            AppUtils.showInformation(frame, text, setting("i18n.information"));
                        }
                    });
                    tunnel.connect();
                    tunnel.setPortForwardingR(sshRemotePort, "localhost", localPort);
                } catch (JSchException ex) {
                    LOGGER.error("Can't open ssh tunnel!", ex);
                    stop(true);
                    String message = setting("i18n.error.sshTunnelFailed") + "\n" + ex.getLocalizedMessage();
                    AppUtils.showError(frame, message, setting("i18n.error"));
                    return;
                }
            }

            try {
                LOGGER.info("Creating server socket at port " + localPort + "...");
                //noinspection ConstantConditions
                serverSocket = (ssl) ?
                        SSLServerSocketFactory.getDefault().createServerSocket(localPort) :
                        ServerSocketFactory.getDefault().createServerSocket(localPort);
            } catch (IOException ex) {
                LOGGER.error("Can't open server socket at localPort " + localPort + "!", ex);
                stop(true);
                String message = setting("i18n.error.socketFailed") + "\n" + ex.getLocalizedMessage();
                AppUtils.showError(frame, message, setting("i18n.error"));
                return;
            }

            try {
                if (!ssh) {
                    LOGGER.info("Waiting for connections at localhost:" + localPort + "...");
                    frame.setInfo(setting("i18n.listening") + " localhost:" + localPort + "...");
                } else {
                    LOGGER.info("Waiting for connections at " + sshHost + ":" + sshRemotePort + "...");
                    frame.setInfo(setting("i18n.listening") + " " + sshHost + ":" + sshRemotePort + "...");
                }
                handler = new Handler(serverSocket.accept());
                handler.start();
                frame.setConnected(true);
            } catch (IOException ex) {
                LOGGER.error("Can't initiate communication!", ex);
                stop(true);
                String message = setting("i18n.error.communicationFailed") + "\n" + ex.getLocalizedMessage();
                AppUtils.showError(frame, message, setting("i18n.error"));
                return;
            }

            LOGGER.info("Sending first screen request...");
            handler.sendScreenRequest();
        }).start();
    }

    private static void stop(boolean stopHandler) {
        if (handler != null) {
            if (stopHandler) handler.stop();
            handler = null;
        }
        if (serverSocket != null) {
            try {
                if (!serverSocket.isClosed()) serverSocket.close();
            } catch (IOException ex) {
                LOGGER.error("Can't close server socket!", ex);
            }
            serverSocket = null;
        }
        if (tunnel != null) {
            if (tunnel.isConnected())
                tunnel.disconnect();
            tunnel = null;
        }

        frame.setScreenDisabled();
        frame.setStarted(false);
        frame.setInfo(setting("i18n.connectionClosed"));
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

    private static class Frame extends StaffFrame {
        private Timer mouseMotionTimer = null;
        private MouseEvent mouseMotionEvent = null;
        private Timer resizeTimer = null;
        private boolean windowsKeyDown = false;
        private List<Integer> pressedKeys = new ArrayList<>();

        private Frame(StaffOptions options) {
            super(options);
        }

        @Override
        protected void doAbout() {
            new StaffApplication.AboutDialog().createAndShow();
        }

        @Override
        protected void doCopyText(String text) {
            if (handler == null) return;
            handler.sendCopyText(text);
        }

        @Override
        @SuppressWarnings("Duplicates")
        protected synchronized void doHandleKeyPress(KeyEvent e) {
            if (handler == null) return;
            //LOGGER.debug("key pressed: " + e.paramString());

            // Get code of the pressed key.
            // Keypad arrows are translated to regular arrow keys.
            final int keyCode;
            switch (e.getKeyCode()) {
                case KeyEvent.VK_KP_DOWN:
                    keyCode = KeyEvent.VK_DOWN;
                    break;
                case KeyEvent.VK_KP_LEFT:
                    keyCode = KeyEvent.VK_LEFT;
                    break;
                case KeyEvent.VK_KP_RIGHT:
                    keyCode = KeyEvent.VK_RIGHT;
                    break;
                case KeyEvent.VK_KP_UP:
                    keyCode = KeyEvent.VK_UP;
                    break;
                default:
                    keyCode = e.getKeyCode();
                    break;
            }

            // Never press undefined key codes.
            if (keyCode == KeyEvent.VK_UNDEFINED) {
                return;
            }

            // Never send caps lock, num lock and scroll lock key.
            if (keyCode == KeyEvent.VK_CAPS_LOCK || keyCode == KeyEvent.VK_NUM_LOCK || keyCode == KeyEvent.VK_SCROLL_LOCK) {
                return;
            }

            // Detect, if a control key was pressed.
            final boolean isControlKey = e.isActionKey() ||
                    keyCode == KeyEvent.VK_BACK_SPACE ||
                    keyCode == KeyEvent.VK_DELETE ||
                    keyCode == KeyEvent.VK_ENTER ||
                    keyCode == KeyEvent.VK_SPACE ||
                    keyCode == KeyEvent.VK_TAB ||
                    keyCode == KeyEvent.VK_ESCAPE ||
                    keyCode == KeyEvent.VK_ALT ||
                    keyCode == KeyEvent.VK_ALT_GRAPH ||
                    keyCode == KeyEvent.VK_CONTROL ||
                    keyCode == KeyEvent.VK_SHIFT ||
                    keyCode == KeyEvent.VK_META;

            // Press control keys.
            if (isControlKey) {
                //LOGGER.debug("press key \"{}\" ({})", keyCode, KeyEvent.getKeyText(keyCode));
                handler.sendKeyPress(keyCode);
                e.consume();
            }

            // Press other keys, if they are pressed together with a modifier key.
            else if (e.isControlDown() || e.isMetaDown() || windowsKeyDown || (!SystemUtils.IS_OS_MAC && e.isAltDown())) {
                //LOGGER.debug("press key \"{}\" ({})", keyCode, KeyEvent.getKeyText(keyCode));
                handler.sendKeyPress(keyCode);
                if (!pressedKeys.contains(keyCode))
                    pressedKeys.add(keyCode);
                e.consume();
            }

            // Remember, that the Windows key was pressed.
            if (keyCode == KeyEvent.VK_WINDOWS) {
                synchronized (Frame.this) {
                    windowsKeyDown = true;
                }
            }
        }

        @Override
        @SuppressWarnings("Duplicates")
        protected synchronized void doHandleKeyRelease(KeyEvent e) {
            if (handler == null) return;
            //LOGGER.debug("key released: " + e.paramString());

            // Get code of the released key.
            // Keypad arrows are translated to regular arrow keys.
            final int keyCode;
            switch (e.getKeyCode()) {
                case KeyEvent.VK_KP_DOWN:
                    keyCode = KeyEvent.VK_DOWN;
                    break;
                case KeyEvent.VK_KP_LEFT:
                    keyCode = KeyEvent.VK_LEFT;
                    break;
                case KeyEvent.VK_KP_RIGHT:
                    keyCode = KeyEvent.VK_RIGHT;
                    break;
                case KeyEvent.VK_KP_UP:
                    keyCode = KeyEvent.VK_UP;
                    break;
                default:
                    keyCode = e.getKeyCode();
                    break;
            }

            // Never press undefined key codes.
            if (keyCode == KeyEvent.VK_UNDEFINED) {
                return;
            }

            // Never send caps lock, num lock and scroll lock key.
            if (keyCode == KeyEvent.VK_CAPS_LOCK || keyCode == KeyEvent.VK_NUM_LOCK || keyCode == KeyEvent.VK_SCROLL_LOCK) {
                return;
            }

            // Detect, if a control key was pressed.
            final boolean isControlKey = e.isActionKey() ||
                    keyCode == KeyEvent.VK_BACK_SPACE ||
                    keyCode == KeyEvent.VK_DELETE ||
                    keyCode == KeyEvent.VK_ENTER ||
                    keyCode == KeyEvent.VK_SPACE ||
                    keyCode == KeyEvent.VK_TAB ||
                    keyCode == KeyEvent.VK_ESCAPE ||
                    keyCode == KeyEvent.VK_ALT ||
                    keyCode == KeyEvent.VK_ALT_GRAPH ||
                    keyCode == KeyEvent.VK_CONTROL ||
                    keyCode == KeyEvent.VK_SHIFT ||
                    keyCode == KeyEvent.VK_META;

            // Release control keys.
            if (isControlKey) {
                //LOGGER.debug("release key \"{}\" ({})", keyCode, KeyEvent.getKeyText(keyCode));
                handler.sendKeyRelease(keyCode);
                e.consume();
            }

            // Release other keys, if they are pressed together with a modifier key.
            else if (e.isControlDown() || e.isMetaDown() || windowsKeyDown || (!SystemUtils.IS_OS_MAC && e.isAltDown()) || pressedKeys.contains(keyCode)) {
                //LOGGER.debug("release key \"{}\" ({})", keyCode, KeyEvent.getKeyText(keyCode));
                handler.sendKeyRelease(keyCode);
                pressedKeys.remove((Integer) keyCode);
                e.consume();
            }

            // Forget, that the Windows key is pressed.
            if (keyCode == KeyEvent.VK_WINDOWS) {
                synchronized (Frame.this) {
                    windowsKeyDown = false;
                }
            }
        }

        @Override
        protected synchronized void doHandleKeyTyped(KeyEvent e) {
            if (handler == null) return;
            //LOGGER.debug("key typed: " + e.paramString());
            final char keyChar = e.getKeyChar();

            // Don't type non printable characters.
            if (keyChar == KeyEvent.CHAR_UNDEFINED || Character.isWhitespace(keyChar) || Character.isISOControl(keyChar) || Character.isIdentifierIgnorable(keyChar)) {
                //LOGGER.debug("non printable {} / {}", Character.isWhitespace(keyChar), Character.isISOControl(keyChar));
                return;
            }

            // Don't type a character, if a modifier key is pressed at the same time.
            if (e.isControlDown() || e.isMetaDown() || windowsKeyDown || (!SystemUtils.IS_OS_MAC && e.isAltDown())) {
                //LOGGER.debug("modifier {} / {} / {} / {}", e.isControlDown(), e.isAltDown(), e.isMetaDown(), windowsKeyDown);
                return;
            }

            //LOGGER.debug("type character \"{}\" ({})", keyChar, e.getKeyCode());
            handler.sendKeyType(keyChar);
            e.consume();
        }

        @Override
        protected void doHandleMouseMotion(MouseEvent e) {
            if (handler == null) return;
            //LOGGER.debug("mouse moved: " + e.paramString());

            mouseMotionEvent = e;
            if (mouseMotionTimer != null) {
                return;
            }
            mouseMotionTimer = new Timer(100, e1 -> {
                if (handler != null && mouseMotionEvent != null)
                    handler.sendMouseMove(mouseMotionEvent.getX(), mouseMotionEvent.getY());
                mouseMotionEvent = null;
                mouseMotionTimer = null;
            });
            mouseMotionTimer.setRepeats(false);
            mouseMotionTimer.start();
        }

        @Override
        protected void doHandleMousePress(MouseEvent e) {
            if (handler == null) return;
            //LOGGER.debug("mouse pressed: " + e.paramString());
            handler.sendMousePress(
                    InputEvent.getMaskForButton(e.getButton()));
        }

        @Override
        protected void doHandleMouseRelease(MouseEvent e) {
            if (handler == null) return;
            //LOGGER.debug("mouse released: " + e.paramString());
            handler.sendMouseRelease(
                    InputEvent.getMaskForButton(e.getButton()));
        }

        @Override
        protected void doHandleMouseWheel(MouseWheelEvent e) {
            if (handler == null) return;
            //LOGGER.debug("mouse wheel moved: " + e.paramString());
            handler.sendMouseWheel(
                    e.getScrollAmount() * e.getWheelRotation());
        }

        @Override
        protected void doQuit() {
            stop(true);
            System.exit(0);
        }

        @Override
        protected void doResize() {
            if (handler == null) return;
            //LOGGER.debug("screen resized");

            if (resizeTimer != null) return;
            resizeTimer = new Timer(500, event -> {
                if (handler != null) handler.sendScreenRequest();
                resizeTimer = null;
            });
            resizeTimer.setRepeats(false);
            resizeTimer.start();
        }

        @Override
        protected void doStart() {
            pressedKeys.clear();
            windowsKeyDown = false;
            start();
        }

        @Override
        protected void doStop() {
            stop(true);
        }
    }

    private static class Handler extends SocketHandler {
        private int serverScreenWidth = 0;
        private int serverScreenHeight = 0;
        private Timer monitoringTimer = null;
        private DataMonitor downloadMonitor = null;
        private DataMonitor uploadMonitor = null;

        private Handler(Socket socket) {
            super(socket);
        }

        @Override
        protected ObjectInputStream createObjectInputStream(InputStream input) throws IOException {
            downloadMonitor = new DataMonitor();
            return super.createObjectInputStream(
                    new MonitoringInputStream(input, downloadMonitor));
        }

        @Override
        protected ObjectOutputStream createObjectOutputStream(OutputStream output) throws IOException {
            uploadMonitor = new DataMonitor();
            return super.createObjectOutputStream(
                    new MonitoringOutputStream(output, uploadMonitor));
        }

        @Override
        public void processReceivedObject(Serializable object) {
            if (object instanceof ScreenResponse) {
                //LOGGER.debug("RECEIVE SCREEN RESPONSE");

                final ScreenResponse response = (ScreenResponse) object;
                serverScreenWidth = response.screenWidth;
                serverScreenHeight = response.screenHeight;

                //int byteCount = 0;
                //int sliceCount = 0;
                List<BufferedImage> slices = new ArrayList<>();
                for (ScreenTile tile : response.tiles) {
                    if (tile == null) {
                        slices.add(null);
                        continue;
                    }
                    //byteCount += tile.data.length;
                    //sliceCount++;
                    //LOGGER.debug("received slice (" + tile.data.length + " bytes)");
                    try (InputStream input = new ByteArrayInputStream(tile.data)) {
                        BufferedImage slice = ImageUtils.read(input);
                        if (slice == null) {
                            LOGGER.warn("Can't read tile!");
                            slices.add(null);
                        } else {
                            slices.add(slice);
                        }

                    } catch (Exception ex) {
                        LOGGER.warn("Can't read tile!", ex);
                        slices.add(null);
                    }
                }

                //float bytesPerSlice = (float) byteCount / (float) sliceCount;
                //LOGGER.debug("update screen ("
                //        + sliceCount + " slices, "
                //        + byteCount + " bytes, "
                //        + NumberFormat.getIntegerInstance().format(bytesPerSlice) + " bytes per slice)"
                //);
                frame.updateScreen(
                        slices,
                        response.imageWidth,
                        response.imageHeight,
                        response.tileWidth,
                        response.tileHeight
                );
            } else {
                LOGGER.warn("Received an unsupported object (" + object.getClass().getName() + ")!");
            }
        }

        private void sendCopyText(String text) {
            send(new CopyTextRequest(text));
        }

        private void sendKeyPress(int keyCode) {
            //LOGGER.debug("sendKeyPress | code: " + keyCode);
            send(new KeyPressRequest(keyCode));
        }

        private void sendKeyRelease(int keyCode) {
            //LOGGER.debug("sendKeyRelease | code: " + keyCode);
            send(new KeyReleaseRequest(keyCode));
        }

        private void sendKeyType(char keyChar) {
            //LOGGER.debug("sendKeyType | char: " + keyChar);
            send(new KeyTypeRequest(keyChar));
        }

        private void sendMouseMove(int x, int y) {
            final int viewWidth = frame.getScreenWidth();
            final int viewHeight = frame.getScreenHeight();
            final int imageWidth = frame.getScreenImageWidth();
            final int imageHeight = frame.getScreenImageHeight();
            final int offsetLeft = (viewWidth > imageWidth) ?
                    (int) (((double) (viewWidth - imageWidth)) / 2d) :
                    0;
            final int offsetTop = (viewHeight > imageHeight) ?
                    (int) (((double) (viewHeight - imageHeight)) / 2d) :
                    0;

            if (x < offsetLeft || y < offsetTop) return;

            x -= offsetLeft;
            y -= offsetTop;

            if (x > imageWidth || y > imageHeight) return;

            final double scaleX = (double) serverScreenWidth / (double) imageWidth;
            final double scaleY = (double) serverScreenHeight / (double) imageHeight;

            x = (int) (scaleX * ((double) x));
            y = (int) (scaleY * ((double) y));

            //LOGGER.debug("mouse move    : " + x + " / " + y);
            //LOGGER.debug("> server size : " + serverScreenWidth + " / " + serverScreenHeight);
            //LOGGER.debug("> view size   : " + viewWidth + " / " + viewHeight);
            //LOGGER.debug("> image size  : " + viewWidth + " / " + viewHeight);
            //LOGGER.debug("> offset      : " + offsetLeft + " / " + offsetTop);
            //LOGGER.debug("> coordinates : " + x + " / " + y);

            send(new MouseMoveRequest(x, y));
        }

        private void sendMousePress(int buttons) {
            send(new MousePressRequest(buttons));
        }

        private void sendMouseRelease(int buttons) {
            send(new MouseReleaseRequest(buttons));
        }

        private void sendMouseWheel(int wheelAmt) {
            send(new MouseWheelRequest(wheelAmt));
        }

        private void sendScreenRequest() {
            //LOGGER.debug("SEND SCREEN REQUEST");
            send(new ScreenRequest(
                    frame.getScreenWidth(),
                    frame.getScreenHeight()
            ));
        }

        @Override
        public void start() {
            monitoringTimer = new Timer(1000, e -> {
                if (uploadMonitor == null || downloadMonitor == null)
                    return;
                try {
                    frame.setRates(downloadMonitor.getAverageRate(), uploadMonitor.getAverageRate());

                    Date minAge = new Date(System.currentTimeMillis() - 2000);
                    downloadMonitor.removeOldSamples(minAge);
                    uploadMonitor.removeOldSamples(minAge);
                } catch (Exception ex) {
                    LOGGER.warn("Can't upload monitoring!", ex);
                }
            });
            monitoringTimer.setRepeats(true);
            monitoringTimer.start();

            super.start();
        }

        @Override
        public void stop() {
            super.stop();

            if (monitoringTimer != null) {
                monitoringTimer.stop();
                monitoringTimer = null;
            }

            StaffApplication.stop(false);
        }
    }
}
