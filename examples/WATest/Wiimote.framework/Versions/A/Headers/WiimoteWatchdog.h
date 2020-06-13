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
{
    @private
        NSTimer *_timer;
        BOOL     _isPingNotificationEnabled;
}

+ (WiimoteWatchdog*)sharedWatchdog;

- (BOOL)isEnabled;
- (void)setEnabled:(BOOL)enabled;

- (BOOL)isPingNotificationEnabled;
- (void)setPingNotificationEnabled:(BOOL)enabled;

@end
