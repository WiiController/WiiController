//
//  WiimoteBatteryPart.m
//  Wiimote
//
//  Created by alxn1 on 30.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteBatteryPart.h"
#import "WiimoteEventDispatcher+Battery.h"

@implementation WiimoteBatteryPart

+ (void)load
{
    [WiimotePart registerPartClass:[WiimoteBatteryPart class]];
}

- (id)initWithOwner:(Wiimote*)owner
    eventDispatcher:(WiimoteEventDispatcher*)dispatcher
          ioManager:(WiimoteIOManager*)ioManager
{
    self = [super initWithOwner:owner eventDispatcher:dispatcher ioManager:ioManager];
    if(self == nil)
        return nil;

    _level = -1.0;
    _isLow = NO;

    return self;
}

- (CGFloat)batteryLevel
{
    return _level;
}

- (BOOL)isBatteryLevelLow
{
    return _isLow;
}

- (void)handleReport:(WiimoteDeviceReport*)report
{
    if([report type]    != WiimoteDeviceReportTypeState ||
       [report length]  < sizeof(WiimoteDeviceStateReport))
    {
        return;
    }

    const WiimoteDeviceStateReport *state =
                (const WiimoteDeviceStateReport*)[report data];

    CGFloat batteryLevel        = (((CGFloat)state->batteryLevel) / ((CGFloat)WiimoteDeviceMaxBatteryLevel)) * 100.0f;
    BOOL    isBatteryLevelLow   = ((state->flagsAndLEDState & WiimoteDeviceStateReportFlagBatteryIsLow) != 0);

    if(batteryLevel < 0.0f)
        batteryLevel = 0.0f;

    if(batteryLevel > 100.0f)
        batteryLevel = 100.0f;

    if(batteryLevel         != _level ||
       isBatteryLevelLow    != _isLow)
    {
        _level = batteryLevel;
        _isLow = isBatteryLevelLow;

        [[self eventDispatcher] postBatteryLevelUpdateNotification:_level isLow:_isLow];
    }
}

- (void)disconnected
{
    _level = -1.0;
    _isLow = NO;
}

@end
