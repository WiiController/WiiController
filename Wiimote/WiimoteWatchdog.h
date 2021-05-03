//
//  WiimoteWatchdog.h
//  Wiimote
//
//  Created by alxn1 on 27.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *WiimoteWatchdogEnabledChangedNotification;
FOUNDATION_EXPORT NSString *WiimoteWatchdogPingNotification;

@interface WiimoteWatchdog : NSObject

+ (WiimoteWatchdog *)sharedWatchdog;

@property(nonatomic, getter=isEnabled) BOOL enabled;
@property(nonatomic, getter=isPingNotificationEnabled) BOOL pingNotificationEnabled;

@end
