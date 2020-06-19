//
//  WJoyDevice.m
//  driver
//
//  Created by alxn1 on 17.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WJoyDevice.h"

#import "WJoyDeviceImpl.h"

NSString *WJoyDeviceVendorIDKey             = @"WJoyDeviceVendorIDKey";
NSString *WJoyDeviceProductIDKey            = @"WJoyDeviceProductIDKey";
NSString *WJoyDeviceProductStringKey        = @"WJoyDeviceProductStringKey";
NSString *WJoyDeviceSerialNumberStringKey   = @"WJoyDeviceSerialNumberStringKey";

@implementation WJoyDevice

+ (BOOL)prepare
{
    return [WJoyDeviceImpl prepare];
}

- (id)initWithHIDDescriptor:(NSData*)HIDDescriptor
{
    return [self initWithHIDDescriptor:HIDDescriptor properties:nil];
}

- (id)initWithHIDDescriptor:(NSData*)HIDDescriptor productString:(NSString*)productString
{
    NSDictionary *properties = @{WJoyDeviceProductStringKey: productString};

    return [self initWithHIDDescriptor:HIDDescriptor properties:properties];
}

- (id)initWithHIDDescriptor:(NSData*)HIDDescriptor properties:(NSDictionary*)properties
{
    self = [super init];
    if(self == nil)
        return nil;

    uint32_t     vendorID           = [[properties objectForKey:WJoyDeviceVendorIDKey] unsignedIntValue];
    uint32_t     productID          = [[properties objectForKey:WJoyDeviceProductIDKey] unsignedIntValue];
    NSString    *productString      = [properties objectForKey:WJoyDeviceProductStringKey];
    NSString    *serialNumberString = [properties objectForKey:WJoyDeviceSerialNumberStringKey];

    _impl = [[WJoyDeviceImpl alloc] init];
    if(_impl == nil)
    {
        return nil;
    }

    if(productString != nil)
        [_impl setDeviceProductString:productString];

    if(serialNumberString != nil)
        [_impl setDeviceSerialNumberString:serialNumberString];

    if(vendorID != 0 || productID != 0)
        [_impl setDeviceVendorID:vendorID productID:productID];

    if(![_impl enable:HIDDescriptor])
    {
        return nil;
    }

    _properties = [properties copy];
    return self;
}


- (NSDictionary*)properties
{
    return _properties;
}

- (BOOL)updateHIDState:(NSData*)HIDState
{
    return [_impl updateState:HIDState];
}

@end
