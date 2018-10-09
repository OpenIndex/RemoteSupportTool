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
package de.openindex.support.core;

import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import javax.swing.JPanel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SidebarPanel extends JPanel {
    @SuppressWarnings("unused")
    private final static Logger LOGGER = LoggerFactory.getLogger(SidebarPanel.class);

    private final BufferedImage sidebarImage;
    private final BufferedImage brandingImage;

    public SidebarPanel(BufferedImage sidebarImage, BufferedImage brandingImage) {
        super();
        this.sidebarImage = sidebarImage;
        this.brandingImage = brandingImage;
        this.setOpaque(false);
    }

    @Override
    public Dimension getPreferredSize() {
        return new Dimension(sidebarImage.getWidth(), sidebarImage.getHeight());
    }

    @Override
    protected void paintComponent(Graphics g) {
        super.paintComponent(g);

        final int panelWidth = getWidth();
        final int panelHeight = getHeight();
        final Graphics2D g2d = (Graphics2D) g;

        g2d.drawImage(sidebarImage, 0, 0, null);

        if (brandingImage != null) {
            final int brandingWidth = brandingImage.getWidth();
            final int brandingHeight = brandingImage.getHeight();

            final int x = (panelWidth - brandingWidth) / 2;
            final int y = panelHeight - brandingHeight;
            g2d.drawImage(brandingImage, x, y, null);
        }

        g2d.dispose();
    }
}
