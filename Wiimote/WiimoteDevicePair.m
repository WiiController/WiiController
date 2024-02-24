//
//  WiimoteDevicePair.m
//  Wiimote
//
//  Created by alxn1 on 30.06.13.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteDevicePair.h"

#import <IOBluetooth/IOBluetooth.h>
#import "IOBluetoothCoreBluetoothCoordinator+Private.h"
#import "IOBluetoothDevice+Private.h"
#import "IOBluetoothDevicePair+Private.h"

#import "WiimoteLog.h"

// Most of the pairing code for macOS 12+ is from https://github.com/dolphin-emu/WiimotePair

@interface WiimoteDevicePairDelegate : NSObject <IOBluetoothDevicePairDelegate>

@property() void(^onFinish)(WiimoteDevicePairDelegate *);

- (void)attemptPairWithDevice:(IOBluetoothDevice *)device;

@end

static NSMapTable *_globalPairDelegates;

void wiimotePairWithDevice(IOBluetoothDevice *device)
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _globalPairDelegates = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsOpaquePersonality valueOptions:NSPointerFunctionsStrongMemory];
    });

    __auto_type pairDelegate = [WiimoteDevicePairDelegate new];
    [_globalPairDelegates setObject:pairDelegate forKey:pairDelegate];

    [pairDelegate attemptPairWithDevice:device];
    pairDelegate.onFinish = ^(WiimoteDevicePairDelegate *sender){
        [_globalPairDelegates removeObjectForKey:sender];
    };
}

@implementation WiimoteDevicePairDelegate
{
    BOOL _isFirstAttempt;
    IOBluetoothDevicePair *_pair;
}

- (void)attemptPairWithDevice:(IOBluetoothDevice *)device
{
    _pair = [IOBluetoothDevicePair pairWithDevice:device];
    _pair.delegate = self;

    // We need to call this private API to ensure that the delegate is always queried for the PIN.
    [_pair setUserDefinedPincode:YES];

    if ([_pair start] != kIOReturnSuccess)
    {
        W_ERROR(@"[IOBluetoothDevicePair start] failed");
    }
}

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;

    _isFirstAttempt = YES;

    return self;
}

- (void)devicePairingPINCodeRequest:(IOBluetoothDevicePair *)sender
{
    W_DEBUG_F(@"sending PIN code to %@", [sender device]);
    
    IOBluetoothDevicePair* pair = (IOBluetoothDevicePair*)sender;
    IOBluetoothDevice* device = [sender device];
    
    IOBluetoothHostController* controller = [IOBluetoothHostController defaultController];
    
    NSString* controllerAddressStr;
    if (_isFirstAttempt)
        controllerAddressStr = controller.addressAsString;
    else
        controllerAddressStr = device.addressString;
    
    BluetoothDeviceAddress controllerAddress;
    IOBluetoothNSStringToDeviceAddress(controllerAddressStr, &controllerAddress);
    
    BluetoothPINCode code;
    memset(&code, 0, sizeof(code));
    
    // When using the SYNC button, the PIN is the address of the Bluetooth controller in reverse.
    for (int i = 0; i < 6; i++) {
        code.data[i] = controllerAddress.data[5 - i];
    }
    
    uint64_t key;
    memcpy(&key, code.data, sizeof(key));
    
    // This is what [_devicePair replyPINCode:PINCode:] essentially does.
    // However, that method does a bunch of NSString-ification on the PIN code first.
    // We don't want this, so we replicate its behaviour here while skipping the NSString stuff.
    [[IOBluetoothCoreBluetoothCoordinator sharedInstance] pairPeer:[device classicPeer] forType:[pair currentPairingType] withKey:@(key)];
}

- (void)devicePairingFinished:(IOBluetoothDevicePair *)sender error:(IOReturn)error
{
    if (error != kIOReturnSuccess)
    {
        if (_isFirstAttempt)
        {
            _isFirstAttempt = NO;
            [self attemptPairWithDevice:sender.device];
        }
        else
        {
            W_ERROR_F(@"failed with error: %i", error);
        }
    }

    _pair = nil;
    if (self.onFinish)
        self.onFinish(self);
}

@end
