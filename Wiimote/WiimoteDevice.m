//
//  WiimoteDevice.m
//  Wiimote
//
//  Created by alxn1 on 29.07.12.
//  Copyright (c) 2012 alxn1. All rights reserved.
//

#import "WiimoteDevice.h"
#import "WiimoteDeviceReadQueue.h"

#import "WiimoteLog.h"
#import "WiimoteDeviceReport+Private.h"

@interface WiimoteDevice () <WiimoteDeviceTransportDelegate>

@end

@implementation WiimoteDevice
{
    id <WiimoteDeviceTransport> _transport;

    WiimoteDeviceReport *_report;
    WiimoteDeviceReadQueue *_readQueue;
    
    uint8_t _LEDsState;
}

- (instancetype)initWithTransport:(id <WiimoteDeviceTransport>)transport
{
    self = [super init];
	if (!self) return nil;

	if (!transport) return nil;

	_transport = transport;
    _report = [[WiimoteDeviceReport alloc] initWithDevice:self];
    _readQueue = [[WiimoteDeviceReadQueue alloc] initWithDevice:self];

    _transport.delegate = self;

	return self;
}

- (instancetype)initWithHIDDevice:(W_HIDDevice*)device
{
	return [self initWithTransport:wiimoteDeviceTransportWithHIDDevice(device)];
}

- (instancetype)initWithBluetoothDevice:(IOBluetoothDevice*)device
{
    return [self initWithTransport:wiimoteDeviceTransportWithBluetoothDevice(device)];
}

- (void)dealloc
{
	[self disconnect];
}

- (BOOL)connect
{
	if (_transport.isOpen) return YES;

	if (![_transport open])
    {
        W_ERROR(@"can't open device");
		[self disconnect];
        return NO;
    }

	return YES;
}

- (void)disconnect
{
	if (!_transport.isOpen) return;

    _transport.delegate = nil;
    [_transport close];

    W_DEBUG(@"device disconnected");

    _isVibrationEnabled = NO;
    _LEDsState = 0;

    [_readQueue handleDisconnect];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->_delegate wiimoteDeviceDisconnected:self];
    });
}

- (BOOL)postCommand:(WiimoteDeviceCommandType)command
               data:(const uint8_t*)data
             length:(NSUInteger)length
{
    if (!_transport.isOpen || !data || length == 0) return NO;

	uint8_t buffer[length + 1];

    buffer[0] = command;
    memcpy(buffer + 1, data, length);

    if (_isVibrationEnabled) buffer[1] |= WiimoteDeviceCommandFlagVibrationEnabled;
    else buffer[1] &= (~WiimoteDeviceCommandFlagVibrationEnabled);

	if (![_transport postBytes:buffer length:sizeof(buffer)])
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
    if (!_transport.isOpen || data == NULL || length > WiimoteDeviceWriteMemoryReportMaxDataSize)
	{
		return NO;
	}

    if (length == 0) return YES;

    uint8_t buffer[sizeof(WiimoteDeviceWriteMemoryParams)];
    WiimoteDeviceWriteMemoryParams *params = (WiimoteDeviceWriteMemoryParams*)buffer;

    params->address = OSSwapHostToBigConstInt32(address);
    params->length = length;
    memset(params->data, 0, sizeof(params->data));
    memcpy(params->data, data, length);

    return [self postCommand:WiimoteDeviceCommandTypeWriteMemory
						data:buffer
                      length:sizeof(buffer)];
}

- (BOOL)readMemory:(NSRange)memoryRange
              then:(WiimoteDeviceReadCallback)callback
{
    if (!_transport.isOpen) return NO;

	return [_readQueue readMemory:memoryRange then:callback];
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

    params.flags = 0;
    params.reportType = type;

    return [self postCommand:WiimoteDeviceCommandTypeSetReportType
						data:(const uint8_t*)&params
                      length:sizeof(params)];
}

- (BOOL)postVibrationAndLEDStates
{
    return [self postCommand:WiimoteDeviceCommandTypeSetLEDState
                        data:&_LEDsState
                      length:sizeof(_LEDsState)];
}

- (BOOL)setVibrationEnabled:(BOOL)enabled
{
    if (_isVibrationEnabled == enabled) return YES;

    _isVibrationEnabled = enabled;
    if (![self postVibrationAndLEDStates])
    {
        _isVibrationEnabled = !enabled;
        return NO;
    }

    return YES;
}

- (uint8_t)LEDsState
{
    return _LEDsState;
}

- (BOOL)setLEDsState:(uint8_t)state
{
    uint8_t oldState = _LEDsState;

    _LEDsState = state;
    if(![self postVibrationAndLEDStates])
    {
        _LEDsState = oldState;
        return NO;
    }

    return YES;
}

// MARK: Private

- (void)handleReport:(WiimoteDeviceReport*)report
{
    [_readQueue handleReport:report];
	[_delegate wiimoteDevice:self handleReport:report];
}

// MARK: WiimoteDeviceTransportDelegate

- (void)wiimoteDeviceTransport:(id <WiimoteDeviceTransport>)transport
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

- (void)wiimoteDeviceTransportDisconnected:(id <WiimoteDeviceTransport>)transport
{
	[self disconnect];
}

@end
