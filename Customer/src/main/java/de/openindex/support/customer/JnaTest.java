package de.openindex.support.customer;

import com.sun.jna.Native;
import com.sun.jna.NativeLong;
import com.sun.jna.platform.unix.X11;
import com.sun.jna.platform.win32.BaseTSD;
import com.sun.jna.platform.win32.User32;
import com.sun.jna.platform.win32.WinDef;
import com.sun.jna.platform.win32.WinUser;
import com.sun.jna.ptr.IntByReference;

public class JnaTest {
    public static void main(String[] args) {
        //sendTextX11("test123/\\@äöüß€");
        sendTextX11("Ä");
        sendTextX11("ä");
        sendTextX11("Ö");
        sendTextX11("ö");
        sendTextX11("Ü");
        sendTextX11("ü");
    }

    public static void sendTextWindows(String text) {
        // inspired by https://stackoverflow.com/a/22308727

        User32 user32 = Native.load(User32.class);

        WinUser.INPUT[] input = new WinUser.INPUT[text.length()];
        int size = 0;
        for (int i = 0; i < text.length(); i++) {
            char c = text.charAt(i);
            System.out.println("printing " + c);

            input[i] = new WinUser.INPUT();
            input[i].type = new WinDef.DWORD(WinUser.INPUT.INPUT_KEYBOARD);
            input[i].input.ki = new WinUser.KEYBDINPUT();
            input[i].input.ki.wVk = new WinDef.WORD(0);
            input[i].input.ki.wScan = new WinDef.WORD(c);
            input[i].input.ki.time = new WinDef.DWORD(0);
            input[i].input.ki.dwFlags = new WinDef.DWORD(WinUser.KEYBDINPUT.KEYEVENTF_UNICODE);
            input[i].input.ki.dwExtraInfo = new BaseTSD.ULONG_PTR();
            size += input[i].size();
        }

        // see https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-sendinput
        user32.SendInput(new WinDef.DWORD(input.length), input, size);
    }

    public static void sendTextX11(String text) {
        // inspired by https://stackoverflow.com/a/30417578

        X11 x11 = Native.load(X11.class);
        X11.XTest xtest = Native.load(X11.XTest.class);

        X11.Display d = x11.XOpenDisplay(null);
        System.out.println("grabbed display " + d);

        int screen = x11.XDefaultScreen(d);
        System.out.println("default screen " + screen);
        System.out.println("> width: " + x11.XDisplayWidth(d, screen));
        System.out.println("> height: " + x11.XDisplayHeight(d, screen));

        //get the range of keycodes usually from 8 - 255
        IntByReference minKeycodes = new IntByReference();
        IntByReference maxKeycodes = new IntByReference();
        x11.XDisplayKeycodes(d, minKeycodes, maxKeycodes);
        System.out.println("> keycodes " + minKeycodes.getValue() + " - " + maxKeycodes.getValue());

        //get all the mapped keysyms available
        IntByReference keysymsPerKeycode = new IntByReference();
        X11.KeySym keysyms = x11.XGetKeyboardMapping(
                d,
                (byte)minKeycodes.getValue(),
                maxKeycodes.getValue()-minKeycodes.getValue(),
                keysymsPerKeycode);

        /*//find unused keycode for unmapped keysyms so we can
        //hook up our own keycode and map every keysym on it
        //so we just need to 'click' our once unmapped keycode
        int i;
        for (i = minKeycodes.getValue(); i <= maxKeycodes.getValue(); i++)
        {
            int j = 0;
            int key_is_empty = 1;
            for (j = 0; j < keysymsPerKeycode.getValue(); j++)
            {
                int symindex = (i - minKeycodes.getValue()) * keysymsPerKeycode.getValue() + j;
                // test for debugging to looking at those value
                // KeySym sym_at_index = keysyms[symindex];
                // char *symname;
                // symname = XKeysymToString(keysyms[symindex]);

                if (keysyms[symindex] != 0)
                {
                    key_is_empty = 0;
                }
                else
                {
                    break;
                }
            }
            if (key_is_empty)
            {
                scratch_keycode = i;
                break;
            }
        }
        XFree(keysyms);
        XFlush(dpy);*/




        for (int i = 0; i < text.length(); i++) {
            char c = text.charAt(i);
            System.out.println("printing " + c);

            //int value = StandardCharsets.UTF_8.encode(String.valueOf(c)).getInt();
            //System.out.println("> value " + value);
            String unicode = String.format("U%04x", (int) c);
            System.out.println("> code " + unicode);

            //X11.KeySym sym = x11.XStringToKeysym(String.valueOf(c));
            X11.KeySym sym = x11.XStringToKeysym(unicode);
            System.out.println("> " + sym);

            //int code = (sym != null) ? x11.XKeysymToKeycode(d, sym) : 0x00D1;
            int code = x11.XKeysymToKeycode(d, sym);

            X11.KeySym[] resetKeySym = null;
            if (code==0) {
                resetKeySym = new X11.KeySym[keysymsPerKeycode.getValue()];
                for (int j=0; j<resetKeySym.length; j++) {
                    resetKeySym[j] = x11.XKeycodeToKeysym(d, (byte) minKeycodes.getValue(), j);
                }

                x11.XChangeKeyboardMapping(d, minKeycodes.getValue(), 1, new X11.KeySym[]{sym}, 1);
                code = minKeycodes.getValue();
            }

            System.out.println("> " + code);

            if (code > 0) {
                xtest.XTestFakeKeyEvent(d, code, false, new NativeLong(0));
                x11.XFlush(d);
                xtest.XTestFakeKeyEvent(d, code, true, new NativeLong(0));
                x11.XFlush(d);
                xtest.XTestFakeKeyEvent(d, code, false, new NativeLong(0));
                x11.XFlush(d);
            }

            if (resetKeySym!=null) {
                x11.XChangeKeyboardMapping(d, minKeycodes.getValue(), resetKeySym.length, resetKeySym, resetKeySym.length);
            }
        }
    }
}
