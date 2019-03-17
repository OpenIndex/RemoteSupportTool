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
import java.awt.datatransfer.StringSelection;
import java.awt.event.KeyEvent;
import java.util.ArrayList;
import java.util.List;
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
    @SuppressWarnings("FieldCanBeLocal")
    private final int DEFAULT_DELAY = 15;
    private final List<Integer> pressedKeys = new ArrayList<>();

    public Robot(GraphicsDevice screen) throws AWTException {
        super(screen);
        setAutoDelay(DEFAULT_DELAY);
        //setAutoWaitForIdle(true);
    }

    public synchronized void copyText(String text) {
        try {
            Toolkit.getDefaultToolkit().getSystemClipboard().setContents(
                    new StringSelection(text), null);
        } catch (Exception ex) {
            LOGGER.warn("Can't copy text to clipboard!", ex);
        }
    }

    @SuppressWarnings("unused")
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

    public synchronized void printCharacter(char character) {
        printText(String.valueOf(character));
    }

    public synchronized void printText(String text) {
        //LOGGER.debug("printText \"{}\"", text);
        waitForIdle();

        // release keys, that may have been set previously
        //final List<Integer> oldPressedKeys = new ArrayList<>(pressedKeys);
        releasePressedKeys();

        //noinspection EmptyFinallyBlock
        try {
            // Try to print the text through the native API of the operating system.
            boolean textWasSent = false;
            if (SystemUtils.IS_OS_WINDOWS)
                textWasSent = WindowsUtils.sendText(text, this);
            else if (SystemUtils.IS_OS_MAC)
                textWasSent = MacUtils.sendText(text);
            else if (SystemUtils.IS_OS_LINUX)
                textWasSent = LinuxUtils.sendText(text);

            // Otherwise try to print the text through the Robot class.
            if (!textWasSent) {
                for (int i = 0; i < text.length(); i++) {
                    final char character = text.charAt(i);
                    final int code = KeyEvent.getExtendedKeyCodeForChar(character);

                    if (KeyEvent.VK_UNDEFINED != code) {
                        keyPress(code);
                        keyRelease(code);
                    } else {
                        LOGGER.warn("Can't detect key code for character \"{}\".", character);
                    }
                }
            }

        } finally {
            // reset previously pressed keys
            //releasePressedKeys();
            //for (Integer code : oldPressedKeys) {
            //    keyPress(code);
            //}
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
