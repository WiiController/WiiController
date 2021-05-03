//
//  HIDManager.h
//  HID
//
//  Created by alxn1 on 24.06.13.
//  Copyright 2013 alxn1. All rights reserved.
//

#import <HID/W_HIDDevice.h>

FOUNDATION_EXPORT NSString *HIDManagerDeviceConnectedNotification;
FOUNDATION_EXPORT NSString *HIDManagerDeviceDisconnectedNotification;

FOUNDATION_EXPORT NSString *HIDManagerDeviceKey;

@interface HIDManager : NSObject <W_HIDDeviceDelegate>

+ (HIDManager *)manager;

@property(nonatomic, copy, readonly) NSSet *connectedDevices;

@end
