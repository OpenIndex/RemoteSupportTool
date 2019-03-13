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
package de.openindex.support.customer.utils;

import java.awt.AWTException;
import java.awt.GraphicsDevice;
import java.awt.Toolkit;
import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.StringSelection;
import java.awt.event.KeyEvent;
import java.util.ArrayList;
import java.util.List;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.SystemUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Extended robot for remote control.
 *
 * @author Andreas Rudolph
 */
@SuppressWarnings("WeakerAccess")
public class Robot extends java.awt.Robot {
    private final static Logger LOGGER = LoggerFactory.getLogger(Robot.class);
    private final int DEFAULT_DELAY = 15;
    private final List<Integer> pressedKeys = new ArrayList<>();

    public Robot(GraphicsDevice screen) throws AWTException {
        super(screen);
        setAutoDelay(DEFAULT_DELAY);
        //setAutoWaitForIdle(true);
    }

    public synchronized boolean isPressed(int code) {
        return pressedKeys.contains(code);
    }

    @Override
    public synchronized void keyPress(int code) {
        super.keyPress(code);
        if (!pressedKeys.contains(code))
            pressedKeys.add(code);
    }

    @Override
    public synchronized void keyRelease(int code) {
        super.keyRelease(code);
        pressedKeys.remove((Integer) code);
    }

    @Override
    public synchronized void mousePress(int buttons) {
        super.mousePress(buttons);
        //waitForIdle();
    }

    @Override
    public synchronized void mouseRelease(int buttons) {
        super.mouseRelease(buttons);
        //waitForIdle();
    }

    public synchronized void pasteText(String text) {
        final Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();

        String oldClipboardValue = StringUtils.EMPTY;
        //String oldClipboardValue;
        //try {
        //    oldClipboardValue = (String) clipboard.getData(DataFlavor.stringFlavor);
        //} catch (Exception ex) {
        //    oldClipboardValue = StringUtils.EMPTY;
        //}

        try {
            clipboard.setContents(new StringSelection(text), null);
            waitForIdle();
            setAutoDelay(50);

            if (SystemUtils.IS_OS_MAC_OSX)
                keyPress(KeyEvent.VK_META);
            else
                keyPress(KeyEvent.VK_CONTROL);

            keyPress(KeyEvent.VK_V);
            keyRelease(KeyEvent.VK_V);

            if (SystemUtils.IS_OS_MAC_OSX)
                keyRelease(KeyEvent.VK_META);
            else
                keyRelease(KeyEvent.VK_CONTROL);
        } catch (Exception ex) {
            LOGGER.warn("Can't paste text!", ex);
        } finally {
            try {
                clipboard.setContents(new StringSelection(oldClipboardValue), null);
            } catch (Exception ex) {
                LOGGER.warn("Can't clear clipboard!", ex);
            }
            setAutoDelay(DEFAULT_DELAY);
        }
    }

    public synchronized void printCharacter(char character) {
        //LOGGER.debug("printCharacter: " + character);
        waitForIdle();

        // release keys, that may have been set previously
        List<Integer> oldPressedKeys = new ArrayList<>(pressedKeys);
        releasePressedKeys();

        if (SystemUtils.IS_OS_WINDOWS) {
            // print character on Windows systems by typing ALT + unicode number
            keyPress(KeyEvent.VK_ALT);
            keyPress(KeyEvent.VK_NUMPAD0);
            keyRelease(KeyEvent.VK_NUMPAD0);
            String altCode = Integer.toString(character);
            for (int i = 0; i < altCode.length(); i++) {
                char code = (char) (altCode.charAt(i) + '0');
                keyPress(code);
                keyRelease(code);
            }
            keyRelease(KeyEvent.VK_ALT);
        } else {
            // paste the character through the system clipboard
            pasteText(String.valueOf(character));
        }

        // reset pressed keys
        releasePressedKeys();
        for (Integer code : oldPressedKeys) {
            keyPress(code);
        }
    }

    public synchronized void releasePressedKeys() {
        for (Integer code : pressedKeys) {
            try {
                super.keyRelease(code);
            } catch (Exception ex) {
                LOGGER.warn("Can't release previously pressed key (" + code + ")!", ex);
            }
        }
        pressedKeys.clear();
    }
}
