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
package de.openindex.support.staff.utils;

import de.openindex.support.staff.StaffApplication;
import de.openindex.support.staff.StaffFrame;
import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.event.ComponentAdapter;
import java.awt.event.ComponentEvent;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSeparator;
import javax.swing.JTextArea;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Dialog for pasting text to the remote machine.
 *
 * @author Andreas Rudolph
 */
public abstract class PasteTextDialog extends JDialog {
    @SuppressWarnings("unused")
    private final static Logger LOGGER = LoggerFactory.getLogger(PasteTextDialog.class);
    private JTextArea textField;

    public PasteTextDialog(StaffFrame frame) {
        super(frame);
        setModal(false);
        //setAlwaysOnTop(false);
    }

    public void createAndShow() {
        setTitle(StaffApplication.setting("i18n.pasteTextTitle"));
        setPreferredSize(new Dimension(350, 200));
        setMinimumSize(new Dimension(300, 150));
        setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);
        addWindowListener(new WindowAdapter() {
            @Override
            public void windowClosing(WindowEvent e) {
                setVisible(false);
            }
        });
        getRootPane().setBackground(Color.WHITE);
        getRootPane().setOpaque(true);

        // text field
        textField = new JTextArea();
        textField.setLineWrap(true);
        textField.setWrapStyleWord(true);
        textField.setBorder(BorderFactory.createEmptyBorder(5, 5, 5, 5));
        JScrollPane textScrollPane = new JScrollPane(textField);
        textScrollPane.setBorder(BorderFactory.createEmptyBorder());
        textScrollPane.addComponentListener(new ComponentAdapter() {
            @Override
            public void componentResized(ComponentEvent e) {
                Dimension size = ((JScrollPane) e.getComponent()).getViewport().getSize();
                textField.setBounds(0, 0, size.width, size.height);
            }
        });

        // submit button
        JButton submitButton = new JButton();
        submitButton.setText(StaffApplication.setting("i18n.pasteText"));
        submitButton.addActionListener(e -> {
            String text = StringUtils.trimToNull(textField.getText());
            if (text != null) doSubmit(text);
        });

        // close button
        JButton closeButton = new JButton();
        closeButton.setText(StaffApplication.setting("i18n.close"));
        closeButton.addActionListener(e -> setVisible(false));

        // build button bar
        JPanel buttonBar = new JPanel(new FlowLayout(FlowLayout.CENTER));
        buttonBar.setOpaque(false);
        buttonBar.add(submitButton);
        buttonBar.add(closeButton);

        // build bottom bar
        JPanel bottomBar = new JPanel(new BorderLayout());
        bottomBar.setOpaque(false);
        bottomBar.add(new JSeparator(), BorderLayout.NORTH);
        bottomBar.add(buttonBar, BorderLayout.CENTER);

        // add components to the frame
        getRootPane().setLayout(new BorderLayout(10, 10));
        getRootPane().add(textScrollPane, BorderLayout.CENTER);
        getRootPane().add(bottomBar, BorderLayout.SOUTH);

        // show dialog
        pack();
        setLocationRelativeTo(null);
        setVisible(true);

        // update form
        textField.setText(StaffApplication.setting("i18n.pasteTextDefault"));
        textField.requestFocus();
        textField.selectAll();
    }

    protected abstract void doSubmit(String text);
}
