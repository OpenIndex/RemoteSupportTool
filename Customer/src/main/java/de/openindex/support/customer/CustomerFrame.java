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
package de.openindex.support.customer;

import de.openindex.support.core.ImageUtils;
import de.openindex.support.core.gui.SidebarPanel;
import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Component;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.Font;
import java.awt.GraphicsConfiguration;
import java.awt.GraphicsDevice;
import java.awt.GraphicsEnvironment;
import java.awt.Rectangle;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import javax.swing.BorderFactory;
import javax.swing.DefaultListCellRenderer;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JPanel;
import javax.swing.JSpinner;
import javax.swing.JTextField;
import javax.swing.SpinnerNumberModel;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;
import net.miginfocom.swing.MigLayout;
import org.apache.commons.text.StringEscapeUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Main frame of the customer application.
 *
 * @author Andreas Rudolph
 */
@SuppressWarnings("WeakerAccess")
public abstract class CustomerFrame extends JFrame {
    @SuppressWarnings("unused")
    private final static Logger LOGGER = LoggerFactory.getLogger(CustomerFrame.class);
    private final CustomerOptions options;
    private JLabel hostLabel = null;
    private JTextField hostField = null;
    private JLabel portLabel = null;
    private JSpinner portField = null;
    private JLabel screenLabel = null;
    private JComboBox<GraphicsDevice> screenField = null;
    private JCheckBox sslField = null;
    private JLabel statusLabel = null;
    private JButton startButton = null;
    private JButton stopButton = null;

    public CustomerFrame(CustomerOptions options) {
        super();
        this.options = options;
    }

    @SuppressWarnings("Duplicates")
    public void createAndShow() {
        // init frame
        setTitle(CustomerApplication.setting("i18n.appTitle"));
        setIconImage(ImageUtils.loadImage(CustomerApplication.resource("application.png")));
        setPreferredSize(new Dimension(600, 350));
        setMinimumSize(new Dimension(500, 300));
        setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);
        addWindowListener(new WindowAdapter() {
            @Override
            public void windowClosing(WindowEvent e) {
                doQuit();
            }
        });
        getRootPane().setBackground(Color.WHITE);
        getRootPane().setOpaque(true);

        // title
        JLabel titleLabel = new JLabel();
        titleLabel.setText(CustomerApplication.setting("i18n.title"));
        titleLabel.setFont(titleLabel.getFont().deriveFont(Font.BOLD, titleLabel.getFont().getSize2D() + 5));
        titleLabel.setBorder(BorderFactory.createEmptyBorder(0, 0, 5, 0));

        // info
        JLabel infoLabel = new JLabel();
        infoLabel.setText("<html>" + StringEscapeUtils.escapeXml11(CustomerApplication.setting("i18n.info")) + "</html>");
        infoLabel.setBorder(BorderFactory.createEmptyBorder(0, 0, 10, 0));

        // status
        statusLabel = new JLabel();
        statusLabel.setBorder(BorderFactory.createEmptyBorder(5, 3, 3, 3));
        statusLabel.setVisible(false);

        // sidebar
        SidebarPanel sidebarPanel = new SidebarPanel(
                ImageUtils.loadImage(CustomerApplication.resource("sidebar_staff.png")),
                ImageUtils.loadImage(CustomerApplication.resourceBranding())
        );

        // hostname field
        hostLabel = new JLabel();
        hostLabel.setText(CustomerApplication.setting("i18n.host") + ":");
        hostField = new JTextField();
        hostField.setText(options.getHost());
        hostField.setBackground(Color.WHITE);
        hostField.getDocument().addDocumentListener(new DocumentListener() {
            @Override
            public void insertUpdate(DocumentEvent e) {
                options.setHost(hostField.getText());
            }

            @Override
            public void removeUpdate(DocumentEvent e) {
            }

            @Override
            public void changedUpdate(DocumentEvent e) {
            }
        });

        // port number field
        portLabel = new JLabel();
        portLabel.setText(CustomerApplication.setting("i18n.port") + ":");
        portField = new JSpinner(new SpinnerNumberModel(
                (int) options.getPort(), 1, 65535, 1));
        portField.setBackground(Color.WHITE);
        portField.setEditor(new JSpinner.NumberEditor(portField, "#"));
        portField.addChangeListener(e -> options.setPort((Integer) portField.getValue()));

        // screen selection field
        screenLabel = new JLabel();
        screenLabel.setText(CustomerApplication.setting("i18n.screen") + ":");
        screenField = new JComboBox<>();
        //screenField.setOpaque(true);
        screenField.setBackground(Color.WHITE);
        screenField.setLightWeightPopupEnabled(false);
        screenField.setRenderer(new DefaultListCellRenderer() {
            @Override
            public Component getListCellRendererComponent(JList<?> list, Object value, int index, boolean isSelected, boolean cellHasFocus) {
                final JLabel label = (JLabel) super.getListCellRendererComponent(list, value, index, isSelected, cellHasFocus);
                final GraphicsDevice screen = (GraphicsDevice) value;
                final GraphicsConfiguration cfg = screen.getDefaultConfiguration();
                final Rectangle bounds = cfg.getBounds();

                label.setText(screen.getIDstring() + " ("
                        + bounds.width + "x" + bounds.height + "@" + cfg.getColorModel().getPixelSize() + "bpp; "
                        + "x=" + bounds.x + "; y=" + bounds.y + ")");
                return label;
            }
        });
        String selectedScreenId = options.getScreenId();
        for (GraphicsDevice screen : GraphicsEnvironment.getLocalGraphicsEnvironment().getScreenDevices()) {
            if (screen.getType() != GraphicsDevice.TYPE_RASTER_SCREEN) continue;
            screenField.addItem(screen);
            if (selectedScreenId != null && screen.getIDstring().equalsIgnoreCase(selectedScreenId)) {
                screenField.setSelectedIndex(screenField.getItemCount() - 1);
            }
        }
        screenField.addActionListener(e -> {
            GraphicsDevice screen = (GraphicsDevice) screenField.getSelectedItem();
            options.setScreenId((screen != null) ? screen.getIDstring() : null);
        });

        // ssl encryption field
        sslField = new JCheckBox();
        sslField.setText(CustomerApplication.setting("i18n.ssl"));
        sslField.setSelected(options.isSsl());
        sslField.setOpaque(true);
        sslField.setBackground(Color.WHITE);
        sslField.addActionListener(e -> options.setSsl(sslField.isSelected()));

        // build form
        JPanel formPanel = new JPanel(new MigLayout(
                "insets 10 10 10 10",
                "[][grow][][]",
                ""
        ));
        formPanel.setOpaque(false);
        formPanel.add(titleLabel, "span 4, width 100::, grow, wrap");
        formPanel.add(infoLabel, "span 4, width 100::, grow, wrap");
        formPanel.add(hostLabel, "align right");
        formPanel.add(hostField, "width 100::, grow");
        formPanel.add(portLabel, "align right");
        formPanel.add(portField, "wrap");
        formPanel.add(screenLabel, "align right");
        formPanel.add(screenField, "span 3, width 100::, grow, wrap");
        formPanel.add(new JLabel(), "align right");
        formPanel.add(sslField, "span 3");

        // start button
        startButton = new JButton();
        startButton.setText(CustomerApplication.setting("i18n.connect"));
        startButton.addActionListener(e -> doStart());

        // stop button
        stopButton = new JButton();
        stopButton.setText(CustomerApplication.setting("i18n.disconnect"));
        stopButton.setEnabled(false);
        stopButton.addActionListener(e -> doStop());

        // about button
        JButton aboutButton = new JButton();
        aboutButton.setText(CustomerApplication.setting("i18n.about"));
        aboutButton.addActionListener(e -> doAbout());

        // quit button
        JButton quitButton = new JButton();
        quitButton.setText(CustomerApplication.setting("i18n.quit"));
        quitButton.addActionListener(e -> doQuit());

        // build bottom bar
        JPanel buttonBar = new JPanel(new FlowLayout());
        buttonBar.setOpaque(false);
        buttonBar.add(aboutButton);
        buttonBar.add(quitButton);

        JPanel buttonBarLeft = new JPanel(new FlowLayout());
        buttonBarLeft.setOpaque(false);
        buttonBarLeft.add(startButton);
        buttonBarLeft.add(stopButton);

        JPanel bottomBar = new JPanel(new BorderLayout(0, 0));
        bottomBar.setOpaque(false);
        bottomBar.add(buttonBarLeft, BorderLayout.WEST);
        bottomBar.add(buttonBar, BorderLayout.EAST);
        bottomBar.add(statusLabel, BorderLayout.SOUTH);

        // add components to the frame
        getRootPane().setLayout(new BorderLayout(0, 0));
        getRootPane().add(sidebarPanel, BorderLayout.WEST);
        getRootPane().add(formPanel, BorderLayout.CENTER);
        getRootPane().add(bottomBar, BorderLayout.SOUTH);

        // show frame
        pack();
        setLocationRelativeTo(null);
        setVisible(true);

        // update form
        setStarted(false);
        startButton.requestFocus();
    }

    protected abstract void doAbout();

    protected abstract void doQuit();

    protected abstract void doStart();

    protected abstract void doStop();

    public String getHost() {
        return hostField.getText().trim();
    }

    public Integer getPort() {
        return (Integer) portField.getValue();
    }

    public GraphicsDevice getScreen() {
        return (GraphicsDevice) screenField.getSelectedItem();
    }

    public boolean isSsl() {
        return sslField.isSelected();
    }

    public void setStarted(boolean started) {
        hostLabel.setEnabled(!started);
        hostField.setEnabled(!started);
        portLabel.setEnabled(!started);
        portField.setEnabled(!started);
        screenLabel.setEnabled(!started);
        screenField.setEnabled(!started);
        sslField.setEnabled(!started);
        startButton.setEnabled(!started);
        stopButton.setEnabled(started);

        if (started)
            requestFocus();
        else
            startButton.requestFocus();
    }

    public void setStatusConnected() {
        statusLabel.setText(CustomerApplication.setting("i18n.status.connected"));
        statusLabel.setIcon(ImageUtils.loadIcon(
                CustomerApplication.resource("icon_connected.png")));
        statusLabel.setVisible(true);
    }

    public void setStatusConnecting() {
        statusLabel.setText(CustomerApplication.setting("i18n.status.connecting"));
        statusLabel.setIcon(ImageUtils.loadIcon(
                CustomerApplication.resource("icon_connecting.png")));
        statusLabel.setVisible(true);
    }

    public void setStatusDisconnected() {
        statusLabel.setText(CustomerApplication.setting("i18n.status.disconnected"));
        statusLabel.setIcon(ImageUtils.loadIcon(
                CustomerApplication.resource("icon_disconnected.png")));
        statusLabel.setVisible(true);
    }
}
