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
package de.openindex.support.core.gui;

import de.openindex.support.core.AppUtils;
import de.openindex.support.core.ImageUtils;
import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.Frame;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.net.URL;
import java.util.Properties;
import java.util.ResourceBundle;
import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JEditorPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.event.HyperlinkEvent;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.SystemUtils;
import org.apache.commons.text.StringSubstitutor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * General dialog with application information.
 *
 * @author Andreas Rudolph
 */
public abstract class AboutDialog extends JDialog {
    @SuppressWarnings("unused")
    private final static Logger LOGGER = LoggerFactory.getLogger(AboutDialog.class);
    private final ResourceBundle settings;
    private final URL sidebarImageUrl;
    private final URL brandingImageUrl;

    protected AboutDialog(Frame owner, ResourceBundle settings, URL sidebarImageUrl, URL brandingImageUrl) {
        super(owner, true);
        this.settings = settings;
        this.sidebarImageUrl = sidebarImageUrl;
        this.brandingImageUrl = brandingImageUrl;
    }

    public void createAndShow() {
        // init dialog
        setTitle(settings.getString("i18n.aboutTitle"));
        setPreferredSize(new Dimension(600, 350));
        setMinimumSize(new Dimension(400, 300));
        setDefaultCloseOperation(JDialog.DO_NOTHING_ON_CLOSE);
        addWindowListener(new WindowAdapter() {
            @Override
            public void windowClosing(WindowEvent e) {
                setVisible(false);
                dispose();
            }
        });

        // sidebar
        SidebarPanel sidebarPanel = new SidebarPanel(
                ImageUtils.loadImage(this.sidebarImageUrl),
                ImageUtils.loadImage(brandingImageUrl)
        );

        // about section
        JEditorPane aboutPane = new JEditorPane();
        aboutPane.putClientProperty(JEditorPane.HONOR_DISPLAY_PROPERTIES, true);
        aboutPane.setEditable(false);
        aboutPane.setOpaque(true);
        aboutPane.setBackground(Color.WHITE);
        aboutPane.setContentType("text/html");
        aboutPane.setText(replaceVariables(getAboutText()));
        aboutPane.setCaretPosition(0);
        aboutPane.addHyperlinkListener(e -> {
            //LOGGER.debug("hyperlink / " + e.getEventType() + " / " + e.getURL());
            if (HyperlinkEvent.EventType.ACTIVATED.equals(e.getEventType()))
                AppUtils.browse(e.getURL());
        });
        JScrollPane aboutScrollPane = new JScrollPane(aboutPane);
        aboutScrollPane.setOpaque(false);
        aboutScrollPane.setBorder(BorderFactory.createEmptyBorder(0, 8, 0, 0));

        // close button
        JButton closeButton = new JButton();
        closeButton.setText(settings.getString("i18n.close"));
        closeButton.addActionListener(e -> {
            setVisible(false);
            dispose();
        });

        // website button
        JButton websiteButton = new JButton();
        websiteButton.setText(settings.getString("i18n.website"));
        websiteButton.addActionListener(e -> AppUtils.browse(this.settings.getString("website.author")));

        // github button
        JButton githubButton = new JButton();
        githubButton.setText(settings.getString("i18n.source"));
        githubButton.addActionListener(e -> AppUtils.browse(this.settings.getString("website.source")));

        // build bottom bar
        JPanel buttonBarLeft = new JPanel(new FlowLayout());
        buttonBarLeft.setOpaque(false);
        buttonBarLeft.add(websiteButton);
        buttonBarLeft.add(githubButton);

        JPanel buttonBarRight = new JPanel(new FlowLayout());
        buttonBarRight.setOpaque(false);
        buttonBarRight.add(closeButton);

        JPanel bottomBar = new JPanel(new BorderLayout());
        bottomBar.setOpaque(false);
        bottomBar.add(buttonBarLeft, BorderLayout.WEST);
        bottomBar.add(buttonBarRight, BorderLayout.EAST);

        // add components to the dialog
        getRootPane().setOpaque(true);
        getRootPane().setBackground(Color.WHITE);
        getRootPane().setLayout(new BorderLayout());
        getRootPane().add(sidebarPanel, BorderLayout.WEST);
        getRootPane().add(aboutScrollPane, BorderLayout.CENTER);
        getRootPane().add(bottomBar, BorderLayout.SOUTH);

        // show dialog
        pack();
        setLocationRelativeTo(this.getOwner());
        setVisible(true);
    }

    protected abstract String getAboutText();

    private String replaceVariables(String text) {
        Properties replacements = new Properties();

        replacements.setProperty("app.title", settings.getString("title"));
        replacements.setProperty("app.version", settings.getString("version"));
        replacements.setProperty("openjdk.name", StringUtils.defaultIfBlank(
                SystemUtils.JAVA_RUNTIME_NAME, SystemUtils.JAVA_VM_NAME));
        replacements.setProperty("openjdk.version", StringUtils.defaultIfBlank(
                SystemUtils.JAVA_RUNTIME_VERSION, SystemUtils.JAVA_VERSION));
        return StringSubstitutor.replace(text, replacements);
    }
}
