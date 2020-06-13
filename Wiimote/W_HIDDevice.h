//
//  W_HIDDevice.h
//  HID
//
//  Created by alxn1 on 24.06.13.
//  Copyright 2013 alxn1. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <IOKit/hid/IOHIDLib.h>

@class W_HIDDevice;
@class HIDManager;

@protocol W_HIDDeviceDelegate <NSObject>

@optional
- (void)HIDDevice:(W_HIDDevice*)device reportDataReceived:(const uint8_t*)bytes length:(NSUInteger)length;
- (void)HIDDeviceDisconnected:(W_HIDDevice*)device;

@end

@interface W_HIDDevice : NSObject

- (HIDManager*)owner;

- (BOOL)isValid;
- (void)invalidate;

// only kIOHIDOptionsTypeNone or kIOHIDOptionsTypeSeizeDevice
- (IOOptionBits)options;
- (BOOL)setOptions:(IOOptionBits)options;

- (NSDictionary*)properties;

- (BOOL)postBytes:(const uint8_t*)bytes length:(NSUInteger)length;

- (id)delegate;
- (void)setDelegate:(id)delegate;

- (NSString*)name;
- (NSString*)address;

@end
