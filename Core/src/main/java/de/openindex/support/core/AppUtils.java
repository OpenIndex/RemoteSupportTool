/*
 * Copyright 2015-2019 OpenIndex.de.
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

import java.awt.BorderLayout;
import java.awt.Component;
import java.awt.Desktop;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.io.File;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.text.NumberFormat;
import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JComponent;
import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JPasswordField;
import javax.swing.JTextPane;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.SystemUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * General helper methods.
 *
 * @author Andreas Rudolph
 */
@SuppressWarnings("WeakerAccess")
public class AppUtils {
    @SuppressWarnings("unused")
    private final static Logger LOGGER = LoggerFactory.getLogger(AppUtils.class);
    private final static String KEYSTORE = "javax.net.ssl.keyStore";
    private final static String KEYSTORE_PASSWORD = "javax.net.ssl.keyStorePassword";
    private final static String TRUSTSTORE = "javax.net.ssl.trustStore";
    private final static String TRUSTSTORE_PASSWORD = "javax.net.ssl.trustStorePassword";
    private static char[] lastPassword = null;

    private AppUtils() {
        super();
    }

    public static String askForPassword(JFrame parent, Object message, String title, String submitText, String cancelText) {
        final JDialog dialog = new JDialog(parent, true);

        final JPasswordField field = new JPasswordField();
        field.addKeyListener(new KeyAdapter() {
            @Override
            public void keyReleased(KeyEvent e) {
                if (e.getKeyCode() == KeyEvent.VK_ENTER) {
                    lastPassword = field.getPassword();
                    dialog.setVisible(false);
                }
            }
        });
        if (lastPassword != null)
            field.setText(StringUtils.trimToEmpty(String.valueOf(lastPassword)));

        final JPanel panel = new JPanel(new BorderLayout(5, 5));
        panel.setOpaque(false);
        panel.add(field, BorderLayout.SOUTH);

        if (message instanceof JComponent) {
            panel.add((JComponent) message, BorderLayout.NORTH);
        } else if (message instanceof String) {
            panel.add(new JLabel((String) message), BorderLayout.NORTH);
        }

        final JButton submitButton = new JButton();
        submitButton.setText(StringUtils.defaultIfBlank(submitText, "Submit"));
        submitButton.addActionListener(e -> {
            lastPassword = field.getPassword();
            dialog.setVisible(false);
        });

        final JButton cancelButton = new JButton();
        cancelButton.setText(StringUtils.defaultIfBlank(cancelText, "Cancel"));
        cancelButton.addActionListener(e -> {
            field.setText(StringUtils.EMPTY);
            dialog.setVisible(false);
        });

        final JPanel buttonBar = new JPanel(new FlowLayout(FlowLayout.CENTER));
        buttonBar.add(submitButton);
        buttonBar.add(cancelButton);
        buttonBar.setBorder(BorderFactory.createEmptyBorder(10, 0, 0, 0));

        dialog.setResizable(false);
        dialog.setTitle(title);
        dialog.setMinimumSize(new Dimension(300, 0));
        dialog.setDefaultCloseOperation(JDialog.DO_NOTHING_ON_CLOSE);
        dialog.addWindowListener(new WindowAdapter() {
            @Override
            public void windowClosing(WindowEvent e) {
                field.setText(StringUtils.EMPTY);
                dialog.setVisible(false);
            }
        });
        dialog.getRootPane().setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));
        dialog.getRootPane().setLayout(new BorderLayout());
        dialog.getRootPane().add(panel, BorderLayout.NORTH);
        dialog.getRootPane().add(buttonBar, BorderLayout.SOUTH);

        dialog.pack();
        dialog.setLocationRelativeTo(parent);
        field.requestFocus();
        field.selectAll();
        dialog.setVisible(true);

        dialog.dispose();
        return StringUtils.trimToNull(String.valueOf(field.getPassword()));
    }

    public static Boolean askQuestion(Component parent, String message, String title) {
        JTextPane content = new JTextPane();
        content.setEditable(false);
        content.setOpaque(false);
        content.setText(message);

        int response = JOptionPane.showConfirmDialog(
                parent, content, title, JOptionPane.YES_NO_OPTION);

        if (response == JOptionPane.OK_OPTION)
            return true;
        if (response == JOptionPane.NO_OPTION)
            return false;
        return null;
    }

    public static void browse(String url) {
        if (StringUtils.isBlank(url)) return;
        try {
            browse(new URI(url));
        } catch (URISyntaxException ex) {
            LOGGER.warn("Can't parse URL '" + url + "'!", ex);
        }
    }

    public static void browse(URL url) {
        if (url == null) return;
        try {
            browse(url.toURI());
        } catch (URISyntaxException ex) {
            LOGGER.error("Can't convert URL '" + url.toString() + "'!", ex);
        }
    }

    public static void browse(URI url) {
        if (url == null) return;
        if (Desktop.isDesktopSupported()) {
            Desktop desktop = Desktop.getDesktop();
            if (desktop.isSupported(Desktop.Action.BROWSE)) {
                try {
                    desktop.browse(url);
                    return;
                } catch (Exception ex) {
                    LOGGER.error("Can't open the default web browser!", ex);
                }
            }
        }

        try {
            if (SystemUtils.IS_OS_WINDOWS) {
                Runtime.getRuntime()
                        .exec("rundll32 url.dll,FileProtocolHandler " + url)
                        .waitFor();
            } else if (SystemUtils.IS_OS_MAC_OSX) {
                Runtime.getRuntime()
                        .exec(new String[]{"open", url.toString()})
                        .waitFor();
            } else if (SystemUtils.IS_OS_UNIX) {
                Runtime.getRuntime()
                        .exec(new String[]{"xdg-open", url.toString()})
                        .waitFor();
            } else {
                throw new Exception("No browser found for this operating system (" + SystemUtils.OS_NAME + ")!");
            }
        } catch (Exception ex) {
            LOGGER.error("Can't execute a browser command!", ex);
        }
    }

    public static String getDefaultSshKey() {
        File idRsa = new File(new File(SystemUtils.getUserHome(), ".ssh"), "id_rsa");
        if (idRsa.isFile())
            return idRsa.getAbsolutePath();

        File idDsa = new File(new File(SystemUtils.getUserHome(), ".ssh"), "id_dsa");
        if (idDsa.isFile())
            return idDsa.getAbsolutePath();

        return null;
    }

    public static String getHumanReadableByteCount(long size) {
        NumberFormat numberFormat = NumberFormat.getNumberInstance();
        numberFormat.setMinimumFractionDigits(0);
        numberFormat.setMaximumFractionDigits(2);
        return getHumanReadableByteCount(size, numberFormat);
    }

    public static String getHumanReadableByteCount(long size, NumberFormat numberFormat) {
        if (size / FileUtils.ONE_GB > 0) {
            double value = (double) size / (double) FileUtils.ONE_GB;
            return numberFormat.format(value) + " GB";
        } else if (size / FileUtils.ONE_MB > 0) {
            double value = (double) size / (double) FileUtils.ONE_MB;
            return numberFormat.format(value) + " MB";
        } else if (size / FileUtils.ONE_KB > 0) {
            double value = (double) size / (double) FileUtils.ONE_KB;
            return numberFormat.format(value) + " KB";
        }
        return numberFormat.format(size) + " bytes";
    }

    public static File getKeystore() {
        String keystore = System.getProperty(KEYSTORE);
        return (StringUtils.isNotBlank(keystore)) ?
                new File(keystore) : null;
    }

    public static String getKeystorePassword() {
        return StringUtils.trimToNull(System.getProperty(KEYSTORE_PASSWORD));
    }

    public static void initKeystore(File defaultKeystore, String defaultPassword) {
        System.setProperty(KEYSTORE, StringUtils.defaultIfBlank(
                System.getProperty(KEYSTORE), defaultKeystore.getAbsolutePath()));
        System.setProperty(KEYSTORE_PASSWORD, StringUtils.defaultIfBlank(
                System.getProperty(KEYSTORE_PASSWORD), defaultPassword));
    }

    public static void initTruststore(File defaultTruststore, String defaultPassword) {
        System.setProperty(TRUSTSTORE, StringUtils.defaultIfBlank(
                System.getProperty(TRUSTSTORE), defaultTruststore.getAbsolutePath()));
        System.setProperty(TRUSTSTORE_PASSWORD, StringUtils.defaultIfBlank(
                System.getProperty(TRUSTSTORE_PASSWORD), defaultPassword));
    }

    public static boolean isAsciiCharacter(char character) {
        return character == ' ' || // is space
                (character >= 48 && character <= 57) || // is number
                (character >= 65 && character <= 90) || // is upper case letter
                (character >= 97 && character <= 122); // is lower case letter
    }

    public static URL resource(String file) {
        return AppUtils.class.getResource("resources/" + file);
    }

    public static void showError(Component parent, String message, String title) {
        showMessage(parent, message, title, JOptionPane.ERROR_MESSAGE);
    }

    public static void showInformation(Component parent, String message, String title) {
        showMessage(parent, message, title, JOptionPane.INFORMATION_MESSAGE);
    }

    public static void showMessage(Component parent, String message, String title, int type) {
        JTextPane content = new JTextPane();
        content.setEditable(false);
        content.setOpaque(false);
        content.setText(message);
        JOptionPane.showMessageDialog(parent, content, title, type);
    }
}
