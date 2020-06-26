# WiiController
## Use your Nintendo Wii and Wii U controllers on macOS as standard gamepads

WiiController is a device driver and helper application that allows you to use the following Nintendo Bluetooth controllers as virtual gamepads on macOS:

- Wii Remote
- Wii Remote Plus
- Wii U Pro Controller
- Wii Balance Board
- Supported accessories:
  - Nunchuck
  - Classic Controller (original or Pro)
  - Wii Motion Plus (for original Wii Remote) (untested, may not work)
  - UDraw Tablet (untested, may not work)

This repository builds on the work of [JustinBis/wjoy-foohid](https://github.com/JustinBis/wjoy-foohid), which in turn updated the [original wjoy driver](https://github.com/alxn1/wjoy) by [alxn1](https://github.com/alxn1).

## Install

**Please use appropriate caution:** You are about to install a kernel-level device driver. I am not aware of anything wrong with the code, and it has never caused me any noticable problems or kernel panics, but _this may be different for you_ and installation is entirely _at your own risk_. If you encounter problems, I will try to help you to the best of my ability, but this software comes with **absolutely no warranty**.

The driver and app _should_ work on macOS 10.11 or later. As of now, this fork has only been tested on 10.15.5 and 10.14.6.

### Disable SIP kext protections

You must have the kernel extensions protection of [System Integrity Protection (SIP)](http://www.imore.com/el-capitan-system-integrity-protection-helps-keep-malware-away) disabled for the driver to load. To disable SIP, boot into [recovery mode](https://support.apple.com/en-ca/HT201314), select Terminal from Utilities in the menu bar, and run the following:

```
csrutil disable
```

This second command is optional, but will re-harden (re-enable) other parts of system security that WiiController does not care about. This is ultimately your choice.

```
csrutil enable --without kext
```

### Installation steps _after you have disabled SIP kext protections_

 1. **Download WiiController**: https://github.com/WiiController/WiiController/releases
 2. Turn on Bluetooth.
 3. Start the WiiController application.
 4. Pairing should begin automatically, but will expire after 10 seconds. To re-enable it if 10 seconds have passed, click the Wii Remote icon in the menu bar and select Pair Device.
 5. Press the small red "sync" button on your Nintendo device. To pair multiple devices, select Pair Device again for each.
 6. (Optional) Once connected, configure your controller as a Steam controller in Steam Big Picture Mode. Read more here: https://www.howtogeek.com/234427/how-to-remap-buttons-on-your-steam-controller/

## I need help!

Please check the [wiki](https://github.com/WiiController/WiiController/wiki).

## Notes on Wii U Pro Controller and Steam games

(These notes are from [JustinBis/wjoy-foohid](https://github.com/JustinBis/wjoy-foohid). I have not confirmed any of this myself, but I presume it is correct.)

In my experience, Unity games for Mac do not support the Wii U Pro Controller, since they tend to use the XInput package. There is no application that emulates an Xbox controller for Mac.

Working:

 - Binding of Isaac
 - DolphinEmu
 - Antichamber
 - Hotline Miami
 - Teleglitch

Not working:

 - Ultimate Chicken Horse
 - Gang Beasts
 - Broforce
 - Monaco
 - Superhot
