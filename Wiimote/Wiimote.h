//
//  Wiimote.h
//  Wiimote
//
//  Created by alxn1 on 29.07.12.
//  Copyright (c) 2012 alxn1. All rights reserved.
//

#import <Wiimote/WiimoteDelegate.h>
#import <Wiimote/WiimoteExtension.h>
#import <Wiimote/WiimoteAccelerometer.h>
#import <Wiimote/WiimoteWatchdog.h>
#import <Wiimote/WiimoteBluetooth.h>

#define WIIMOTE_INQUIRY_TIME_IN_SECONDS 10

FOUNDATION_EXPORT NSString *WiimoteBeginDiscoveryNotification;
FOUNDATION_EXPORT NSString *WiimoteEndDiscoveryNotification;

FOUNDATION_EXPORT NSString *WiimoteUseOneButtonClickConnectionChangedNotification;

FOUNDATION_EXPORT NSString *WiimoteUseOneButtonClickConnectionKey;

@class WiimoteDevice;
@class WiimotePartSet;
@class WiimoteIRPart;
@class WiimoteLEDPart;
@class WiimoteButtonPart;
@class WiimoteBatteryPart;
@class WiimoteVibrationPart;
@class WiimoteAccelerometerPart;
@class WiimoteExtensionPart;

@interface Wiimote : NSObject
{
    WiimoteDevice               *_device;
    WiimotePartSet              *_partSet;
    NSString                    *_modelName;

    WiimoteIRPart               *_iRPart;
    WiimoteLEDPart              *_lEDPart;
    WiimoteButtonPart           *_buttonPart;
    WiimoteBatteryPart          *_batteryPart;
    WiimoteVibrationPart        *_vibrationPart;
    WiimoteAccelerometerPart    *_accelerometerPart;
    WiimoteExtensionPart        *_extensionPart;

    NSDictionary                *_userInfo;
}

+ (NSArray*)supportedModelNames;

+ (BOOL)isUseOneButtonClickConnection;
+ (void)setUseOneButtonClickConnection:(BOOL)useOneButtonClickConnection;

+ (BOOL)isDiscovering;
+ (BOOL)beginDiscovery;

+ (NSArray*)connectedDevices;

@property(nonatomic,readonly,getter=isConnected) BOOL connected;
- (void)disconnect;

@property(nonatomic,readonly) BOOL isWiiUProController;
@property(nonatomic,readonly) BOOL isBalanceBoard;

@property(nonatomic,readonly) NSData *address;
@property(nonatomic,readonly) NSString *addressString;
@property(nonatomic,readonly) NSString *modelName;
@property(nonatomic,readonly) NSString *marketingName;

- (void)playConnectEffect;

// or'ed WiimoteLED flags
@property(nonatomic) NSUInteger highlightedLEDMask;

@property(nonatomic,getter=isVibrationEnabled) BOOL vibrationEnabled;

- (BOOL)isButtonPressed:(WiimoteButtonType)button;

// 0.0 - 100.0 %, or -1 if undefined
@property(nonatomic,readonly) CGFloat batteryLevel;
@property(nonatomic,readonly) NSString *batteryLevelDescription;
@property(nonatomic,readonly) BOOL isBatteryLevelLow;

@property(nonatomic,getter=isIREnabled) BOOL IREnabled;

- (WiimoteIRPoint*)irPoint:(NSUInteger)index;

@property(nonatomic,readonly) WiimoteAccelerometer *accelerometer;

@property(nonatomic,readonly) WiimoteExtension *connectedExtension;

- (void)detectMotionPlus;
- (void)reconnectExtension;
- (void)disconnectExtension;

- (void)requestUpdateState;

// disable all notifications, except begin/end discovery,
// battery level, extensions connect/disconnect and wiimote connect/disconnect
@property(nonatomic,readonly,getter=isStateChangeNotificationsEnabled) BOOL stateChangeNotificationsEnabled;

@property(nonatomic) NSDictionary *userInfo;

@property(nonatomic,weak) id <WiimoteDelegate> delegate;

@end
