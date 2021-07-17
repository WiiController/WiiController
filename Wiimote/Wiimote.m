//
//  Wiimote.m
//  Wiimote
//
//  Created by alxn1 on 29.07.12.
//  Copyright (c) 2012 alxn1. All rights reserved.
//

#import "Wiimote.h"
#import "Wiimote+Tracking.h"
#import "WiimoteDevice.h"
#import "WiimotePartSet.h"
#import "WiimoteInquiry.h"

#import "WiimoteIRPart.h"
#import "WiimoteLEDPart.h"
#import "WiimoteButtonPart.h"
#import "WiimoteBatteryPart.h"
#import "WiimoteVibrationPart.h"
#import "WiimoteAccelerometerPart.h"
#import "WiimoteExtensionPart.h"

NSString *WiimoteBeginDiscoveryNotification = @"WiimoteBeginDiscoveryNotification";
NSString *WiimoteEndDiscoveryNotification = @"WiimoteEndDiscoveryNotification";

NSString *WiimoteUseOneButtonClickConnectionChangedNotification = @"WiimoteUseOneButtonClickConnectionChangedNotification";

NSString *WiimoteUseOneButtonClickConnectionKey = @"WiimoteUseOneButtonClickConnectionKey";

@implementation Wiimote

+ (NSArray *)supportedModelNames
{
    return [WiimoteInquiry supportedModelNames];
}

+ (BOOL)isUseOneButtonClickConnection
{
    return [[WiimoteInquiry sharedInquiry] isUseOneButtonClickConnection];
}

+ (void)setUseOneButtonClickConnection:(BOOL)useOneButtonClickConnection
{
    if ([Wiimote isUseOneButtonClickConnection] == useOneButtonClickConnection)
        return;

    NSDictionary *userInfo = @{ WiimoteUseOneButtonClickConnectionKey : @(useOneButtonClickConnection) };

    [[WiimoteInquiry sharedInquiry] setUseOneButtonClickConnection:useOneButtonClickConnection];

    [[NSNotificationCenter defaultCenter]
        postNotificationName:WiimoteUseOneButtonClickConnectionChangedNotification
                      object:nil
                    userInfo:userInfo];
}

+ (BOOL)isDiscovering
{
    return [[WiimoteInquiry sharedInquiry] isStarted];
}

+ (BOOL)beginDiscovery
{
    if (![[WiimoteInquiry sharedInquiry]
            startWithTarget:self
               didEndAction:@selector(discoveryFinished)])
    {
        return NO;
    }

    [[NSNotificationCenter defaultCenter]
        postNotificationName:WiimoteBeginDiscoveryNotification
                      object:self];

    return YES;
}

+ (void)discoveryFinished
{
    [[NSNotificationCenter defaultCenter]
        postNotificationName:WiimoteEndDiscoveryNotification
                      object:self];
}

+ (NSArray *)connectedDevices
{
    return [Wiimote connectedWiimotes];
}

- (void)dealloc
{
    [self setVibrationEnabled:NO];
    [_device disconnect];
}

- (BOOL)isConnected
{
    return _device.transport.isOpen;
}

- (void)disconnect
{
    [_device disconnect];
}

- (BOOL)isWiiUProController
{
    return [_modelName isEqualToString:WiimoteDeviceNameUPro];
}

- (BOOL)isBalanceBoard
{
    return [_modelName isEqualToString:WiimoteDeviceNameBalanceBoard];
}

- (NSData *)address
{
    return _device.transport.address;
}

- (NSString *)addressString
{
    return _device.transport.addressString;
}

- (NSString *)modelName
{
    return _modelName;
}

- (NSString *)marketingName
{
    return @{
        WiimoteDeviceName : @"Wii Remote",
        WiimoteDeviceNameTR : @"Wii Remote Plus",
        WiimoteDeviceNameUPro : @"Wii U Pro Controller",
        WiimoteDeviceNameBalanceBoard : @"Wii Balance Board"
    }[_modelName]
        ?: _modelName;
}

- (void)playConnectEffect
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setVibrationEnabled:NO];
    });
    [self setVibrationEnabled:YES];
}

- (NSUInteger)highlightedLEDMask
{
    return [_lEDPart highlightedLEDMask];
}

- (void)setHighlightedLEDMask:(NSUInteger)mask
{
    [_lEDPart setHighlightedLEDMask:mask];
}

- (BOOL)isVibrationEnabled
{
    return [_vibrationPart isVibrationEnabled];
}

- (void)setVibrationEnabled:(BOOL)enabled
{
    [_vibrationPart setVibrationEnabled:enabled];
}

- (BOOL)isButtonPressed:(WiimoteButtonType)button
{
    return [_buttonPart isButtonPressed:button];
}

- (CGFloat)batteryLevel
{
    return [_batteryPart batteryLevel];
}

- (NSString *)batteryLevelDescription
{
    __auto_type batteryLevel = [self batteryLevel];
    return batteryLevel >= 0.0 ? [NSString stringWithFormat:@"%.0lf%%", batteryLevel]
                               : @"–";
}

- (BOOL)isBatteryLevelLow
{
    return [_batteryPart isBatteryLevelLow];
}

- (BOOL)isIREnabled
{
    return [_iRPart isEnabled];
}

- (void)setIREnabled:(BOOL)enabled
{
    [_iRPart setEnabled:enabled];
}

- (WiimoteIRPoint *)irPoint:(NSUInteger)index
{
    return [_iRPart point:index];
}

- (WiimoteAccelerometer *)accelerometer
{
    return [_accelerometerPart accelerometer];
}

- (WiimoteExtension *)connectedExtension
{
    return [_extensionPart connectedExtension];
}

- (void)detectMotionPlus
{
    [_extensionPart detectMotionPlus];
}

- (void)reconnectExtension
{
    [_extensionPart reconnectExtension];
}

- (void)disconnectExtension
{
    [_extensionPart disconnectExtension];
}

- (void)requestUpdateState
{
    [_device requestStateReport];
}

- (BOOL)isStateChangeNotificationsEnabled
{
    return [[_partSet eventDispatcher] isStateNotificationsEnabled];
}

- (void)setStateChangeNotificationsEnabled:(BOOL)enabled
{
    [[_partSet eventDispatcher] setStateNotificationsEnabled:enabled];
}

- (NSDictionary *)userInfo
{
    return _userInfo;
}

- (void)setUserInfo:(NSDictionary *)userInfo
{
    if (_userInfo == userInfo)
        return;

    _userInfo = userInfo;
}

- (id)delegate
{
    return [[_partSet eventDispatcher] delegate];
}

- (void)setDelegate:(id)delegate
{
    [[_partSet eventDispatcher] setDelegate:delegate];
}

@end
