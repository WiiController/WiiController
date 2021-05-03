//
//  WiimoteEventDispatcher+Accelerometer.m
//  Wiimote
//
//  Created by alxn1 on 03.08.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteEventDispatcher+Accelerometer.h"
#import "WiimoteDelegate.h"

@implementation WiimoteEventDispatcher (Accelerometer)

- (void)postAccelerometerEnabledNotification:(BOOL)enabled
{
    [self.delegate wiimote:self.owner accelerometerEnabledStateChanged:enabled];

    [self postNotification:WiimoteAccelerometerEnabledStateChangedNotification
                     param:@(enabled)
                       key:WiimoteAccelerometerEnabledStateKey];
}

- (void)postAccelerometerGravityChangedNotificationX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z
{
    [self.delegate wiimote:self.owner accelerometerChangedGravityX:x y:y z:z];

    if ([self isStateNotificationsEnabled])
    {
        NSDictionary *params = @{
            WiimoteAccelerometerGravityXKey : @(x),
            WiimoteAccelerometerGravityYKey : @(y),
            WiimoteAccelerometerGravityZKey : @(z)
        };

        [self postNotification:WiimoteAccelerometerGravityChangedNotification
                        params:params];
    }
}

- (void)postAccelerometerAnglesChangedNotificationPitch:(CGFloat)pitch roll:(CGFloat)roll
{
    [self.delegate wiimote:self.owner accelerometerChangedPitch:pitch roll:roll];

    if ([self isStateNotificationsEnabled])
    {
        NSDictionary *params = @{
            WiimoteAccelerometerPitchKey : @(pitch),
            WiimoteAccelerometerRollKey : @(roll)
        };

        [self postNotification:WiimoteAccelerometerAnglesChangedNotification
                        params:params];
    }
}

@end
