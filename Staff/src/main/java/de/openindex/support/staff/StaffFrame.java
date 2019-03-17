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
package de.openindex.support.staff;

import de.openindex.support.core.AppUtils;
import de.openindex.support.core.ImageUtils;
import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.event.ActionEvent;
import java.awt.event.ComponentAdapter;
import java.awt.event.ComponentEvent;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.event.MouseMotionAdapter;
import java.awt.event.MouseWheelEvent;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.awt.image.BufferedImage;
import java.io.File;
import java.util.List;
import javax.swing.AbstractAction;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JPopupMenu;
import javax.swing.JSeparator;
import javax.swing.JSpinner;
import javax.swing.JTextField;
import javax.swing.JToggleButton;
import javax.swing.SpinnerNumberModel;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;
import net.miginfocom.swing.MigLayout;
import org.apache.commons.lang3.ObjectUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.SystemUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Main frame of the staff application.
 *
 * @author Andreas Rudolph
 */
@SuppressWarnings("WeakerAccess")
public abstract class StaffFrame extends JFrame {
    @SuppressWarnings("unused")
    private final static Logger LOGGER = LoggerFactory.getLogger(StaffFrame.class);
    private final StaffOptions options;
    private boolean started = false;
    private ScreenPanel screenView = null;
    private JButton startButton = null;
    private JButton stopButton = null;
    private JButton actionsButton = null;
    private JPopupMenu actionsMenu = null;
    private JToggleButton optionsButton = null;
    private JPanel optionsPanel = null;
    private JLabel infoLabel = null;
    private JLabel downloadLabel = null;
    private JLabel uploadLabel = null;
    private JSpinner localPortField = null;
    private JCheckBox sslField = null;
    private JCheckBox sshField = null;
    private JLabel sshHostLabel = null;
    private JTextField sshHostField = null;
    private JLabel sshPortLabel = null;
    private JSpinner sshPortField = null;
    private JLabel sshRemotePortLabel = null;
    private JSpinner sshRemotePortField = null;
    private JLabel sshUserLabel = null;
    private JTextField sshUserField = null;
    private JLabel sshKeyLabel = null;
    private JTextField sshKeyField = null;
    private JButton sshKeyButton = null;
    private JCheckBox sshKeyAuthField = null;
    private PasteTextDialog pasteTextDialog = null;

    public StaffFrame(StaffOptions options) {
        super();
        this.options = options;
    }

    public void createAndShow() {
        final BufferedImage applicationImage = ImageUtils.loadImage(
                StaffApplication.resource("application.png"));

        // init frame
        setTitle(StaffApplication.setting("i18n.appTitle"));
        setIconImage(applicationImage);
        setPreferredSize(new Dimension(600, 400));
        setMinimumSize(new Dimension(500, 300));
        setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);
        addWindowListener(new WindowAdapter() {
            @Override
            public void windowClosing(WindowEvent e) {
                doQuit();
            }
        });

        // screen view
        screenView = new ScreenPanel(ObjectUtils.defaultIfNull(
                ImageUtils.loadImage(StaffApplication.resource("startup.png")),
                applicationImage));
        screenView.setFocusTraversalKeysEnabled(false);
        screenView.addKeyListener(new KeyAdapter() {
            @Override
            public void keyPressed(KeyEvent e) {
                doHandleKeyPress(e);
            }

            @Override
            public void keyReleased(KeyEvent e) {
                doHandleKeyRelease(e);
            }
        });
        screenView.addMouseListener(new MouseAdapter() {
            @Override
            public void mouseEntered(MouseEvent e) {
                if (!started) return;
                screenView.requestFocus();
            }

            @Override
            public void mousePressed(MouseEvent e) {
                doHandleMousePress(e);
            }

            @Override
            public void mouseReleased(MouseEvent e) {
                doHandleMouseRelease(e);
            }
        });
        screenView.addMouseMotionListener(new MouseMotionAdapter() {
            @Override
            public void mouseMoved(MouseEvent e) {
                doHandleMouseMotion(e);
            }

            @Override
            public void mouseDragged(MouseEvent e) {
                doHandleMouseMotion(e);
            }
        });
        screenView.addMouseWheelListener(this::doHandleMouseWheel);
        screenView.addComponentListener(new ComponentAdapter() {

            @Override
            public void componentResized(ComponentEvent e) {
                doResize();
            }
        });

        // info label
        infoLabel = new JLabel();
        infoLabel.setVisible(false);
        infoLabel.setIcon(ImageUtils.loadIcon(StaffApplication.resource("icon_info.png")));

        // upload label
        uploadLabel = new JLabel();
        uploadLabel.setVisible(false);
        uploadLabel.setIcon(ImageUtils.loadIcon(StaffApplication.resource("icon_upload.png")));

        // download label
        downloadLabel = new JLabel();
        downloadLabel.setVisible(false);
        downloadLabel.setIcon(ImageUtils.loadIcon(StaffApplication.resource("icon_download.png")));

        // port number field
        JLabel localPortLabel = new JLabel();
        localPortLabel.setText(StaffApplication.setting("i18n.port") + ":");
        localPortField = new JSpinner(new SpinnerNumberModel(
                (int) options.getLocalPort(), 1, 65535, 1));
        localPortField.setBackground(Color.WHITE);
        localPortField.addChangeListener(e -> options.setLocalPort((Integer) localPortField.getValue()));

        // ssl encryption field
        sslField = new JCheckBox();
        sslField.setText(StaffApplication.setting("i18n.sslEncryption"));
        sslField.setSelected(options.isSsl());
        sslField.setOpaque(true);
        sslField.setBackground(Color.WHITE);
        sslField.addActionListener(e -> options.setSsl(sslField.isSelected()));

        // ssh tunnel field
        sshField = new JCheckBox();
        sshField.setText(StaffApplication.setting("i18n.sshTunneling"));
        sshField.setSelected(options.isSsh());
        sshField.setOpaque(true);
        sshField.setBackground(Color.WHITE);
        sshField.addActionListener(e -> {
            options.setSsh(sshField.isSelected());
            setSshTunnel(sshField.isSelected());
        });

        // ssh host
        sshHostLabel = new JLabel();
        sshHostLabel.setText(StaffApplication.setting("i18n.sshHost") + ":");
        sshHostField = new JTextField();
        sshHostField.setText(options.getSshHost());
        sshHostField.setBackground(Color.WHITE);
        sshHostField.getDocument().addDocumentListener(new DocumentListener() {
            @Override
            public void insertUpdate(DocumentEvent e) {
                options.setSshHost(sshHostField.getText());
            }

            @Override
            public void removeUpdate(DocumentEvent e) {
            }

            @Override
            public void changedUpdate(DocumentEvent e) {
            }
        });

        // ssh port
        sshPortLabel = new JLabel();
        sshPortLabel.setText(StaffApplication.setting("i18n.sshPort") + ":");
        sshPortField = new JSpinner(new SpinnerNumberModel(
                (int) options.getSshPort(), 1, 65535, 1));
        sshPortField.setBackground(Color.WHITE);
        sshPortField.addChangeListener(e -> options.setSshPort((Integer) sshPortField.getValue()));

        // ssh remote port
        sshRemotePortLabel = new JLabel();
        sshRemotePortLabel.setText(StaffApplication.setting("i18n.sshRemotePort") + ":");
        sshRemotePortField = new JSpinner(new SpinnerNumberModel(
                (int) options.getSshRemotePort(), 1, 65535, 1));
        sshRemotePortField.setBackground(Color.WHITE);
        sshRemotePortField.addChangeListener(e -> options.setSshRemotePort((Integer) sshRemotePortField.getValue()));

        // ssh user
        sshUserLabel = new JLabel();
        sshUserLabel.setText(StaffApplication.setting("i18n.sshUser") + ":");
        sshUserField = new JTextField();
        sshUserField.setText(options.getSshUser());
        sshUserField.setBackground(Color.WHITE);
        sshUserField.getDocument().addDocumentListener(new DocumentListener() {
            @Override
            public void insertUpdate(DocumentEvent e) {
                options.setSshUser(sshUserField.getText());
            }

            @Override
            public void removeUpdate(DocumentEvent e) {
            }

            @Override
            public void changedUpdate(DocumentEvent e) {
            }
        });

        // ssh key
        sshKeyLabel = new JLabel();
        sshKeyLabel.setText(StaffApplication.setting("i18n.sshKey") + ":");
        sshKeyField = new JTextField();
        sshKeyField.setText(options.getSshKey());
        sshKeyField.setBackground(Color.WHITE);
        sshKeyField.setEditable(false);
        sshKeyButton = new JButton();
        sshKeyButton.setText("Select");
        sshKeyButton.addActionListener(e -> {
            JFileChooser ch = new JFileChooser();
            ch.setDialogTitle(StaffApplication.setting("i18n.sshKeySelect"));

            File f = null;
            if (StringUtils.isNotBlank(sshKeyField.getText())) {
                f = new File(sshKeyField.getText());
                if (!f.isFile()) f = null;
            }
            if (f != null) {
                ch.setSelectedFile(f);
            } else {
                f = new File(SystemUtils.getUserHome(), ".ssh");
                ch.setCurrentDirectory((f.isFile()) ? f : SystemUtils.getUserHome());
            }

            if (ch.showOpenDialog(StaffFrame.this) != JFileChooser.APPROVE_OPTION) return;
            sshKeyField.setText(ch.getSelectedFile().getAbsolutePath());
            options.setSshKey(sshKeyField.getText());
        });
        JPanel sshKeyFieldPanel = new JPanel(new MigLayout("fillx, insets 0", "[grow][]"));
        sshKeyFieldPanel.setOpaque(false);
        sshKeyFieldPanel.add(sshKeyField, "growx");
        sshKeyFieldPanel.add(sshKeyButton);

        // ssh public key authentication
        sshKeyAuthField = new JCheckBox();
        sshKeyAuthField.setText(StaffApplication.setting("i18n.sshKeyAuth"));
        sshKeyAuthField.setSelected(options.isSshKeyAuth());
        sshKeyAuthField.setOpaque(true);
        sshKeyAuthField.setBackground(Color.WHITE);
        sshKeyAuthField.addActionListener(e -> {
            options.setSshKeyAuth(sshKeyAuthField.isSelected());
            setSshTunnel(sshField.isSelected());
        });

        // options panel
        JPanel basicOptionsPanel = new JPanel(new MigLayout("insets 0"));
        basicOptionsPanel.setOpaque(false);
        basicOptionsPanel.add(localPortField);
        basicOptionsPanel.add(sslField);
        basicOptionsPanel.add(sshField);

        optionsPanel = new JPanel(new MigLayout(
                "fillx",
                "[][grow][][]",
                ""
        ));
        optionsPanel.setOpaque(false);
        optionsPanel.setVisible(false);
        optionsPanel.add(new JSeparator(), "span 4, growx, wrap");
        optionsPanel.add(localPortLabel, "align right");
        optionsPanel.add(basicOptionsPanel, "span 3, wrap");
        optionsPanel.add(sshHostLabel, "align right");
        optionsPanel.add(sshHostField, "growx");
        optionsPanel.add(sshPortLabel, "align right");
        optionsPanel.add(sshPortField, "growx, wrap");
        optionsPanel.add(sshUserLabel, "align right, grow 0");
        optionsPanel.add(sshUserField, "growx");
        optionsPanel.add(sshRemotePortLabel, "align right");
        optionsPanel.add(sshRemotePortField, "growx, wrap");
        optionsPanel.add(sshKeyLabel, "align right, grow 0");
        optionsPanel.add(sshKeyFieldPanel, "span 4, growx, wrap");
        optionsPanel.add(new JLabel());
        optionsPanel.add(sshKeyAuthField, "span 4, growx");

        // start button
        startButton = new JButton();
        startButton.setText(StaffApplication.setting("i18n.start"));
        startButton.addActionListener(e -> doStart());

        // stop button
        stopButton = new JButton();
        stopButton.setText(StaffApplication.setting("i18n.stop"));
        stopButton.setEnabled(false);
        stopButton.addActionListener(e -> doStop());

        // options button
        optionsButton = new JToggleButton();
        optionsButton.setText(StaffApplication.setting("i18n.options"));
        optionsButton.addActionListener(e -> optionsPanel.setVisible(optionsButton.isSelected()));

        // actions button
        actionsButton = new JButton();
        actionsButton.setText(StaffApplication.setting("i18n.actions"));
        actionsButton.addActionListener(e -> actionsMenu.show(actionsButton, 0, actionsButton.getHeight()));
        actionsMenu = new JPopupMenu();
        actionsMenu.add(new AbstractAction(StaffApplication.setting("i18n.pasteText")) {
            @Override
            public void actionPerformed(ActionEvent e) {
                if (pasteTextDialog == null) {
                    pasteTextDialog = new PasteTextDialog();
                    pasteTextDialog.createAndShow();
                } else {
                    if (!pasteTextDialog.isVisible()) {
                        pasteTextDialog.setLocationRelativeTo(StaffFrame.this);
                        pasteTextDialog.setVisible(true);
                    }
                    pasteTextDialog.toFront();
                }
            }
        });

        // about button
        JButton aboutButton = new JButton();
        aboutButton.setText(StaffApplication.setting("i18n.about"));
        aboutButton.addActionListener(e -> doAbout());

        // quit button
        JButton quitButton = new JButton();
        quitButton.setText(StaffApplication.setting("i18n.quit"));
        quitButton.addActionListener(e -> doQuit());

        // build bottom bar
        JPanel buttonBar = new JPanel(new FlowLayout());
        buttonBar.setOpaque(false);
        buttonBar.add(startButton);
        buttonBar.add(stopButton);
        buttonBar.add(optionsButton);
        buttonBar.add(actionsButton);
        buttonBar.add(aboutButton);
        buttonBar.add(quitButton);

        JPanel statusBar = new JPanel(new MigLayout("insets 0, aligny 50%, hidemode 3"));
        statusBar.setOpaque(false);
        statusBar.add(infoLabel);
        statusBar.add(downloadLabel);
        statusBar.add(uploadLabel);

        JPanel bottomBar = new JPanel(new BorderLayout(0, 0));
        bottomBar.setOpaque(true);
        bottomBar.setBackground(Color.WHITE);
        bottomBar.add(buttonBar, BorderLayout.EAST);
        bottomBar.add(statusBar, BorderLayout.CENTER);
        bottomBar.add(optionsPanel, BorderLayout.SOUTH);

        // add components to the frame
        getRootPane().setLayout(new BorderLayout());
        getRootPane().add(screenView, BorderLayout.CENTER);
        getRootPane().add(bottomBar, BorderLayout.SOUTH);

        // show frame
        pack();
        setLocationRelativeTo(null);
        setVisible(true);

        // update form
        setStarted(false);
        setSshTunnel(sshField.isSelected());
        startButton.requestFocus();
    }

    protected abstract void doAbout();

    protected abstract void doHandleKeyPress(KeyEvent e);

    protected abstract void doHandleKeyRelease(KeyEvent e);

    protected abstract void doHandleMouseMotion(MouseEvent e);

    protected abstract void doHandleMousePress(MouseEvent e);

    protected abstract void doHandleMouseRelease(MouseEvent e);

    protected abstract void doHandleMouseWheel(MouseWheelEvent e);

    protected abstract void doPasteText(String text);

    protected abstract void doQuit();

    protected abstract void doResize();

    protected abstract void doStart();

    protected abstract void doStop();

    public Integer getLocalPort() {
        return (Integer) localPortField.getValue();
    }

    public int getScreenHeight() {
        return screenView.getHeight();
    }

    public int getScreenImageHeight() {
        return screenView.getImageHeight();
    }

    public int getScreenImageWidth() {
        return screenView.getImageWidth();
    }

    public int getScreenWidth() {
        return screenView.getWidth();
    }

    public String getSshHost() {
        return sshHostField.getText().trim();
    }

    public File getSshKey() {
        String key = StringUtils.trimToNull(sshKeyField.getText());
        if (key == null) return null;
        File f = new File(key);
        return (f.isFile()) ? f : null;
    }

    public Integer getSshPort() {
        return (Integer) sshPortField.getValue();
    }

    public Integer getSshRemotePort() {
        return (Integer) sshRemotePortField.getValue();
    }

    public String getSshUser() {
        return sshUserField.getText().trim();
    }

    public boolean isSsh() {
        return sshField.isSelected();
    }

    public boolean isSshKeyAuth() {
        return sshKeyAuthField.isSelected();
    }

    public boolean isSsl() {
        return sslField.isSelected();
    }

    public void setConnected(boolean connected) {
        actionsButton.setEnabled(connected);
        actionsButton.setVisible(connected);
    }

    public void setInfo(String txt) {
        infoLabel.setText(txt);
        uploadLabel.setVisible(false);
        downloadLabel.setVisible(false);
        infoLabel.setVisible(true);
    }

    public void setRates(float download, float upload) {
        long downloadRate = (long) download;
        long uploadRate = (long) upload;

        downloadLabel.setText(AppUtils.getHumanReadableByteCount(downloadRate) + "/s");
        uploadLabel.setText(AppUtils.getHumanReadableByteCount(uploadRate) + "/s");

        infoLabel.setVisible(false);
        downloadLabel.setVisible(true);
        uploadLabel.setVisible(true);
    }

    public void setScreenDisabled() {
        screenView.setDisabled();
        screenView.repaint();
    }

    private void setSshTunnel(boolean enabled) {
        sshHostLabel.setEnabled(enabled);
        sshHostField.setEnabled(enabled);
        sshPortLabel.setEnabled(enabled);
        sshPortField.setEnabled(enabled);
        sshRemotePortLabel.setEnabled(enabled);
        sshRemotePortField.setEnabled(enabled);
        sshUserLabel.setEnabled(enabled);
        sshUserField.setEnabled(enabled);
        sshKeyLabel.setEnabled(enabled);
        sshKeyField.setEnabled(enabled && sshKeyAuthField.isSelected());
        sshKeyButton.setEnabled(enabled && sshKeyAuthField.isSelected());
        sshKeyAuthField.setEnabled(enabled);
    }

    public void setStarted(boolean started) {
        this.started = started;
        startButton.setEnabled(!started);
        startButton.setVisible(!started);
        stopButton.setEnabled(started);
        stopButton.setVisible(started);
        actionsButton.setEnabled(false);
        actionsButton.setVisible(false);
        optionsButton.setEnabled(!started);
        optionsButton.setSelected(false);
        optionsButton.setVisible(!started);
        optionsPanel.setVisible(false);
        infoLabel.setText(StringUtils.EMPTY);
        infoLabel.setVisible(false);
        downloadLabel.setText(StringUtils.EMPTY);
        downloadLabel.setVisible(false);
        uploadLabel.setText(StringUtils.EMPTY);
        uploadLabel.setVisible(false);

        if (pasteTextDialog != null) {
            pasteTextDialog.setVisible(false);
        }
    }

    public void updateScreen(List<BufferedImage> slices, int imageWidth, int imageHeight, int sliceWidth, int sliceHeight) {
        screenView.setSlices(slices, imageWidth, imageHeight, sliceWidth, sliceHeight);
        screenView.repaint();
    }

    private static class ScreenPanel extends JPanel {
        private final BufferedImage emptyImage;
        private BufferedImage image = null;
        private boolean disabled = false;

        private ScreenPanel(BufferedImage emptyImage) {
            super();
            this.emptyImage = emptyImage;
        }

        private int getImageHeight() {
            return (this.image != null) ? this.image.getHeight() : 0;
        }

        private int getImageWidth() {
            return (this.image != null) ? this.image.getWidth() : 0;
        }

        private synchronized void setDisabled() {
            if (image != null) {
                image = ImageUtils.toGrayScale(image);
            }
            disabled = true;
        }

        private synchronized void setSlices(List<BufferedImage> slices, int imageWidth, int imageHeight, int sliceWidth, int sliceHeight) {
            //LOGGER.debug("draw " + slices.size() + " slices");
            if (image == null || image.getWidth() != imageWidth || image.getHeight() != imageHeight || disabled) {
                disabled = false;
                image = new BufferedImage(
                        imageWidth,
                        imageHeight,
                        BufferedImage.TYPE_INT_RGB
                );
            }

            int x = 0;
            int y = 0;
            Graphics2D g = image.createGraphics();
            for (BufferedImage slice : slices) {
                if (slice != null) {
                    //LOGGER.debug("draw slice at " + x + " / " + y);
                    g.drawImage(slice, x, y, null);
                }

                if ((x + sliceWidth) < imageWidth) {
                    x += sliceWidth;
                } else {
                    x = 0;
                    y += sliceHeight;
                }
            }
            g.dispose();
        }

        @Override
        protected void paintComponent(Graphics g) {
            super.paintComponent(g);

            final int panelWidth = getWidth();
            final int panelHeight = getHeight();
            final Graphics2D g2d = (Graphics2D) g;

            try {
                g2d.setColor(Color.BLACK);
                g2d.fillRect(0, 0, panelWidth, panelHeight);

                final Image img = (this.image != null) ?
                        this.image : this.emptyImage;

                if (img == null) return;

                final int imgWidth = img.getWidth(null);
                final int imgHeight = img.getHeight(null);
                final int x = (int) ((double) (panelWidth - imgWidth) / 2d);
                final int y = (int) ((double) (panelHeight - imgHeight) / 2d);

                g2d.drawImage(img, x, y, null);
            } finally {
                g2d.dispose();
            }
        }
    }

    private class PasteTextDialog extends de.openindex.support.staff.utils.PasteTextDialog {
        private PasteTextDialog() {
            super(StaffFrame.this);
        }

        @Override
        protected void doSubmit(String text) {
            doPasteText(text);
        }
    }
}
