//
//  WiimoteNunchuck.m
//  Wiimote
//
//  Created by alxn1 on 31.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteNunchuck.h"
#import "WiimoteAccelerometer+PlugIn.h"
#import "Wiimote.h"

@interface WiimoteNunchuck () <WiimoteAccelerometerDelegate>

@end

@implementation WiimoteNunchuck
{
    BOOL _isCalibrationDataRead;

    BOOL _buttonState[WiimoteNunchuckButtonCount];

    NSPoint _stickPosition;
    WiimoteDeviceStickCalibrationData _stickCalibrationData;

    WiimoteAccelerometer *_accelerometer;
}

+ (void)load
{
    [WiimoteExtension registerExtensionClass:[WiimoteNunchuck class]];
}

+ (NSArray*)extensionSignatures
{
	static const uint8_t  signature[]	= { 0x00, 0x00, 0xA4, 0x20, 0x00, 0x00 };
	static const uint8_t  signature2[]	= { 0xFF, 0x00, 0xA4, 0x20, 0x00, 0x00 };

	static NSArray *result = nil;

	if(result == nil)
	{
		result = [[NSArray alloc] initWithObjects:
					[NSData dataWithBytes:signature  length:sizeof(signature)],
					[NSData dataWithBytes:signature2 length:sizeof(signature2)],
					nil];
	}

	return result;
}

+ (NSRange)calibrationDataMemoryRange
{
    return NSMakeRange(
				WiimoteDeviceRoutineExtensionCalibrationDataAddress,
                WiimoteDeviceRoutineExtensionCalibrationDataSize);
}

+ (WiimoteExtensionMeritClass)meritClass
{
    return WiimoteExtensionMeritClassSystem;
}

+ (NSUInteger)minReportDataSize
{
    return sizeof(WiimoteDeviceNunchuckReport);
}

- (id)initWithOwner:(Wiimote*)owner
    eventDispatcher:(WiimoteEventDispatcher*)dispatcher
{
    self = [super initWithOwner:owner eventDispatcher:dispatcher];
    if(self == nil)
        return nil;

	_isCalibrationDataRead	= NO;
    _accelerometer             = [[WiimoteAccelerometer alloc] init];

    _accelerometer.delegate = self;

    [self reset];
    return self;
}

- (NSString*)name
{
    return @"Nunchuck";
}

- (NSPoint)stickPosition
{
    return _stickPosition;
}

- (BOOL)isButtonPressed:(WiimoteNunchuckButtonType)button
{
    return _buttonState[button];
}

- (WiimoteAccelerometer*)accelerometer
{
    return _accelerometer;
}

- (NSPoint)normalizeStickPosition:(NSPoint)position
{
    return position;
}

- (void)setStickPosition:(NSPoint)newPosition
{
    newPosition = [self normalizeStickPosition:newPosition];

    if(WiimoteDeviceIsPointEqual(_stickPosition, newPosition))
        return;

	_stickPosition = newPosition;

    [[self eventDispatcher] postNunchuck:self stickPositionChanged:newPosition];
}

- (void)setButton:(WiimoteNunchuckButtonType)button pressed:(BOOL)pressed
{
	if(_buttonState[button] == pressed)
		return;

	_buttonState[button] = pressed;

    if(pressed)
        [[self eventDispatcher] postNunchuck:self buttonPressed:button];
    else
        [[self eventDispatcher] postNunchuck:self buttonReleased:button];
}

- (BOOL)isSupportMotionPlus
{
    return YES;
}

- (WiimoteDeviceMotionPlusMode)motionPlusMode
{
    return WiimoteDeviceMotionPlusModeNunchuck;
}

- (void)handleCalibrationData:(const uint8_t*)data length:(NSUInteger)length
{
    if(length < sizeof(WiimoteDeviceNunchuckCalibrationData))
        return;

	const WiimoteDeviceNunchuckCalibrationData *calibrationData =
			(const WiimoteDeviceNunchuckCalibrationData*)data;

	_stickCalibrationData = calibrationData->stick;
    [_accelerometer setCalibrationData:&(calibrationData->accelerometer)];
	[self checkCalibrationData];

	_isCalibrationDataRead = YES;
}

- (void)handleReport:(const uint8_t*)extensionData length:(NSUInteger)length
{
    if(length < sizeof(WiimoteDeviceNunchuckReport))
        return;

    const WiimoteDeviceNunchuckReport *nunchuckReport =
                (const WiimoteDeviceNunchuckReport*)extensionData;

	if(_isCalibrationDataRead)
	{
		NSPoint stickPostion;

		WiimoteDeviceNormalizeStick(
							nunchuckReport->stickX,
							nunchuckReport->stickY,
							_stickCalibrationData,
							stickPostion);

		[self setStickPosition:stickPostion];

        if([_accelerometer isEnabled])
        {
            uint16_t x = (((uint16_t)nunchuckReport->accelerometerX) << 2) | ((nunchuckReport->acceleromererXYZAndButtonState >> 2) & 0x3);
            uint16_t y = (((uint16_t)nunchuckReport->accelerometerY) << 2) | ((nunchuckReport->acceleromererXYZAndButtonState >> 4) & 0x3);
            uint16_t z = (((uint16_t)nunchuckReport->accelerometerZ) << 2) | ((nunchuckReport->acceleromererXYZAndButtonState >> 6) & 0x3);

            [_accelerometer setHardwareValueX:x y:y z:z];
        }
	}

    [self setButton:WiimoteNunchuckButtonTypeZ
            pressed:((nunchuckReport->acceleromererXYZAndButtonState &
                                    WiimoteDeviceNunchuckReportButtonMaskZ) == 0)];

    [self setButton:WiimoteNunchuckButtonTypeC
            pressed:((nunchuckReport->acceleromererXYZAndButtonState &
                                    WiimoteDeviceNunchuckReportButtonMaskC) == 0)];
}

- (void)handleMotionPlusReport:(const uint8_t*)extensionData
                        length:(NSUInteger)length
{
    if(length < sizeof(WiimoteDeviceNunchuckReport))
        return;

    uint8_t data[sizeof(WiimoteDeviceNunchuckReport)];

    // transform to standart nunchuck report
    memcpy(data, extensionData, sizeof(data));
    data[4] &= 0xFE;
    data[4] |= ((extensionData[5] >> 7) & 0x1);
    data[5] =
        ((extensionData[5] & 0x40) << 1) |
        ((extensionData[5] & 0x20) >> 0) |
        ((extensionData[5] & 0x10) >> 1) |
        ((extensionData[5] & 0x0C) >> 2);

    [self handleReport:data length:sizeof(data)];
}

// MARK: WiimoteAccelerometerDelegate

- (void)checkCalibrationData
{
    WiimoteDeviceCheckStickCalibration(_stickCalibrationData, 0, 127, 255);

    if ([_accelerometer isHardwareZeroValuesInvalid])
		[_accelerometer setHardwareZeroX:500 y:500 z:500];

	if ([_accelerometer isHardware1gValuesInvalid])
		[_accelerometer setHardware1gX:700 y:700 z:700];
}

- (void)reset
{
	_buttonState[WiimoteNunchuckButtonTypeC] = NO;
	_buttonState[WiimoteNunchuckButtonTypeZ] = NO;
	_stickPosition = NSZeroPoint;

	[_accelerometer reset];
}

- (void)wiimoteAccelerometer:(WiimoteAccelerometer*)accelerometer
         enabledStateChanged:(BOOL)enabled
{
    if (!self.owner.isConnected)
    {
        if (enabled) accelerometer.enabled = NO;

        return;
    }

    [[self eventDispatcher] postNunchuck:self accelerometerEnabledStateChanged:enabled];
}

- (void)wiimoteAccelerometer:(WiimoteAccelerometer*)accelerometer
             gravityChangedX:(CGFloat)x
                           y:(CGFloat)y
                           z:(CGFloat)z
{
    [[self eventDispatcher] postNunchuck:self accelerometerChangedGravityX:x y:y z:z];
}

- (void)wiimoteAccelerometer:(WiimoteAccelerometer*)accelerometer
                pitchChanged:(CGFloat)pitch
                        roll:(CGFloat)roll
{
    [[self eventDispatcher] postNunchuck:self accelerometerChangedPitch:pitch roll:roll];
}

@end
