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

import java.awt.Toolkit;
import java.lang.reflect.Field;
import javax.swing.UIManager;
import org.apache.commons.lang3.SystemUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Swing helper methods.
 *
 * @author Andreas Rudolph
 */
@SuppressWarnings("WeakerAccess")
public class SwingUtils {
    @SuppressWarnings("unused")
    private final static Logger LOGGER = LoggerFactory.getLogger(SwingUtils.class);

    private SwingUtils() {
        super();
    }

    public static UIManager.LookAndFeelInfo getLookAndFeelInfo(String name) {
        for (UIManager.LookAndFeelInfo lnf : UIManager.getInstalledLookAndFeels()) {
            if (lnf.getName().equalsIgnoreCase(name)) {
                return lnf;
            }
        }
        return null;
    }

    public static void installLookAndFeel() {
        try {
            if (SystemUtils.IS_OS_WINDOWS || SystemUtils.IS_OS_MAC) {
                // Always use system look & feel on Windows & Mac.
                UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
            } else {
                // Prefer Nimbus or Metal look & feel on other systems.
                UIManager.LookAndFeelInfo lnf = SwingUtils.getLookAndFeelInfo("Nimbus");
                if (lnf == null) lnf = SwingUtils.getLookAndFeelInfo("Metal");
                UIManager.setLookAndFeel((lnf != null) ?
                        lnf.getClassName() :
                        UIManager.getSystemLookAndFeelClassName());
            }
        } catch (Exception ex) {
            LOGGER.warn("Can't set look & feel!", ex);
        }
    }

    /**
     * Change application title for certain Linux desktop environments (e.g. Gnome 3, Ubuntu Unity).
     * <p>
     * This method may not work with future Java version. In this case it might be replaced with the
     * <a href="https://github.com/jelmerk/window-matching-agent">window-matching-agent</a> approach.
     *
     * @param value application title to set
     * @see <a href="https://stackoverflow.com/a/29218320">stackoverflow.com</a>
     */
    public static void setAwtAppClassName(String value) {
        try {
            Toolkit toolkit = Toolkit.getDefaultToolkit();
            if (toolkit.getClass().getName().equals("sun.awt.X11.XToolkit")) {
                Field awtAppClassNameField = toolkit.getClass().getDeclaredField("awtAppClassName");
                awtAppClassNameField.setAccessible(true);
                awtAppClassNameField.set(toolkit, value);
            }
        } catch (Exception ex) {
            LOGGER.warn("Can't set awtAppClassName!", ex);
        }
    }
}
