//
//  WiimoteAccelerometer+PlugIn.m
//  Wiimote
//
//  Created by alxn1 on 06.08.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteAccelerometer+PlugIn.h"

@interface WiimoteAccelerometer (PrivatePart)

- (void)setGravityX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z;
- (void)setPitch:(CGFloat)pitch roll:(CGFloat)roll;

@end

@implementation WiimoteAccelerometer (PlugIn)

- (void)setHardwareValueX:(uint16_t)x y:(uint16_t)y z:(uint16_t)z
{
    CGFloat newX = (((CGFloat)x) - ((CGFloat)_zeroX)) / (((CGFloat)m_1gX) - ((CGFloat)_zeroX));
    CGFloat newY = (((CGFloat)y) - ((CGFloat)_zeroY)) / (((CGFloat)m_1gY) - ((CGFloat)_zeroY));
    CGFloat newZ = (((CGFloat)z) - ((CGFloat)_zeroZ)) / (((CGFloat)m_1gZ) - ((CGFloat)_zeroZ));

    [self setGravityX:newX y:newY z:newZ];

    if(newX < -1.0) newX = 1.0; else
    if(newX >  1.0) newX = 1.0;

    if(newY < -1.0) newY = 1.0; else
    if(newY >  1.0) newY = 1.0;

    if(newZ < -1.0) newZ = 1.0; else
    if(newZ >  1.0) newZ = 1.0;

    CGFloat newPitch = _pitch;
    CGFloat newRoll  = _roll;

    if(abs(x - _zeroX) <= (m_1gX - _zeroX))
        newRoll  = (atan2(newX, newZ) * 180.0) / M_PI;

    if(abs(y - _zeroY) <= (m_1gY - _zeroY))
        newPitch = (atan2(newY, newZ) * 180.0) / M_PI;

    [self setPitch:newPitch roll:newRoll];
}

- (void)setHardwareZeroX:(uint16_t)x y:(uint16_t)y z:(uint16_t)z
{
    _zeroX = x;
    _zeroY = y;
    _zeroZ = z;
}

- (void)setHardware1gX:(uint16_t)x y:(uint16_t)y z:(uint16_t)z
{
    m_1gX = x;
    m_1gY = y;
    m_1gZ = z;
}

- (void)setCalibrationData:(const WiimoteDeviceAccelerometerCalibrationData*)calibrationData
{
    uint16_t zeroX  = (((uint16_t)calibrationData->zero.x) << 2) | ((calibrationData->zero.additionalXYZ >> 0) & 0x3);
    uint16_t zeroY  = (((uint16_t)calibrationData->zero.y) << 2) | ((calibrationData->zero.additionalXYZ >> 2) & 0x3);
    uint16_t zeroZ  = (((uint16_t)calibrationData->zero.z) << 2) | ((calibrationData->zero.additionalXYZ >> 4) & 0x3);

    uint16_t gX     = (((uint16_t)calibrationData->oneG.x) << 2) | ((calibrationData->oneG.additionalXYZ >> 0) & 0x3);
    uint16_t gY     = (((uint16_t)calibrationData->oneG.y) << 2) | ((calibrationData->oneG.additionalXYZ >> 2) & 0x3);
    uint16_t gZ     = (((uint16_t)calibrationData->oneG.z) << 2) | ((calibrationData->oneG.additionalXYZ >> 4) & 0x3);

    [self setHardwareZeroX:zeroX y:zeroY z:zeroZ];
    [self setHardware1gX:gX y:gY z:gZ];
}

- (BOOL)isHardwareZeroValuesInvalid
{
    return (_zeroX == 0 ||
            _zeroY == 0 ||
            _zeroZ == 0);
}

- (BOOL)isHardware1gValuesInvalid
{
    return (m_1gX == 0 ||
            m_1gY == 0 ||
            m_1gZ == 0);
}

- (void)reset
{
    _gravityX  = 0.0;
    _gravityY  = 0.0;
    _gravityZ  = 0.0;

    _pitch     = 0.0;
    _roll      = 0.0;

    _isEnabled = NO;
}

@end

@implementation WiimoteAccelerometer (PrivatePart)

- (void)setGravityX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z
{
    x = (((CGFloat)((long long)(x / _gravitySmoothQuant))) * _gravitySmoothQuant);
    y = (((CGFloat)((long long)(y / _gravitySmoothQuant))) * _gravitySmoothQuant);
    z = (((CGFloat)((long long)(z / _gravitySmoothQuant))) * _gravitySmoothQuant);

    if(WiimoteDeviceIsFloatEqualEx(_gravityX, x, _gravitySmoothQuant) &&
       WiimoteDeviceIsFloatEqualEx(_gravityY, y, _gravitySmoothQuant) &&
       WiimoteDeviceIsFloatEqualEx(_gravityZ, z, _gravitySmoothQuant))
    {
        return;
    }

    _gravityX = x;
    _gravityY = y;
    _gravityZ = z;

    [_delegate wiimoteAccelerometer:self gravityChangedX:x y:y z:z];
}

- (void)setPitch:(CGFloat)pitch roll:(CGFloat)roll
{
    pitch = (((CGFloat)((long long)(pitch / _anglesSmoothQuant))) * _anglesSmoothQuant);
    roll  = (((CGFloat)((long long)(roll  / _anglesSmoothQuant))) * _anglesSmoothQuant);

    if(WiimoteDeviceIsFloatEqualEx(_pitch, pitch, _anglesSmoothQuant) &&
       WiimoteDeviceIsFloatEqualEx(_roll,	roll,  _anglesSmoothQuant))
    {
        return;
    }

    _pitch = pitch;
    _roll  = roll;

    [_delegate wiimoteAccelerometer:self pitchChanged:pitch roll:roll];
}

@end

@implementation NSObject (WiimoteAccelerometerDelegate)

- (void)wiimoteAccelerometer:(WiimoteAccelerometer*)accelerometer
         enabledStateChanged:(BOOL)enabled
{
}

- (void)wiimoteAccelerometer:(WiimoteAccelerometer*)accelerometer
             gravityChangedX:(CGFloat)x
                           y:(CGFloat)y
                           z:(CGFloat)z
{
}

- (void)wiimoteAccelerometer:(WiimoteAccelerometer*)accelerometer
                pitchChanged:(CGFloat)pitch
                        roll:(CGFloat)roll
{
}

@end
