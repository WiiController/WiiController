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

@property(nonatomic,readonly) HIDManager *owner;

@property(nonatomic,readonly) BOOL isValid;
- (void)invalidate;

// only kIOHIDOptionsTypeNone or kIOHIDOptionsTypeSeizeDevice
@property(nonatomic,readonly) IOOptionBits options;
- (BOOL)setOptions:(IOOptionBits)options;

@property(nonatomic,readonly) NSDictionary *properties;

- (BOOL)postBytes:(const uint8_t*)bytes length:(NSUInteger)length;

@property(nonatomic) id <W_HIDDeviceDelegate> delegate;

@property(nonatomic,readonly) NSString *name;
@property(nonatomic,readonly) NSString *address;

@end
