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
import com.sun.jna.NativeLong;
import com.sun.jna.platform.unix.X11;
import com.sun.jna.ptr.IntByReference;
import de.openindex.support.core.AppUtils;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Linux specific functions.
 *
 * @author Andreas Rudolph
 */
public class LinuxUtils {
    @SuppressWarnings("unused")
    private final static Logger LOGGER = LoggerFactory.getLogger(LinuxUtils.class);
    private final static X11 X11 = loadX11();
    private final static X11.XTest XTEST = loadXTest();

    /**
     * Load X11 library.
     *
     * @return JNA interface of the X11 library
     */
    private static X11 loadX11() {
        try {
            LOGGER.debug("Load X11 library.");
            return Native.load(X11.class);
        } catch (UnsatisfiedLinkError ex) {
            LOGGER.warn("Can't load X11 library.", ex);
            return null;
        }
    }

    /**
     * Load XTest library.
     *
     * @return JNA interface of the XTest library
     */
    private static X11.XTest loadXTest() {
        try {
            LOGGER.debug("Load XTest library.");
            return Native.load(X11.XTest.class);
        } catch (UnsatisfiedLinkError ex) {
            LOGGER.warn("Can't load XTest library.", ex);
            return null;
        }
    }

    /**
     * Enter a text on Linux systems.
     *
     * @param text text to enter
     * @return true, if the text was successfully sent
     */
    public static boolean sendText(String text) {
        try {
            sendTextViaX11(text);
            return true;
        } catch (LinuxException ex) {
            LOGGER.error("Can't send text via X11!", ex);
        }
        return false;
    }

    /**
     * Enter a text by sending input events through the X11 server via JNA.
     *
     * @param text text to send through the X11 server
     * @throws LinuxException if the X11 libraries are not available
     * @see <a href="https://www.x.org/releases/X11R7.7/doc/libXtst/xtestlib.html#XTestFakeKeyEvent">XTEST Extension Library</a>
     * @see <a href="https://stackoverflow.com/a/30417578">sending fake keypress event to a window using xlib</a>
     * @see <a href="https://stackoverflow.com/q/44313966">C xtest emitting key presses for every Unicode character</a>
     */
    private static void sendTextViaX11(String text) throws LinuxException {
        if (StringUtils.isEmpty(text))
            return;
        if (X11 == null)
            throw new LinuxException("X11 library was not loaded.");
        if (XTEST == null)
            throw new LinuxException("XTest library was not loaded.");

        X11.Display display = X11.XOpenDisplay(null);
        //LOGGER.debug("grabbed display " + display);

        // get the range of keycodes usually from 8 - 255
        IntByReference keycodeLow = new IntByReference();
        IntByReference keycodeHigh = new IntByReference();
        X11.XDisplayKeycodes(display, keycodeLow, keycodeHigh);
        //LOGGER.debug("> keycodes " + keycodeLow.getValue() + " - " + keycodeHigh.getValue());

        // get all the mapped keysyms available
        IntByReference keysymsPerKeycode = new IntByReference();
        X11.XGetKeyboardMapping(
                display,
                (byte) keycodeLow.getValue(),
                keycodeHigh.getValue() - keycodeLow.getValue(),
                keysymsPerKeycode);

        X11.KeySym[] keysyms = new X11.KeySym[keycodeHigh.getValue() - keycodeLow.getValue()];
        for (int i = 0; i < keysyms.length; i++) {
            keysyms[i] = X11.XKeycodeToKeysym(display, (byte) (keycodeLow.getValue() + i), 0);
            //LOGGER.debug("keysym {}", i);
            //LOGGER.debug("> {}", keysyms[i]);
            //LOGGER.debug("> code {}", X11.XKeysymToString(keysyms[i]));
        }

        // find unused keycode for unmapped keysyms so we can
        // hook up our own keycode and map every keysym on it
        // so we just need to 'click' our once unmapped keycode
        int scratch_keycode = 0;
        for (int i = 0; i < keysyms.length; i++) {
            if (keysyms[i] == null) {
                scratch_keycode = keycodeLow.getValue() + i;
                break;
            }
        }
        //LOGGER.debug("scratch keycode {}", scratch_keycode);

        X11.XFlush(display);

        for (int i = 0; i < text.length(); i++) {
            char c = text.charAt(i);
            //LOGGER.debug("printing " + c);


            //int value = StandardCharsets.UTF_8.encode(String.valueOf(c)).getInt();
            //LOGGER.debug("> value " + value);
            String unicode = String.format("U%04x", (int) c);
            //LOGGER.debug("> code " + unicode);

            //X11.KeySym sym = X11.XStringToKeysym(String.valueOf(c));
            X11.KeySym sym = X11.XStringToKeysym(unicode);

            //int code = (sym != null) ? X11.XKeysymToKeycode(display, sym) : 0x00D1;
            int code = X11.XKeysymToKeycode(display, sym);

            X11.KeySym[] resetKeySym = null;
            if (!AppUtils.isAsciiCharacter(c)) {
                //LOGGER.debug("> use scratch");
                //LOGGER.debug("> " + X11.XKeysymToString(sym));

                resetKeySym = new X11.KeySym[keysymsPerKeycode.getValue()];
                for (int j = 0; j < resetKeySym.length; j++) {
                    resetKeySym[j] = X11.XKeycodeToKeysym(display, (byte) scratch_keycode, j);
                }

                X11.XChangeKeyboardMapping(
                        display,
                        scratch_keycode,
                        2,
                        new X11.KeySym[]{sym, sym},
                        1);
                code = scratch_keycode;
            }

            //LOGGER.debug("> " + code);

            if (code > 0) {
                //XTEST.XTestFakeKeyEvent(display, code, false, new NativeLong(0));
                //X11.XFlush(display);

                XTEST.XTestFakeKeyEvent(display, code, true, new NativeLong(0));
                //X11.XFlush(display);
                X11.XSync(display, false);

                XTEST.XTestFakeKeyEvent(display, code, false, new NativeLong(0));
                //X11.XFlush(display);
                X11.XSync(display, false);

                //noinspection CatchMayIgnoreException
                try {
                    Thread.sleep(100);
                } catch (Exception ex) {
                }
            }

            if (resetKeySym != null) {
                X11.XChangeKeyboardMapping(
                        display,
                        scratch_keycode,
                        resetKeySym.length,
                        resetKeySym,
                        1);
            }
        }

        //X11.XFlush(display);
        //X11.XSync(display, false);
        X11.XCloseDisplay(display);
    }

    private static class LinuxException extends Exception {
        private LinuxException(String message) {
            super(message);
        }

        @SuppressWarnings("unused")
        private LinuxException(String message, Throwable cause) {
            super(message, cause);
        }
    }
}
