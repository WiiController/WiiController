//
//  WiimoteEventDispatcher+Battery.m
//  Wiimote
//
//  Created by alxn1 on 30.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteEventDispatcher+Battery.h"
#import "WiimoteDelegate.h"

@implementation WiimoteEventDispatcher (Battery)

- (void)postBatteryLevelUpdateNotification:(CGFloat)batteryLevel isLow:(BOOL)isLow
{
    [self.delegate wiimote:self.owner batteryLevelUpdated:batteryLevel isLow:isLow];

    NSDictionary *params = @{
        WiimoteBatteryLevelKey : @(batteryLevel),
        WiimoteIsBatteryLevelLowKey : @(isLow)
    };

    [self postNotification:WiimoteBatteryLevelUpdatedNotification params:params];
}

@end
