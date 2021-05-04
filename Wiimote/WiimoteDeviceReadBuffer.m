//
//  WiimoteDeviceReadBuffer.m
//  Wiimote
//
//  Created by alxn1 on 29.07.12.
//  Copyright (c) 2012 alxn1. All rights reserved.
//

#import "WiimoteDeviceReadBuffer.h"
#import "WiimoteDevice.h"

@implementation WiimoteDeviceReadBuffer
{
    NSMutableData *_data;
    WiimoteDeviceReadCallback _fullCallback;
}

- (id)initWithMemoryRange:(NSRange)memoryRange fullCallback:(WiimoteDeviceReadCallback)fullCallback
{
    self = [super init];
    if (!self) return nil;

    if (memoryRange.length == 0) return nil;

    _memoryRange = memoryRange;
    _data = [NSMutableData dataWithCapacity:memoryRange.length];
    _fullCallback = fullCallback;

    return self;
}

- (void)append:(const uint8_t *)data length:(NSUInteger)length
{
    [_data appendBytes:data length:length];
    if (self.isFull) [self finish];
}

- (BOOL)isFull
{
    return (_data.length >= _memoryRange.length);
}

- (void)finish
{
    _fullCallback(_data);
}

- (void)errorOccured
{
    [_data setLength:0];
    [self finish];
}

- (void)disconnected
{
    _data = nil;
    [self finish];
}

@end
