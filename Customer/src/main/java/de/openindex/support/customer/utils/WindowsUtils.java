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

import com.sun.jna.Native;
import com.sun.jna.platform.win32.BaseTSD;
import com.sun.jna.platform.win32.Kernel32Util;
import com.sun.jna.platform.win32.User32;
import com.sun.jna.platform.win32.WinDef;
import com.sun.jna.platform.win32.WinUser;
import java.awt.event.KeyEvent;
import java.util.ArrayList;
import java.util.List;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Windows specific functions.
 *
 * @author Andreas Rudolph
 */
public class WindowsUtils {
    @SuppressWarnings("unused")
    private final static Logger LOGGER = LoggerFactory.getLogger(WindowsUtils.class);
    private final static User32 USER32 = loadUser32();

    /**
     * Create keyboard input event.
     *
     * @param character character to print
     * @param flags     flags
     * @return keyboard input event
     */
    private static WinUser.INPUT createKeyboardInput(char character, long flags) {
        WinUser.INPUT input = new WinUser.INPUT();
        input.type = new WinDef.DWORD(WinUser.INPUT.INPUT_KEYBOARD);
        input.input.setType("ki");
        input.input.ki = new WinUser.KEYBDINPUT();
        input.input.ki.wVk = new WinDef.WORD(0);
        input.input.ki.wScan = new WinDef.WORD(character);
        input.input.ki.time = new WinDef.DWORD(0);
        input.input.ki.dwFlags = new WinDef.DWORD(flags);
        input.input.ki.dwExtraInfo = new BaseTSD.ULONG_PTR();
        return input;
    }

    /**
     * Load user32 library.
     *
     * @return JNA interface of the user32 library
     */
    private static User32 loadUser32() {
        try {
            LOGGER.debug("Load user32 library.");
            return Native.load(User32.class);
            //return Native.load(User32.class, W32APIOptions.DEFAULT_OPTIONS);
            //return Native.load(User32.class, W32APIOptions.UNICODE_OPTIONS);
        } catch (UnsatisfiedLinkError ex) {
            LOGGER.warn("Can't load user32 library.", ex);
            return null;
        }
    }

    /**
     * Enter a text on Windows systems.
     *
     * @param text  text to enter
     * @param robot robot instance, that sends keypress events
     * @return true, if the text was successfully sent
     */
    public static boolean sendText(String text, java.awt.Robot robot) {
        try {
            sendTextViaUser32(text);
            return true;
        } catch (WindowsException ex) {
            LOGGER.error("Can't send text via user32 library!", ex);
        } catch (Exception | Error ex) {
            LOGGER.error("An unexpected error occurred!", ex);
        }

        try {
            LOGGER.debug("Falling back to numpad.");
            sendTextViaNumpad(text, robot);
            return true;
        } catch (Exception ex) {
            LOGGER.error("Can't send text via numpad!", ex);
        }

        return false;
    }

    /**
     * Enter a text by typing ALT + unicode number on the numpad.
     *
     * @param text  text to enter
     * @param robot robot instance, that sends keypress events
     */
    private static void sendTextViaNumpad(String text, java.awt.Robot robot) {
        if (StringUtils.isEmpty(text)) return;
        for (int i = 0; i < text.length(); i++) {
            final char c = text.charAt(i);
            final String altCode = Integer.toString(c);

            // print character on Windows systems by typing ALT + unicode number
            robot.keyPress(KeyEvent.VK_ALT);
            robot.keyPress(KeyEvent.VK_NUMPAD0);
            robot.keyRelease(KeyEvent.VK_NUMPAD0);
            for (int j = 0; j < altCode.length(); j++) {
                final char code = (char) (altCode.charAt(j) + '0');
                robot.keyPress(code);
                robot.keyRelease(code);
            }
            robot.keyRelease(KeyEvent.VK_ALT);
        }
    }

    /**
     * Enter a text by sending input events through the Windows API via JNA.
     *
     * @param text text to send through the Windows API
     * @throws WindowsException if the User32 library is not available or no events were processed
     * @see <a href="https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-sendinput">SendInput function</a>
     * @see <a href="https://stackoverflow.com/a/22308727">Using SendInput to send unicode characters beyond U+FFFF</a>
     */
    private static void sendTextViaUser32(String text) throws WindowsException {
        if (StringUtils.isEmpty(text))
            return;
        if (USER32 == null)
            throw new WindowsException("User32 library was not loaded.");

        //final List<Long> pointers = new ArrayList<>();
        //noinspection EmptyFinallyBlock
        try {
            final List<WinUser.INPUT> events = new ArrayList<>();
            for (int i = 0; i < text.length(); i++) {
                final char c = text.charAt(i);
                //LOGGER.debug("printing " + c);
                events.add(createKeyboardInput(c, WinUser.KEYBDINPUT.KEYEVENTF_UNICODE));
                events.add(createKeyboardInput(c, WinUser.KEYBDINPUT.KEYEVENTF_KEYUP | WinUser.KEYBDINPUT.KEYEVENTF_UNICODE));
            }
            //for (WinUser.INPUT i : events) {
            //    long address = Pointer.nativeValue(i.getPointer());
            //    if (!pointers.contains(address)) pointers.add(address);
            //}

            WinUser.INPUT[] inputs = events.toArray(new WinUser.INPUT[0]);
            inputs = (WinUser.INPUT[]) inputs[0].toArray(inputs);
            //for (WinUser.INPUT i : inputs) {
            //    long address = Pointer.nativeValue(i.getPointer());
            //    if (!pointers.contains(address)) pointers.add(address);
            //}

            final WinDef.DWORD result = USER32.SendInput(
                    new WinDef.DWORD(inputs.length), inputs, inputs[0].size());

            if (result.intValue() < 1) {
                LOGGER.error("last error: {}", Kernel32Util.getLastErrorMessage());
                throw new WindowsException("No events were executed.");
            }
            //LOGGER.debug("result: {}", result.intValue());
        } finally {
            //for (Long address : pointers) {
            //    Kernel32Util.freeLocalMemory(new Pointer(address));
            //}
        }
    }

    private static class WindowsException extends Exception {
        private WindowsException(String message) {
            super(message);
        }

        @SuppressWarnings("unused")
        private WindowsException(String message, Throwable cause) {
            super(message, cause);
        }
    }
}
