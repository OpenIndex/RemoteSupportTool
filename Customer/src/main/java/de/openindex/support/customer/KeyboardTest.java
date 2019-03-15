package de.openindex.support.customer;

import de.openindex.support.customer.utils.LinuxUtils;
import de.openindex.support.customer.utils.MacUtils;
import de.openindex.support.customer.utils.WindowsUtils;
import java.awt.GraphicsDevice;
import java.awt.GraphicsEnvironment;
import java.awt.Robot;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.SystemUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class KeyboardTest {
    private final static Logger LOGGER = LoggerFactory.getLogger(KeyboardTest.class);

    public static void main(String[] args) {

        final StringBuilder text = new StringBuilder();
        for (String arg : args) {
            text.append(arg).append(StringUtils.SPACE);
        }
        String txt = text.toString().trim();
        if (StringUtils.isBlank(txt))
            txt = "test123 - äöüß / ÄÖÜ @€ \\";

        try {
            if (SystemUtils.IS_OS_WINDOWS) {
                LOGGER.debug("Send text on Windows...");
                GraphicsDevice device = GraphicsEnvironment.getLocalGraphicsEnvironment().getScreenDevices()[0];
                Robot robot = new Robot(device);
                WindowsUtils.sendText(txt, robot);
            } else if (SystemUtils.IS_OS_LINUX) {
                LOGGER.debug("Send text on Linux...");
                LinuxUtils.sendText(txt);
            } else if (SystemUtils.IS_OS_MAC) {
                LOGGER.debug("Send text on macOS...");
                MacUtils.sendText(txt);
            } else {
                throw new UnsupportedOperationException("Operating system is not supported.");
            }
        } catch (Exception ex) {
            LOGGER.error("Can't send text!", ex);
        }
    }
}
