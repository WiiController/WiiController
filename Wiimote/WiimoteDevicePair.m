//
//  WiimoteDevicePair.m
//  Wiimote
//
//  Created by alxn1 on 30.06.13.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteDevicePair.h"

#import <IOBluetooth/IOBluetooth.h>

#import "WiimoteLog.h"

@interface WiimoteDevicePairDelegate : NSObject <IOBluetoothDevicePairDelegate>

@end
    
@implementation WiimoteDevicePairDelegate {
    BOOL _isFirstAttempt;
}

void wiimotePairWithDevice(IOBluetoothDevice *device) {
    [[WiimoteDevicePairDelegate new] attemptPairWithDevice:device];
}

- (void)attemptPairWithDevice:(IOBluetoothDevice*)device
{
    __auto_type pairingAttempt = [IOBluetoothDevicePair pairWithDevice:device];
    pairingAttempt.delegate = self;

    if ([pairingAttempt start] != kIOReturnSuccess)
    {
        W_ERROR(@"[IOBluetoothDevicePair start] failed");
    }
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    _isFirstAttempt = YES;
    
    return self;
}

- (NSData*)makePINCodeForDevice:(IOBluetoothDevice*)device
{
	NSString *address;
	if (_isFirstAttempt)
        address = [IOBluetoothHostController defaultController].addressAsString;
    else
		address = device.addressString;

	NSArray *components = [address componentsSeparatedByString:@"-"];
	if (components.count != 6) return nil;
    
    uint8_t bytes[6] = { 0 };
	for (int i = 0; i < 6; i++)
	{
		NSScanner *scanner = [NSScanner scannerWithString:components[i]];
        unsigned int value = 0;
		[scanner scanHexInt:&value];
		bytes[5 - i] = (uint8_t)value;
	}

	return [NSData dataWithBytes:bytes length:sizeof(bytes)];
}

- (void)devicePairingPINCodeRequest:(IOBluetoothDevicePair *)sender
{
    NSData *data = [self makePINCodeForDevice:sender.device];
    BluetoothPINCode PIN = { 0 };
	[data getBytes:PIN.data length:sizeof PIN];
	[sender replyPINCode:data.length PINCode:&PIN];
}

- (void)devicePairingFinished:(IOBluetoothDevicePair *)sender error:(IOReturn)error
{
	if (error != kIOReturnSuccess)
	{
		if (_isFirstAttempt)
		{
			_isFirstAttempt = NO;
            [self attemptPairWithDevice:sender.device];
		} else {
            W_ERROR_F(@"failed with error: %i", error);
        }
	}
}

@end
