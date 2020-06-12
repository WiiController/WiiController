//
//  HIDManager.m
//  HID
//
//  Created by alxn1 on 24.06.13.
//  Copyright 2013 alxn1. All rights reserved.
//

#import "HIDManager.h"

#import "W_HIDDevice+Private.h"

NSString *HIDManagerDeviceConnectedNotification     = @"HIDManagerDeviceConnectedNotification";
NSString *HIDManagerDeviceDisconnectedNotification  = @"HIDManagerDeviceDisconnectedNotification";

NSString *HIDManagerDeviceKey                       = @"HIDManagerDeviceKey";

@interface HIDManager (PrivatePart)

- (void)rawDeviceConnected:(IOHIDDeviceRef)device;
- (void)deviceConnected:(W_HIDDevice*)device;

@end

@implementation HIDManager

static void HIDManagerDeviceConnected(
                                    void            *context,
                                    IOReturn         result,
                                    void            *sender,
                                    IOHIDDeviceRef   device)
{
    HIDManager *manager = (__bridge HIDManager*)context;

    [manager rawDeviceConnected:device];
}

- (id)initInternal
{
    self = [super init];

    if(self == nil)
        return nil;

    m_Handle            = IOHIDManagerCreate(kCFAllocatorDefault, 0);
    m_ConnectedDevices  = [[NSMutableSet alloc] init];

    if(m_Handle == nil)
    {
        return nil;
    }

    IOHIDManagerSetDeviceMatching(m_Handle, (CFDictionaryRef)[NSDictionary dictionary]);
    IOHIDManagerRegisterDeviceMatchingCallback(m_Handle, HIDManagerDeviceConnected, (__bridge void * _Nullable)(self));
    IOHIDManagerScheduleWithRunLoop(
                                m_Handle,
                                [[NSRunLoop currentRunLoop] getCFRunLoop],
                                (CFStringRef)NSRunLoopCommonModes);

    if(IOHIDManagerOpen(m_Handle, kIOHIDOptionsTypeNone) != kIOReturnSuccess)
    {
        return nil;
    }

    return self;
}

- (void)dealloc
{
    if(m_Handle != NULL)
    {
        IOHIDManagerUnscheduleFromRunLoop(
                                m_Handle,
                                [[NSRunLoop currentRunLoop] getCFRunLoop],
                                (CFStringRef)NSRunLoopCommonModes);

        IOHIDManagerClose(m_Handle, 0);
        CFRelease(m_Handle);
    }

    while([m_ConnectedDevices count] != 0)
        [[m_ConnectedDevices anyObject] invalidate];

}

+ (HIDManager*)manager
{
    static HIDManager *result = nil;

    if(result == nil)
        result = [[HIDManager alloc] initInternal];

    return result;
}

- (NSSet*)connectedDevices
{
    return m_ConnectedDevices;
}

@end

@implementation HIDManager (PrivatePart)

- (void)rawDeviceConnected:(IOHIDDeviceRef)device
{
    if([m_ConnectedDevices containsObject:(__bridge id)device])
        return;

    W_HIDDevice *d = [[W_HIDDevice alloc]
                            initWithOwner:self
                                deviceRef:device
                                  options:kIOHIDOptionsTypeNone];

    [self deviceConnected:d];
}

- (void)deviceConnected:(W_HIDDevice*)device
{
    [m_ConnectedDevices addObject:device];

    [[NSNotificationCenter defaultCenter]
                            postNotificationName:HIDManagerDeviceConnectedNotification
                                          object:self
                                        userInfo:[NSDictionary
                                                        dictionaryWithObject:device
                                                                      forKey:HIDManagerDeviceKey]];
}

@end
