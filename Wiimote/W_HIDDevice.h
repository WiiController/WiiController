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

@interface NSObject (HIDDeviceDelegate)

- (void)HIDDevice:(W_HIDDevice*)device reportDataReceived:(const uint8_t*)bytes length:(NSUInteger)length;
- (void)HIDDeviceDisconnected:(W_HIDDevice*)device;

@end

@interface W_HIDDevice : NSObject
{
    @private
        HIDManager      *m_Owner;

        BOOL             m_IsValid;
        BOOL             m_IsDisconnected;
        IOHIDDeviceRef   m_Handle;
        IOOptionBits     m_Options;
        NSDictionary    *m_Properties;

        NSMutableData   *m_ReportBuffer;

        id               m_Delegate;
}

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

@end

@interface W_HIDDevice (Properties)

- (NSString*)name;
- (NSString*)address;

@end
