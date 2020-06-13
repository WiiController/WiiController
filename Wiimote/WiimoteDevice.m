//
//  WiimoteDevice.m
//  Wiimote
//
//  Created by alxn1 on 29.07.12.
//  Copyright (c) 2012 alxn1. All rights reserved.
//

#import "WiimoteDevice.h"
#import "WiimoteDeviceReadMemQueue.h"
#import "WiimoteDeviceTransport.h"

#import "WiimoteLog.h"
#import "WiimoteDeviceReport+Private.h"

@interface WiimoteDevice (PrivatePart)

- (void)handleReport:(WiimoteDeviceReport*)report;
- (void)handleDisconnect;

@end

@implementation WiimoteDevice

- (id)initWithTransport:(WiimoteDeviceTransport*)transport
{
    self = [super init];
	if(self == nil)
		return nil;

	if(transport == nil)
	{
		return nil;
	}

	_transport				= transport;
    _report                = [[WiimoteDeviceReport alloc] initWithDevice:self];
    _readMemQueue			= [[WiimoteDeviceReadMemQueue alloc] initWithDevice:self];
	_isConnected			= NO;
    _isVibrationEnabled    = NO;
    _lEDsState             = 0;
	_delegate				= nil;

	[_transport setDelegate:self];

	return self;
}

- (id)initWithHIDDevice:(W_HIDDevice*)device
{
	return [self initWithTransport:[WiimoteDeviceTransport withHIDDevice:device]];
}

- (id)initWithBluetoothDevice:(IOBluetoothDevice*)device
{
    return [self initWithTransport:[WiimoteDeviceTransport withBluetoothDevice:device]];
}

- (void)dealloc
{
	[self disconnect];
}

- (BOOL)isConnected
{
	return _isConnected;
}

- (BOOL)connect
{
	if([self isConnected])
		return YES;

	_isConnected = YES;

	if(![_transport open])
    {
        W_ERROR(@"can't open device");
		[self disconnect];
		_isConnected = NO;
        return NO;
    }

	return YES;
}

- (void)disconnect
{
	if(![self isConnected])
		return;

    _isConnected = NO;
    [_transport setDelegate:nil];
    [_transport close];

	[self handleDisconnect];
}

- (NSString*)name
{
    return [_transport name];
}

- (NSData*)address
{
	return [_transport address];
}

- (NSString*)addressString
{
    return [_transport addressString];
}

- (id)lowLevelDevice
{
    return [_transport lowLevelDevice];
}

- (BOOL)postCommand:(WiimoteDeviceCommandType)command
               data:(const uint8_t*)data
             length:(NSUInteger)length
{
    if(![self isConnected]  ||
        data    == NULL     ||
        length  == 0)
    {
		return NO;
    }

	uint8_t buffer[length + 1];

    buffer[0] = command;
    memcpy(buffer + 1, data, length);

    if(_isVibrationEnabled)
        buffer[1] |= WiimoteDeviceCommandFlagVibrationEnabled;
    else
        buffer[1] &= (~WiimoteDeviceCommandFlagVibrationEnabled);

	if(![_transport postBytes:buffer length:sizeof(buffer)])
    {
        W_ERROR(@"can't post data to device");
        return NO;
    }

    return YES;
}

- (BOOL)writeMemory:(NSUInteger)address
               data:(const uint8_t*)data
             length:(NSUInteger)length
{
    if(![self isConnected]  ||
        data    == NULL     ||
		length  > WiimoteDeviceWriteMemoryReportMaxDataSize)
	{
		return NO;
	}

    if(length == 0)
		return YES;

    uint8_t                          buffer[sizeof(WiimoteDeviceWriteMemoryParams)];
    WiimoteDeviceWriteMemoryParams  *params = (WiimoteDeviceWriteMemoryParams*)buffer;

    params->address = OSSwapHostToBigConstInt32(address);
    params->length  = length;
    memset(params->data, 0, sizeof(params->data));
    memcpy(params->data, data, length);

    return [self postCommand:WiimoteDeviceCommandTypeWriteMemory
						data:buffer
                      length:sizeof(buffer)];
}

- (BOOL)readMemory:(NSRange)memoryRange
            target:(id)target
            action:(SEL)action
{
    if(![self isConnected])
		return NO;

	return [_readMemQueue readMemory:memoryRange
							   target:target
							   action:action];
}

- (BOOL)requestStateReport
{
    uint8_t param = 0;

    return [self postCommand:WiimoteDeviceCommandTypeGetState
                        data:&param
                      length:sizeof(param)];
}

- (BOOL)requestReportType:(WiimoteDeviceReportType)type
{
	WiimoteDeviceSetReportTypeParams params;

    params.flags        = 0;
    params.reportType   = type;

    return [self postCommand:WiimoteDeviceCommandTypeSetReportType
						data:(const uint8_t*)&params
                      length:sizeof(params)];
}

- (BOOL)postVibrationAndLEDStates
{
    return [self postCommand:WiimoteDeviceCommandTypeSetLEDState
                        data:&_lEDsState
                      length:sizeof(_lEDsState)];
}

- (BOOL)isVibrationEnabled
{
    return _isVibrationEnabled;
}

- (BOOL)setVibrationEnabled:(BOOL)enabled
{
    if(_isVibrationEnabled == enabled)
        return YES;

    _isVibrationEnabled = enabled;
    if(![self postVibrationAndLEDStates])
    {
        _isVibrationEnabled = !enabled;
        return NO;
    }

    return YES;
}

- (uint8_t)LEDsState
{
    return _lEDsState;
}

- (BOOL)setLEDsState:(uint8_t)state
{
    uint8_t oldState = _lEDsState;

    _lEDsState = state;
    if(![self postVibrationAndLEDStates])
    {
        _lEDsState = oldState;
        return NO;
    }

    return YES;
}

- (id)delegate
{
	return _delegate;
}

- (void)setDelegate:(id)delegate
{
	_delegate = delegate;
}

@end

@implementation WiimoteDevice (PrivatePart)

- (void)handleReport:(WiimoteDeviceReport*)report
{
    [_readMemQueue handleReport:report];
	[_delegate wiimoteDevice:self handleReport:report];
}

- (void)handleDisconnect
{
    W_DEBUG(@"device disconnected");

    _isVibrationEnabled    = NO;
    _lEDsState             = 0;

    [_readMemQueue handleDisconnect];
	[_delegate performSelector:@selector(wiimoteDeviceDisconnected:)
					 withObject:self
					 afterDelay:0.5];
}

@end

@implementation WiimoteDevice (IOBluetoothL2CAPChannelDelegate)

- (void)wiimoteDeviceTransport:(WiimoteDeviceTransport*)transport
            reportDataReceived:(const uint8_t*)bytes
                        length:(NSUInteger)length
{
	if(![_report updateFromReportData:(const uint8_t*)bytes
                                length:length])
    {
        W_DEBUG(@"invalid report");
        return;
    }

	[self handleReport:_report];
}

- (void)wiimoteDeviceTransportDisconnected:(WiimoteDeviceTransport*)transport
{
	[self disconnect];
}

@end

@implementation NSObject (WiimoteDeviceDelegate)

- (void)wiimoteDevice:(WiimoteDevice*)device handleReport:(WiimoteDeviceReport*)report
{
}

- (void)wiimoteDeviceDisconnected:(WiimoteDevice*)device
{
}

@end
