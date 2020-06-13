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

@implementation HIDManager
{
    IOHIDManagerRef  _handle;
    NSMutableSet *_connectedDevices;
}

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

    _handle            = IOHIDManagerCreate(kCFAllocatorDefault, 0);
    _connectedDevices  = [NSMutableSet set];

    if(_handle == nil)
    {
        return nil;
    }

    IOHIDManagerSetDeviceMatching(_handle, (CFDictionaryRef)[NSDictionary dictionary]);
    IOHIDManagerRegisterDeviceMatchingCallback(_handle, HIDManagerDeviceConnected, (__bridge void * _Nullable)(self));
    IOHIDManagerScheduleWithRunLoop(
                                _handle,
                                [[NSRunLoop currentRunLoop] getCFRunLoop],
                                (CFStringRef)NSRunLoopCommonModes);

    if(IOHIDManagerOpen(_handle, kIOHIDOptionsTypeNone) != kIOReturnSuccess)
    {
        return nil;
    }

    return self;
}

- (void)dealloc
{
    if(_handle != NULL)
    {
        IOHIDManagerUnscheduleFromRunLoop(
                                _handle,
                                [[NSRunLoop currentRunLoop] getCFRunLoop],
                                (CFStringRef)NSRunLoopCommonModes);

        IOHIDManagerClose(_handle, 0);
        CFRelease(_handle);
    }

    while([_connectedDevices count] != 0)
        [[_connectedDevices anyObject] invalidate];

}

+ (HIDManager*)manager
{
    static HIDManager *result = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        result = [[HIDManager alloc] initInternal];
    });
    return result;
}

- (void)HIDDeviceDisconnected:(W_HIDDevice*)device
{
    [_connectedDevices removeObject:device];

    [[NSNotificationCenter defaultCenter]
                            postNotificationName:HIDManagerDeviceDisconnectedNotification
                                          object:self
                                        userInfo:[NSDictionary
                                                        dictionaryWithObject:device
                                                                      forKey:HIDManagerDeviceKey]];
}

- (void)rawDeviceConnected:(IOHIDDeviceRef)device
{
    if([_connectedDevices containsObject:(__bridge id)device])
        return;

    W_HIDDevice *d = [[W_HIDDevice alloc]
                            initWithOwner:self
                                deviceRef:device
                                  options:kIOHIDOptionsTypeNone];

    [self deviceConnected:d];
}

- (void)deviceConnected:(W_HIDDevice*)device
{
    [_connectedDevices addObject:device];

    [[NSNotificationCenter defaultCenter]
                            postNotificationName:HIDManagerDeviceConnectedNotification
                                          object:self
                                        userInfo:[NSDictionary
                                                        dictionaryWithObject:device
                                                                      forKey:HIDManagerDeviceKey]];
}

@end
