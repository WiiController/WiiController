//
//  WiimoteAccelerometerPart.m
//  Wiimote
//
//  Created by alxn1 on 03.08.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteAccelerometerPart.h"
#import "WiimoteEventDispatcher+Accelerometer.h"
#import "Wiimote+PlugIn.h"

@interface WiimoteAccelerometerPart () <WiimoteAccelerometerDelegate>

@end

@implementation WiimoteAccelerometerPart
{
    BOOL _isCalibrationDataRead;
}

+ (void)load
{
    [WiimotePart registerPartClass:[WiimoteAccelerometerPart class]];
}

- (id)initWithOwner:(Wiimote*)owner
    eventDispatcher:(WiimoteEventDispatcher*)dispatcher
          ioManager:(WiimoteIOManager*)ioManager
{
    self = [super initWithOwner:owner eventDispatcher:dispatcher ioManager:ioManager];
    if (!self) return nil;

    _isCalibrationDataRead = NO;
    _accelerometer = [[WiimoteAccelerometer alloc] init];

    _accelerometer.delegate = self;

    return self;
}

- (NSSet*)allowedReportTypeSet
{
    static NSSet *result = nil;

    if(![_accelerometer isEnabled])
        return nil;

    if(result == nil)
    {
        result = [[NSSet alloc] initWithObjects:
                            [NSNumber numberWithInteger:WiimoteDeviceReportTypeButtonAndAccelerometerState],
                            [NSNumber numberWithInteger:WiimoteDeviceReportTypeButtonAndAccelerometerAndIR12BytesState],
                            [NSNumber numberWithInteger:WiimoteDeviceReportTypeButtonAndAccelerometerAndExtension16BytesState],
                            [NSNumber numberWithInteger:WiimoteDeviceReportTypeButtonAndAccelerometerAndIR10BytesAndExtension6Bytes],
                            nil] ;
    }

    return result;
}

- (void)connected
{
	if(![[self owner] isWiiUProController])
		[self readCalibrationData];
}

- (void)handleReport:(WiimoteDeviceReport*)report
{
    if(![_accelerometer isEnabled] || !_isCalibrationDataRead)
        return;

    if([report length] < sizeof(WiimoteDeviceButtonAndAccelerometerStateReport))
        return;

    WiimoteDeviceReportType reportType = (WiimoteDeviceReportType)[report type];

    switch(reportType)
    {
        case WiimoteDeviceReportTypeButtonAndAccelerometerState:
        case WiimoteDeviceReportTypeButtonAndAccelerometerAndIR12BytesState:
        case WiimoteDeviceReportTypeButtonAndAccelerometerAndExtension16BytesState:
        case WiimoteDeviceReportTypeButtonAndAccelerometerAndIR10BytesAndExtension6Bytes:
            break;

        default:
            return;
    }

	const WiimoteDeviceButtonAndAccelerometerStateReport *stateReport =
            (const WiimoteDeviceButtonAndAccelerometerStateReport*)[report data];

    uint16_t x = (((uint16_t)stateReport->accelerometerX) << 2) | (((stateReport->accelerometerAdditionalX  >> 5) & 0x3) << 0);
    uint16_t y = (((uint16_t)stateReport->accelerometerY) << 2) | (((stateReport->accelerometerAdditionalYZ >> 5) & 0x1) << 1);
    uint16_t z = (((uint16_t)stateReport->accelerometerZ) << 2) | (((stateReport->accelerometerAdditionalYZ >> 6) & 0x1) << 1);

    [_accelerometer setHardwareValueX:x y:y z:z];
}

- (void)disconnected
{
    [_accelerometer reset];
}

- (void)readCalibrationData
{
    NSRange memRange = NSMakeRange(WiimoteDeviceCalibrationDataAddress, sizeof(WiimoteDeviceAccelerometerCalibrationData));

    (void)[self.ioManager readMemory:memRange then:^(NSData *data) {
        if(data.length < sizeof(WiimoteDeviceAccelerometerCalibrationData)) return;

        const WiimoteDeviceAccelerometerCalibrationData *calibrationData = (const WiimoteDeviceAccelerometerCalibrationData*)data.bytes;

        [self->_accelerometer setCalibrationData:calibrationData];
        [self checkCalibrationData];

        self->_isCalibrationDataRead = YES;
    }];
}

- (void)checkCalibrationData
{
    if([_accelerometer isHardwareZeroValuesInvalid])
        [_accelerometer setHardwareZeroX:500 y:500 z:500];

    if([_accelerometer isHardware1gValuesInvalid])
        [_accelerometer setHardware1gX:600 y:600 z:600];
}

// MARK: WiimoteAccelerometerDelegate

- (void)wiimoteAccelerometer:(WiimoteAccelerometer*)accelerometer
         enabledStateChanged:(BOOL)enabled
{
    if(![[self owner] isConnected])
    {
        if(enabled)
            [accelerometer setEnabled:NO];

        return;
    }

    [[self owner] deviceConfigurationChanged];
    [[self eventDispatcher] postAccelerometerEnabledNotification:enabled];
}

- (void)wiimoteAccelerometer:(WiimoteAccelerometer*)accelerometer
             gravityChangedX:(CGFloat)x
                           y:(CGFloat)y
                           z:(CGFloat)z
{
    [[self eventDispatcher] postAccelerometerGravityChangedNotificationX:x y:y z:z];
}

- (void)wiimoteAccelerometer:(WiimoteAccelerometer*)accelerometer
                pitchChanged:(CGFloat)pitch
                        roll:(CGFloat)roll
{
    [[self eventDispatcher] postAccelerometerAnglesChangedNotificationPitch:pitch roll:roll];
}

@end
