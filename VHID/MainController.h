//
//  MainController.h
//  VHID
//
//  Created by alxn1 on 24.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "TestView.h"

#import <WirtualJoy/WJoyDevice.h>
#import <VHID/VHIDDevice.h>

@interface MainController : NSObject<VHIDDeviceDelegate, TestViewDelegate>
{
    @private
        VHIDDevice *_mouseState;
        WJoyDevice *_virtualMouse;
}

@end
