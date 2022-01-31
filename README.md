# WiiController
## Use your Wii and Wii U controllers on macOS as standard gamepads

**Note: [WiiController does not currently work on macOS 12. Projects like Dolphin are having similar issues.](https://github.com/WiiController/WiiController/issues/16#issuecomment-1019526888)**  
macOS 11 and below are not affected by this issue.

WiiController is a macOS device driver application that allows you to use the following controllers as standard HID gamepads:

- Wii Remote (original or Plus)
  - Nunchuk
  - Classic Controller (original or Pro)
  - Guitar Hero 3 controller
- Wii U Pro Controller

The following controllers are at least partially implemented, but aren't currently usable:

- Wii Balance Board
- Wii Motion Plus
- UDraw Tablet

If you really want support for one of these, please open an issue.

## How does it work?

Since Wii devices require a special Bluetooth pairing procedure, the app handles this. Once pairing succeeds and a connection is established, the app creates a virtual HID gamepad (joystick) device to represent the controller. Note that this requires a driver extension, or kernel extension before macOS 10.15.

Once everything is set up, the app continually translates input from the controllers (which use a proprietary protocol over Bluetooth) to normal HID events in real time. The result is that, as long as the app is running, your controllers effectively speak HID!

WiiController stands on the shoulders of alxn1's [WJoy](https://github.com/alxn1/wjoy), and incorporates some patches from [JustinBis/wjoy-foohid](https://github.com/JustinBis/wjoy-foohid). Most of the code is from WJoy, but cleaned up and updated. The kext has been translated to a dext for macOS 10.15 and up.

## Install

### Please note

**If you are running macOS 10.15 or later:** Please note that a driver extension is required for WiiController to function. Until I obtain a signing certificate, it may be a security hole. Installation is at your own risk.

**If you are running macOS 10.14 or earlier:** Please use appropriate caution and note that a kernel extension is required for WiiController to function. I have not heard of it causing any kernel panics, but it may be a security hole. Installation is at your own risk. If you encounter problems with it, I will try to help you to the best of my ability, but this software comes with **no warranty**.

### Requirements

**Note: [WiiController does not currently work on macOS 12. Projects like Dolphin are having similar issues.](https://github.com/WiiController/WiiController/issues/16#issuecomment-1019526888)**  
macOS 11 and below are not affected by this issue.

- WiiController should work on macOS 10.11 or later. It has been tested on 10.14.6, 10.15.7, and 11.2.3.
- WiiController should work on both Intel and Apple M-series CPU types. Both have been tested. Please note that apps running under Rosetta seem to be unable to see the controller events.

### Disable SIP

As I cannot sign dexts or kexts, you must have [System Integrity Protection (SIP)](https://developer.apple.com/documentation/security/disabling_and_enabling_system_integrity_protection) disabled for the driver to load. To disable SIP, boot into [recovery mode](https://support.apple.com/en-us/HT201314), select Terminal from Utilities in the menu bar, and run the following:

```
csrutil disable
```

If you are running macOS 10.15 or later, restart your computer now.

If you are running macOS 10.14 or earlier, you may _optionally_ run this second command that will re-enable other parts of system security that WiiController does not care about:

```
csrutil enable --without kext
```

Finally, restart your computer.

### Installation steps

1. Disable SIP as described above.
2. **Download WiiController**: https://github.com/WiiController/WiiController/releases
3. Install the app by dragging it to your Applications folder. This is **required** on macOS 10.15 or later.
4. Turn on Bluetooth.
5. Start WiiController by right-clicking it in Finder and selecting Open. (This technique allows you to run an unsigned app.)
6. If it crashes or nothing appears to happen, then this is probably a known code signing issue. It's entirely my fault, but until I resolve it, you can fix the problem by running `codesign -fs - /Applications/WiiController.app` in Terminal (copy and paste the command, then press Return) and then relaunching WiiController. (For details, see [issue #12](https://github.com/WiiController/WiiController/issues/12).)
7. Enter your password if necessary, and approve the system extension when prompted.
8. Pairing should begin automatically, but will expire after 10 seconds. To re-enable it if 10 seconds have passed, click the Wii Remote icon in the menu bar and select Pair Device.
9. Press the small red "sync" button on your Nintendo device. To pair multiple devices, select Pair Device again for each.
10. [Check the wiki on GitHub](https://github.com/WiiController/WiiController/wiki) for further usage instructions and support articles.
