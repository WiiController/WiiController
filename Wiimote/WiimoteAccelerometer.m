//
//  WiimoteAccelerometer.m
//  Wiimote
//
//  Created by alxn1 on 06.08.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteAccelerometer+PlugIn.h"

@implementation WiimoteAccelerometer

- (id)init
{
    self = [super init];
    if(self == nil)
        return nil;

    _isEnabled = NO;
    [self setGravitySmoothQuant:0.15];
    [self setAnglesSmoothQuant:5.0];
    [self setHardwareZeroX:500 y:500 z:500];
    [self setHardware1gX:600 y:600 z:600];
    [self reset];

    return self;
}

- (BOOL)isEnabled
{
    return _isEnabled;
}

- (void)setEnabled:(BOOL)enabled
{
    if(_isEnabled == enabled)
        return;

	[self reset];
    _isEnabled = enabled;

    [_delegate wiimoteAccelerometer:self enabledStateChanged:enabled];
}

- (CGFloat)gravityX
{
    return _gravityX;
}

- (CGFloat)gravityY
{
    return _gravityY;
}

- (CGFloat)gravityZ
{
    return _gravityZ;
}

- (CGFloat)pitch
{
    return _pitch;
}

- (CGFloat)roll
{
    return _roll;
}

- (CGFloat)gravitySmoothQuant
{
    return _gravitySmoothQuant;
}

- (void)setGravitySmoothQuant:(CGFloat)quant
{
    _gravitySmoothQuant = quant;
}

- (CGFloat)anglesSmoothQuant
{
    return _anglesSmoothQuant;
}

- (void)setAnglesSmoothQuant:(CGFloat)quant
{
    _anglesSmoothQuant = quant;
}

@end
