//
//  WiimoteDeviceReadMemHandler.m
//  Wiimote
//
//  Created by alxn1 on 29.07.12.
//  Copyright (c) 2012 alxn1. All rights reserved.
//

#import "WiimoteDeviceReadMemHandler.h"
#import "WiimoteDevice.h"

@implementation WiimoteDeviceReadMemHandler

- (id)initWithMemoryRange:(NSRange)memoryRange
				   target:(id)target
				   action:(SEL)action
{
	self = [super init];
	if(self == nil)
		return nil;

	_memoryRange	= memoryRange;
	_readedData	= [[NSMutableData alloc] initWithCapacity:memoryRange.length];
	_target		= target;
	_action		= action;

	if(memoryRange.length == 0)
	{
		return nil;
	}

	return self;
}

- (void)dataReadFinished
{
	if(_target != nil &&
	   _action != nil)
	{
		[_target performSelector:_action
                       withObject:_readedData
                       afterDelay:0.0];
	}
}

- (NSRange)memoryRange
{
    return _memoryRange;
}

- (BOOL)isAllDataReaded
{
	return ([_readedData length] >= _memoryRange.length);
}

- (void)handleData:(const uint8_t*)data length:(NSUInteger)length
{
    [_readedData appendBytes:data length:length];
    if([_readedData length] >= _memoryRange.length)
		[self dataReadFinished];
}

- (void)errorOccured
{
    [_readedData setLength:0];
    [self dataReadFinished];
}

- (void)disconnected
{
    _readedData = nil;
    [self dataReadFinished];
}

@end
