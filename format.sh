#!/bin/bash

cd $(dirname "$0")

cd WiiController
clang-format -i *.{h,m}
cd ..

cd Wiimote
clang-format -i *.{h,m}
cd ..

cd VHID
clang-format -i {VHIDDevice,VHIDButtonCollection,VHIDPointerCollection}.{h,m}
cd ..

cd WirtualJoy
clang-format -i {WJoyDevice,WJoyDeviceImpl,WJoyTool,WJoyAdminToolRight,WJoyToolMain,STPrivilegedTask,WJoyToolInterface}.{h,m}
cd ..
