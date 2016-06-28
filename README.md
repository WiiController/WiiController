# WJoy-foohid

WJoy allows you to use Wii controllers as native gamepads on OS X.

The following controllers are supported

- Wii Remote
	- Nunchuck
	- Classic Controller
- Wii U Pro Controller
- TODO: List the rest

This project is a fork of the original (now unsupported) project and uses foohid as the driver.


## Quick Start

1. Download and install the latest release of foohid:
2. Download the install latest release of WJoy:
3. Ensure that bluetooth is enabled and then click the wiimote icon on the menu bar
4. Click "start discovery" and then hit the red sync button on your Wii Remote or other accessory
5. Once connected, your controller is ready to be used. Enjoy!


## Why foohid?

In OS X El Capitan (version 10.11), Apple added [System Integrity Protection (AKA "rootless" mode)](http://apple.stackexchange.com/questions/193368/what-is-the-rootless-feature-in-el-capitan-really) as a security feature. Among other things, this feature prevents the system from running unsigned kernel extensions (kexts). The original WJoy project included an unsigned kext to provide a virtual HID for each connected wiimote and thus the original project no longer works on modern versions of OS X.

Thankfully, you can still run kexts signed by Apple or by approved developers. That's where foohid comes in. foohid is a signed kext that allows programs to create virtual HID devices on demand -- exactly what we need. With foohid installed, we can use WJoy without having to disable important security features on the operating system.