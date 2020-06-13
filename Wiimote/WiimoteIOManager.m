//
//  WiimoteIOManager.m
//  Wiimote
//
//  Created by alxn1 on 31.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteIOManager.h"

#import "Wiimote.h"
#import "WiimoteDevice.h"

@implementation WiimoteIOManager
{
    WiimoteDevice   *_device;
}

- (BOOL)postCommand:(WiimoteDeviceCommandType)command
			   data:(const uint8_t*)data
             length:(NSUInteger)length
{
    return [_device postCommand:command data:data length:length];
}

- (BOOL)writeMemory:(NSUInteger)address
			   data:(const uint8_t*)data
             length:(NSUInteger)length
{
    return [_device writeMemory:address data:data length:length];
}

- (BOOL)readMemory:(NSRange)memoryRange
			target:(id)target
			action:(SEL)action
{
    return [_device readMemory:memoryRange target:target action:action];
}

- (id)initWithOwner:(Wiimote*)owner device:(WiimoteDevice*)device
{
    self = [super init];
    if(self == nil)
        return nil;

    _owner     = owner;
    _device    = device;

    return self;
}

@end
