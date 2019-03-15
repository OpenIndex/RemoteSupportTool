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
import de.openindex.support.customer.utils.mac.CoreFoundation;
import de.openindex.support.customer.utils.mac.CoreGraphics;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * MacOS specific functions.
 *
 * @author Andreas Rudolph
 */
public class MacUtils {
    @SuppressWarnings("unused")
    private final static Logger LOGGER = LoggerFactory.getLogger(MacUtils.class);
    private final static CoreFoundation CORE_FOUNDATION = loadCoreFoundation();
    private final static CoreGraphics CORE_GRAPHICS = loadCoreGraphics();

    /**
     * Load Core Foundation framework.
     *
     * @return JNA interface of the Core Foundation framework
     */
    private static CoreFoundation loadCoreFoundation() {
        try {
            LOGGER.debug("Load Core Foundation framework.");
            return Native.load(CoreFoundation.JNA_LIBRARY_NAME, CoreFoundation.class);
        } catch (UnsatisfiedLinkError ex) {
            LOGGER.warn("Can't load Core Foundation framework.", ex);
            return null;
        }
    }

    /**
     * Load Core Graphics framework.
     *
     * @return JNA interface of the Core Graphics framework
     */
    private static CoreGraphics loadCoreGraphics() {
        try {
            LOGGER.debug("Load Core Graphics framework.");
            return Native.load(CoreGraphics.JNA_LIBRARY_NAME, CoreGraphics.class);
        } catch (UnsatisfiedLinkError ex) {
            LOGGER.warn("Can't load Core Graphics framework.", ex);
            return null;
        }
    }

    /**
     * Post a keyboard input event.
     *
     * @param character character to print
     * @param keyDown   key is pressed or released
     */
    private static void postKeyboardEvent(final char character, boolean keyDown) {
        if (CORE_GRAPHICS == null || CORE_FOUNDATION == null)
            return;

        final CoreGraphics.CGEventRef event = CORE_GRAPHICS.CGEventCreateKeyboardEvent(
                null, (char) 0, keyDown);

        CORE_GRAPHICS.CGEventKeyboardSetUnicodeString(event, 1, new char[]{character});
        CORE_GRAPHICS.CGEventPost(CoreGraphics.CGEventTapLocation.kCGHIDEventTap, event);
        CORE_FOUNDATION.CFRelease(event);
    }

    /**
     * Enter a text on macOS systems.
     *
     * @param text text to enter
     * @return true, if the text was successfully sent
     */
    public static boolean sendText(String text) {
        try {
            sendTextViaCoreGraphics(text);
            return true;
        } catch (MacException ex) {
            LOGGER.error("Can't send text via Core Graphics framework!", ex);
        } catch (Exception | Error ex) {
            LOGGER.error("An unexpected error occurred!", ex);
        }
        return false;
    }

    /**
     * Enter a text by sending input events through the Quartz API via JNA.
     *
     * @param text text to send through the Quartz API
     * @throws MacException if the macOS frameworks are not available
     * @see <a href="https://developer.apple.com/documentation/coregraphics/quartz_event_services">Quartz Event Services</a>
     * @see <a href="https://developer.apple.com/documentation/coregraphics/1456564-cgeventcreatekeyboardevent">CGEventCreateKeyboardEvent</a>
     * @see <a href="https://developer.apple.com/documentation/coregraphics/1456028-cgeventkeyboardsetunicodestring">CGEventKeyboardSetUnicodeString</a>
     * @see <a href="https://developer.apple.com/documentation/coregraphics/1456527-cgeventpost">CGEventPost</a>
     */
    private static void sendTextViaCoreGraphics(String text) throws MacException {
        if (StringUtils.isEmpty(text))
            return;
        if (CORE_FOUNDATION == null)
            throw new MacException("Core Foundation framework was not loaded.");
        if (CORE_GRAPHICS == null)
            throw new MacException("Core Graphics framework was not loaded.");

        for (int i = 0; i < text.length(); i++) {
            final char c = text.charAt(i);
            postKeyboardEvent(c, true);
            postKeyboardEvent(c, false);
        }
    }

    private static class MacException extends Exception {
        private MacException(String message) {
            super(message);
        }

        @SuppressWarnings("unused")
        private MacException(String message, Throwable cause) {
            super(message, cause);
        }
    }
}
