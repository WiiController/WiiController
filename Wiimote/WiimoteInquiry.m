//
//  WiimoteInquiry.m
//  Wiimote
//
//  Created by alxn1 on 25.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteInquiry.h"
#import "WiimoteDevicePair.h"
#import "Wiimote+Create.h"

#import <IOBluetooth/IOBluetooth.h>
#import <HID/HIDManager.h>
#import <mach/mach_error.h>

#import "WiimoteLog.h"

#import <dlfcn.h>

#import <objc/message.h>

NSString *WiimoteDeviceName = @"Nintendo RVL-CNT-01";
NSString *WiimoteDeviceNameTR = @"Nintendo RVL-CNT-01-TR";
NSString *WiimoteDeviceNameUPro = @"Nintendo RVL-CNT-01-UC";
NSString *WiimoteDeviceNameBalanceBoard = @"Nintendo RVL-WBC-01";

@interface WiimoteInquiry () <IOBluetoothDeviceInquiryDelegate>
@end

@implementation WiimoteInquiry
{
    IOBluetoothDeviceInquiry *_inquiry;
    id _target;
    SEL _action;
}

+ (void)load
{
    [WiimoteInquiry registerSupportedModelName:WiimoteDeviceName];
    [WiimoteInquiry registerSupportedModelName:WiimoteDeviceNameTR];
    [WiimoteInquiry registerSupportedModelName:WiimoteDeviceNameUPro];
    [WiimoteInquiry registerSupportedModelName:WiimoteDeviceNameBalanceBoard];
}

+ (WiimoteInquiry *)sharedInquiry
{
    static WiimoteInquiry *result = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        result = [[WiimoteInquiry alloc] initInternal];
    });
    return result;
}

+ (NSMutableArray *)mutableSupportedModelNames
{
    static NSMutableArray *result = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        result = [[NSMutableArray alloc] init];
    });
    return result;
}

+ (NSArray *)supportedModelNames
{
    return [WiimoteInquiry mutableSupportedModelNames];
}

+ (void)registerSupportedModelName:(NSString *)name
{
    if (![[WiimoteInquiry mutableSupportedModelNames] containsObject:name])
        [[WiimoteInquiry mutableSupportedModelNames] addObject:name];
}

+ (BOOL)isModelSupported:(NSString *)name
{
    return [[self supportedModelNames] containsObject:name];
}

- (void)dealloc
{
    [self stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)isStarted
{
    return (_inquiry != nil);
}

- (BOOL)startWithTarget:(id)target didEndAction:(SEL)action
{
    if ([self isStarted]) return YES;
    if (!wiimoteIsBluetoothEnabled()) return NO;

    _inquiry = [IOBluetoothDeviceInquiry inquiryWithDelegate:self];

    [_inquiry setInquiryLength:WIIMOTE_INQUIRY_TIME_IN_SECONDS];
    [_inquiry setSearchCriteria:kBluetoothServiceClassMajorAny
               majorDeviceClass:kBluetoothDeviceClassMajorAny
               minorDeviceClass:kBluetoothDeviceClassMinorAny];

    if ([_inquiry start] != kIOReturnSuccess)
    {
        W_ERROR(@"[IOBluetoothDeviceInquiry start] failed");
        [self stop];
        return NO;
    }

    _target = target;
    _action = action;
    return YES;
}

- (BOOL)stop
{
    if (![self isStarted]) return YES;

    [_inquiry stop];
    [_inquiry setDelegate:nil];
    _inquiry = nil;

    return YES;
}

- (void)setUseOneButtonClickConnection:(BOOL)useOneButtonClickConnection
{
    _useOneButtonClickConnection = YES;
    return;

    if (_useOneButtonClickConnection == useOneButtonClickConnection)
        return;

    _useOneButtonClickConnection = useOneButtonClickConnection;

    if (_useOneButtonClickConnection)
        [self connectToPairedDevices];
}

- (void)hidManagerDeviceConnectedNotification:(NSNotification *)notification
{
    if (![self isUseOneButtonClickConnection])
        return;

    W_HIDDevice *device = [[notification userInfo] objectForKey:HIDManagerDeviceKey];
    NSString *deviceName = device.name;

    W_DEBUG_F(@"hid device connected: %@", deviceName);
    if ([WiimoteInquiry isModelSupported:deviceName])
    {
        W_DEBUG(@"connecting...");
        [Wiimote connectToHIDDevice:device];
    }
    else
        W_DEBUG(@"not supported");
}

- (id)initInternal
{
    self = [super init];
    if (self == nil)
        return nil;

    _inquiry = nil;
    _useOneButtonClickConnection = YES;

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(hidManagerDeviceConnectedNotification:)
               name:HIDManagerDeviceConnectedNotification
             object:[HIDManager manager]];

    return self;
}

- (void)postIgnoreHintToSystem:(IOBluetoothDeviceRef)device
{
    static void (*ignoreHIDDeviceFn)(IOBluetoothDeviceRef device) = NULL;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        ignoreHIDDeviceFn = dlsym(RTLD_DEFAULT, "IOBluetoothIgnoreHIDDevice");
    });

    if (ignoreHIDDeviceFn) ignoreHIDDeviceFn(device);
}

- (void)connectToDevices:(NSArray<IOBluetoothDevice *> *)devices
{
    for (IOBluetoothDevice *device in devices)
    {
        W_DEBUG_F(@"bluetooth device connected: %@", device.name);
        if ([WiimoteInquiry isModelSupported:device.name])
        {
            W_DEBUG(@"connecting...");
            [self postIgnoreHintToSystem:(__bridge IOBluetoothDeviceRef)(device)];
            [Wiimote connectToBluetoothDevice:device];
        }
        else
            W_DEBUG(@"not supported");
    }
}

- (void)pairWithDevices:(NSArray<IOBluetoothDevice *> *)devices
{
    for (IOBluetoothDevice *device in devices)
    {
        W_DEBUG_F(@"bluetooth device connected: %@", device.name);
        if ([WiimoteInquiry isModelSupported:device.name])
        {
            if (!device.isPaired)
            {
                W_DEBUG(@"pairing...");
                wiimotePairWithDevice(device);
            }
            else
                W_DEBUG(@"already paired");
        }
        else
            W_DEBUG(@"not supported");
    }
}

- (BOOL)isHIDDeviceAlreadyConnected:(W_HIDDevice *)device wiimotes:(NSArray *)wiimotes
{
    for (Wiimote *wiimote in wiimotes)
    {
        if (wiimote.lowLevelDevice == device) return YES;
    }
    return NO;
}

- (void)connectToPairedDevices
{
    NSEnumerator *en = [[[HIDManager manager] connectedDevices] objectEnumerator];
    W_HIDDevice *device = [en nextObject];
    NSArray *wiimotes = [Wiimote connectedDevices];

    while (device != nil)
    {
        W_DEBUG_F(@"hid device connected: %@", [device name]);
        if (![self isHIDDeviceAlreadyConnected:device wiimotes:wiimotes])
        {
            if ([WiimoteInquiry isModelSupported:[device name]])
            {
                W_DEBUG(@"connecting...");
                [Wiimote connectToHIDDevice:device];
            }
            else
                W_DEBUG(@"not supported");
        }
        else
            W_DEBUG(@"already connected");

        device = [en nextObject];
    }
}

// MARK: IOBluetoothInquiryDelegate

- (void)deviceInquiryDeviceFound:(IOBluetoothDeviceInquiry *)sender
                          device:(IOBluetoothDevice *)device
{
    if ([WiimoteInquiry isModelSupported:[device name]])
    {
        [self pairWithDevices:@[device]];
    }
}

- (void)deviceInquiryComplete:(IOBluetoothDeviceInquiry *)sender
                        error:(IOReturn)error
                      aborted:(BOOL)aborted
{
    if (error != kIOReturnSuccess)
        W_ERROR_F(@"inquiry failed: %s", mach_error_string(error));

    _inquiry = nil;

    if (_target != nil && _action != nil)
    {
        ((void (*)(id self, SEL _cmd))objc_msgSend)(_target, _action);
    }

    _target = nil;
    _action = nil;
}

@end
