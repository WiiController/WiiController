//
//  WiimoteAccelerometer.m
//  Wiimote
//
//  Created by alxn1 on 06.08.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteAccelerometer+PlugIn.h"

@implementation WiimoteAccelerometer

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;

    [self setGravitySmoothQuant:0.15];
    [self setAnglesSmoothQuant:5.0];
    [self setHardwareZeroX:500 y:500 z:500];
    [self setHardware1gX:600 y:600 z:600];
    [self reset];

    return self;
}

- (void)setEnabled:(BOOL)enabled
{
    if (_enabled == enabled) return;

	[self reset];
    _enabled = enabled;

    [_delegate wiimoteAccelerometer:self enabledStateChanged:enabled];
}

@end
