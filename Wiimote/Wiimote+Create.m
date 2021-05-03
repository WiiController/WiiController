//
//  Wiimote+Create.m
//  Wiimote
//
//  Created by alxn1 on 30.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "Wiimote+Create.h"
#import "Wiimote+Tracking.h"
#import "Wiimote+PlugIn.h"

#import "WiimoteDevice.h"

#import "WiimoteIRPart.h"
#import "WiimoteLEDPart.h"
#import "WiimoteButtonPart.h"
#import "WiimoteBatteryPart.h"
#import "WiimoteVibrationPart.h"
#import "WiimoteAccelerometerPart.h"
#import "WiimoteExtensionPart.h"

#import "WiimotePartSet.h"

@interface Wiimote (Create_WiimoteDeviceDelegate) <WiimoteDeviceDelegate>

@end

@implementation Wiimote (Create)

- (void)initParts
{
    _iRPart            = (WiimoteIRPart*)              [self partWithClass:[WiimoteIRPart class]];
    _lEDPart           = (WiimoteLEDPart*)             [self partWithClass:[WiimoteLEDPart class]];
    _buttonPart        = (WiimoteButtonPart*)          [self partWithClass:[WiimoteButtonPart class]];
    _batteryPart       = (WiimoteBatteryPart*)         [self partWithClass:[WiimoteBatteryPart class]];
    _vibrationPart     = (WiimoteVibrationPart*)       [self partWithClass:[WiimoteVibrationPart class]];
    _accelerometerPart = (WiimoteAccelerometerPart*)   [self partWithClass:[WiimoteAccelerometerPart class]];
    _extensionPart     = (WiimoteExtensionPart*)       [self partWithClass:[WiimoteExtensionPart class]];

    [_lEDPart setDevice:_device];
	[_vibrationPart setDevice:_device];
}

- (id)initWithWiimoteDevice:(WiimoteDevice*)device
{
    self = [super init];
    if (!self) return nil;

    _device = device;
    _partSet = [[WiimotePartSet alloc] initWithOwner:self device:_device];
    _modelName = [device.transport.name copy];

    if (!_device || ![_device connect]) return nil;

    _device.delegate = self;

	[self initParts];
    [self requestUpdateState];
    [self deviceConfigurationChanged];

    [Wiimote wiimoteConnected:self];
	[[_partSet eventDispatcher] postConnectedNotification];

	[_partSet performSelector:@selector(connected)
					withObject:nil
					afterDelay:0.0];

    return self;
}

- (id)initWithHIDDevice:(W_HIDDevice*)device
{
    return [self initWithWiimoteDevice:
                        [[WiimoteDevice alloc]
                                    initWithHIDDevice:device]];
}

- (id)initWithBluetoothDevice:(IOBluetoothDevice*)device
{
    return [self initWithWiimoteDevice:
                        [[WiimoteDevice alloc]
                                    initWithBluetoothDevice:device]];
}

- (void)dealloc
{
    [_device disconnect];
}

+ (void)connectToHIDDevice:(W_HIDDevice*)device
{
    (void)[[Wiimote alloc] initWithHIDDevice:device];
}

+ (void)connectToBluetoothDevice:(IOBluetoothDevice*)device
{
    (void)[[Wiimote alloc] initWithBluetoothDevice:device];
}

- (id)lowLevelDevice
{
    return _device.transport.lowLevelDevice;
}

@end

// MARK: WiimoteDeviceDelegate
@implementation Wiimote (Create_WiimoteDeviceDelegate)

- (void)wiimoteDevice:(WiimoteDevice*)device handleReport:(WiimoteDeviceReport*)report
{
	[_partSet handleReport:report];
}

- (void)wiimoteDeviceDisconnected:(WiimoteDevice*)device
{
	[_partSet disconnected];
    [Wiimote wiimoteDisconnected:self];
	[[_partSet eventDispatcher] postDisconnectNotification];
}

@end
