# WJoy

Connects your Nintendo bluetooth controllers to your macOS desktop and laptop.

**For macOS 10.13 High Sierra, 10.12 Sierra and 10.11 El Capitan**

You must have SIP disabled for this application to work. Please disable it by booting your Mac into recovery mode, opening the Terminal and running:

```sh
csrutil disable
```

You may read more here: http://www.imore.com/el-capitan-system-integrity-protection-helps-keep-malware-away

##### Installation Instructions

 1. **Download WJoy here**: http://go.hiddenswitch.com/wjoy
 2. Turn on Bluetooth.
 3. Start the WJoy application.
 4. In the system tray, click the WJoy icon and click Begin Discovery.
 5. Turn on the Wiimote or Wii U Pro Controller by pressing any key on it.
 6. Press the sync button (red flat button on the controller) while in discovery mode.
 7. Once connected, configure the Wii U Pro controller as a Steam controller in Steam Big Picture Mode. Read more here: https://www.howtogeek.com/234427/how-to-remap-buttons-on-your-steam-controller/
 
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
