//
//  Wiimote+Create.h
//  Wiimote
//
//  Created by alxn1 on 30.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "Wiimote.h"

@protocol WiimoteDeviceDelegate;
@class W_HIDDevice;
@class IOBluetoothDevice;

@interface Wiimote (Create)

+ (void)connectToHIDDevice:(W_HIDDevice*)device;
+ (void)connectToBluetoothDevice:(IOBluetoothDevice*)device;

@property(nonatomic,readonly) id lowLevelDevice;

@end
