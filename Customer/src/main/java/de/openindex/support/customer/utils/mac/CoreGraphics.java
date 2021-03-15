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
package de.openindex.support.customer.utils.mac;

import com.sun.jna.Library;
import com.sun.jna.NativeLong;
import com.sun.jna.Pointer;
import com.sun.jna.Structure;

/**
 * Definition (incomplete) of the Core Graphics framework.
 *
 * @author Andreas Rudolph
 * @see <a href="https://developer.apple.com/documentation/coregraphics">Core Graphics</a>
 */
@SuppressWarnings("unused")
public interface CoreGraphics extends Library {
    String JNA_LIBRARY_NAME = "CoreGraphics";

    /**
     * Returns a new Quartz keyboard event.
     *
     * @param source     An event source taken from another event, or NULL.
     * @param virtualKey The virtual key code for the event.
     * @param keyDown    Pass true to specify that the key position is down. To specify that the key position is up, pass false. This value is used to determine the type of the keyboard event
     * @return A new keyboard event, or NULL if the event could not be created. When you no longer need the event, you should release it using the function CFRelease.
     * @see <a href="https://developer.apple.com/documentation/coregraphics/1456564-cgeventcreatekeyboardevent">CGEventCreateKeyboardEvent</a>
     */
    CGEventRef CGEventCreateKeyboardEvent(CGEventSourceRef source, char virtualKey, boolean keyDown);

    /**
     * Sets the Unicode string associated with a Quartz keyboard event.
     *
     * @param event         The keyboard event to access.
     * @param stringLength  The length of the array you provide in the unicodeString parameter.
     * @param unicodeString An array that contains the new Unicode string associated with the specified event.
     * @see <a href="https://developer.apple.com/documentation/coregraphics/1456028-cgeventkeyboardsetunicodestring">CGEventKeyboardSetUnicodeString</a>
     */
    void CGEventKeyboardSetUnicodeString(CGEventRef event, int stringLength, char[] unicodeString);
    //void CGEventKeyboardSetUnicodeString(CGEventRef event, int stringLength, String unicodeString);

    /**
     * Posts a Quartz event into the event stream at a specified location.
     *
     * @param tap   The location at which to post the event. Pass one of the constants listed in {@link CGEventTapLocation}.
     * @param event The event to post.
     * @see <a href="https://developer.apple.com/documentation/coregraphics/1456527-cgeventpost">CGEventPost</a>
     */
    void CGEventPost(int tap, CGEventRef event);

    /**
     * Defines an opaque type that represents a low-level hardware event.
     *
     * @see <a href="https://developer.apple.com/documentation/coregraphics/cgeventref">CGEventRef</a>
     */
    @Structure.FieldOrder({"CFHashCode", "CFTypeID", "CFTypeRef"})
    class CGEventRef extends CoreFoundation.CFTypeRef {
        public NativeLong CFHashCode;
        public NativeLong CFTypeID;
        public Pointer CFTypeRef;
    }

    /**
     * Defines an opaque type that represents the source of a Quartz event.
     *
     * @see <a href="https://developer.apple.com/documentation/coregraphics/cgeventsourceref">CGEventSourceRef</a>
     */
    class CGEventSourceRef extends CoreFoundation.CFTypeRef {

    }

    /**
     * Constants that specify possible tapping points for events.
     *
     * @see <a href="https://developer.apple.com/documentation/coregraphics/cgeventtaplocation">CGEventTapLocation</a>
     */
    interface CGEventTapLocation {
        /**
         * Specifies that an event tap is placed at the point where HID system events enter the window server.
         */
        int kCGHIDEventTap = 0;

        /**
         * Specifies that an event tap is placed at the point where HID system and remote control events enter a login session.
         */
        int kCGSessionEventTap = 1;

        /**
         * Specifies that an event tap is placed at the point where session events have been annotated to flow to an application.
         */
        int kCGAnnotatedSessionEventTap = 2;
    }
}
