//
//  WiimoteDeviceTransport.m
//  Wiimote
//
//  Created by alxn1 on 10.07.13.
//  Copyright 2013 alxn1. All rights reserved.
//

#import "WiimoteDeviceTransport.h"

#import <IOBluetooth/IOBluetooth.h>

#import <HID/W_HIDDevice.h>

#import "WiimoteProtocol.h"

@interface WiimoteHIDDeviceTransport : NSObject <WiimoteDeviceTransport, W_HIDDeviceDelegate>
{
    W_HIDDevice *_device;
}

- (id)initWithHIDDevice:(W_HIDDevice*)device;

@end

@interface WiimoteBluetoothDeviceTransport : NSObject <WiimoteDeviceTransport>
{
    IOBluetoothDevice       *_device;
    IOBluetoothL2CAPChannel *_dataChannel;
    IOBluetoothL2CAPChannel *_controlChannel;

    BOOL                     _isOpen;
}

- (id)initWithBluetoothDevice:(IOBluetoothDevice*)device;

@end

@implementation WiimoteHIDDeviceTransport

@synthesize delegate;

- (id)initWithHIDDevice:(W_HIDDevice*)device
{
    self = [super init];

    if(self == nil)
        return nil;

    if(device == nil)
    {
        return nil;
    }

    _device = device;

    return self;
}


- (NSString*)name
{
    return [_device name];
}

- (NSData*)address
{
	NSString	*address		= [self addressString];
	NSArray		*components		= nil;
	uint8_t		 bytes[6]		= { 0 };
	unsigned int value			= 0;

	components = [address componentsSeparatedByString:@"-"];
	if([components count] != sizeof(bytes))
		return nil;

	for(int i = 0; i < sizeof(bytes); i++)
	{
		NSScanner *scanner = [[NSScanner alloc] initWithString:[components objectAtIndex:i]];
		[scanner scanHexInt:&value];
		bytes[i] = (uint8_t)value;
	}

	return [NSData dataWithBytes:bytes length:sizeof(bytes)];
}

- (NSString*)addressString
{
    return [_device address];
}

- (id)lowLevelDevice
{
    return _device;
}

- (BOOL)isOpen
{
    return [_device isValid];
}

- (BOOL)open
{
    return [_device setOptions:kIOHIDOptionsTypeSeizeDevice];
}

- (void)close
{
    if([self isOpen])
    {
        BluetoothDeviceAddress address = { 0 };

        [[self address] getBytes:address.data length:sizeof(address.data)];
        [[IOBluetoothDevice deviceWithAddress:&address] closeConnection];
        [_device invalidate];
    }
}

- (BOOL)postBytes:(const uint8_t*)bytes length:(NSUInteger)length
{
    return [_device postBytes:bytes length:length];
}

- (void)HIDDevice:(W_HIDDevice*)device reportDataReceived:(const uint8_t*)bytes length:(NSUInteger)length
{
    [[self delegate] wiimoteDeviceTransport:self reportDataReceived:bytes length:length];
}

- (void)HIDDeviceDisconnected:(W_HIDDevice*)device
{
    [[self delegate] wiimoteDeviceTransportDisconnected:self];
}

@end

@implementation WiimoteBluetoothDeviceTransport

@synthesize delegate;

- (id)initWithBluetoothDevice:(IOBluetoothDevice*)device
{
    self = [super init];

    if(self == nil)
        return nil;

    if(device == nil)
    {
        return nil;
    }

    _device            = device;
	_dataChannel       = nil;
	_controlChannel    = nil;
    _isOpen            = NO;

    return self;
}

- (void)dealloc
{
    [self close];
}

- (IOBluetoothL2CAPChannel*)openChannel:(BluetoothL2CAPPSM)channelID
{
	IOBluetoothL2CAPChannel *result = nil;

	if([_device openL2CAPChannelSync:&result
                              withPSM:channelID
                             delegate:self] != kIOReturnSuccess)
    {
		return nil;
    }

	return result;
}

- (NSString*)name
{
    return [_device name];
}

- (NSData*)address
{
    const BluetoothDeviceAddress *address = [_device getAddress];
    if(address == NULL)
        return nil;

    return [NSData dataWithBytes:address->data
                          length:sizeof(address->data)];
}

- (NSString*)addressString
{
    return [_device addressString];
}

- (id)lowLevelDevice
{
    return _device;
}

- (BOOL)isOpen
{
    return _isOpen;
}

- (BOOL)open
{
    if([self isOpen])
		return YES;

	_isOpen            = YES;
	_controlChannel	= [self openChannel:kBluetoothL2CAPPSMHIDControl];
	_dataChannel		= [self openChannel:kBluetoothL2CAPPSMHIDInterrupt];

	if(_controlChannel == nil || _dataChannel    == nil)
    {
		[self close];
        return NO;
    }

	return YES;
}

- (void)close
{
    if(![self isOpen])
        return;

    [_controlChannel setDelegate:nil];
	[_dataChannel setDelegate:nil];

	[_controlChannel closeChannel];
	[_dataChannel closeChannel];
	[_device closeConnection];

	_isOpen = NO;

	[[self delegate] wiimoteDeviceTransportDisconnected:self];
}

- (BOOL)postBytes:(const uint8_t*)bytes length:(NSUInteger)length
{
    if(![self isOpen] || bytes == NULL)
		return NO;

    if(length == 0)
		return YES;

    uint8_t buffer[length + 1];

    buffer[0] = 0xA2; // 0xA2 - HID output report
    memcpy(buffer + 1, bytes, length);

    return ([_dataChannel
                    writeSync:buffer
                       length:sizeof(buffer)] == kIOReturnSuccess);
}

- (void)l2capChannelData:(IOBluetoothL2CAPChannel*)l2capChannel
                    data:(void*)dataPointer
                  length:(size_t)dataLength
{
    const uint8_t *data     = (const uint8_t*)dataPointer;
    size_t         length   = dataLength;

    if(length < 2)
        return;

    [[self delegate] wiimoteDeviceTransport:self reportDataReceived:data + 1 length:length - 1];
}

- (void)l2capChannelClosed:(IOBluetoothL2CAPChannel*)l2capChannel
{
    [self close];
}

@end

id <WiimoteDeviceTransport> wiimoteDeviceTransportWithHIDDevice(W_HIDDevice *device)
{
    return [[WiimoteHIDDeviceTransport alloc] initWithHIDDevice:device];
}

id <WiimoteDeviceTransport> wiimoteDeviceTransportWithBluetoothDevice(IOBluetoothDevice *device)
{
    return [[WiimoteBluetoothDeviceTransport alloc] initWithBluetoothDevice:device];
}
