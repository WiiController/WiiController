//
//  WiimoteMotionPlus.m
//  Wiimote
//
//  Created by alxn1 on 13.09.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteMotionPlus.h"
#import "WiimoteExtensionProbeHandler.h"
#import "WiimoteEventDispatcher+MotionPlus.h"
#import "Wiimote.h"

@implementation WiimoteMotionPlus

+ (void)load
{
    [WiimoteExtension registerExtensionClass:[WiimoteMotionPlus class]];
}

+ (NSUInteger)merit
{
    return WiimoteExtensionMeritClassMotionPlus;
}

+ (NSUInteger)minReportDataSize
{
    return 6;
}

+ (NSArray *)motionPlusSignatures
{
    static const uint8_t signature1[] = { 0x00, 0x00, 0xA4, 0x20, 0x04, 0x05 };
    static const uint8_t signature2[] = { 0x00, 0x00, 0xA4, 0x20, 0x05, 0x05 };
    static const uint8_t signature3[] = { 0x00, 0x00, 0xA4, 0x20, 0x07, 0x05 };
    static const uint8_t signature4[] = { 0x01, 0x00, 0xA4, 0x20, 0x07, 0x05 };

    static NSArray *result = nil;

    if (result == nil)
    {
        result = @[
            [NSData dataWithBytes:signature1 length:sizeof(signature1)],
            [NSData dataWithBytes:signature2 length:sizeof(signature2)],
            [NSData dataWithBytes:signature3 length:sizeof(signature3)],
            [NSData dataWithBytes:signature4 length:sizeof(signature4)]
        ];
    }

    return result;
}

+ (void)probe:(WiimoteIOManager *)ioManager
       target:(id)target
       action:(SEL)action
{
    [WiimoteExtensionProbeHandler
        routineProbe:ioManager
          signatures:[WiimoteMotionPlus motionPlusSignatures]
              target:target
              action:action];
}

- (id)initWithOwner:(Wiimote *)owner
    eventDispatcher:(WiimoteEventDispatcher *)dispatcher
{
    self = [super initWithOwner:owner eventDispatcher:dispatcher];
    if (self == nil)
        return nil;

    _subExtension = nil;
    _iOManager = nil;
    _reportCounter = 0;
    _extensionReportCounter = 0;
    _isSubExtensionDisconnected = NO;

    return self;
}

- (void)calibrate:(WiimoteIOManager *)ioManager
{
    _iOManager = ioManager;
}

- (void)handleReport:(const uint8_t *)extensionData length:(NSUInteger)length
{
    if (length < 6)
        return;

    BOOL isExtensionConnected = ((extensionData[5] & 0x1) == 1);
    BOOL isExtensionDataReport = ((extensionData[5] & 0x2) == 0);

    if (_subExtension == nil && isExtensionConnected)
    {
        [self deactivate];
        return;
    }

    _reportCounter++;
    if (isExtensionDataReport)
        _extensionReportCounter++;

    if (_reportCounter == 10)
    {
        BOOL needDeactivate = NO;

        if ((_subExtension == nil && _extensionReportCounter != 0) || (_subExtension != nil && _extensionReportCounter == 0))
        {
            needDeactivate = YES;
        }

        _reportCounter = 0;
        _extensionReportCounter = 0;

        if (needDeactivate)
        {
            [self deactivate];
            return;
        }
    }

    if (isExtensionDataReport)
    {
        if (!_isSubExtensionDisconnected)
            [_subExtension handleMotionPlusReport:extensionData length:length];

        return;
    }

    _report.yaw.speed = extensionData[0];
    _report.roll.speed = extensionData[1];
    _report.pitch.speed = extensionData[2];

    _report.yaw.speed |= ((uint16_t)(extensionData[3] >> 2)) << 8;
    _report.roll.speed |= ((uint16_t)(extensionData[4] >> 2)) << 8;
    _report.pitch.speed |= ((uint16_t)(extensionData[5] >> 2)) << 8;

    _report.yaw.isSlowMode = ((extensionData[3] & 2) != 0);
    _report.roll.isSlowMode = ((extensionData[4] & 2) != 0);
    _report.pitch.isSlowMode = ((extensionData[3] & 1) != 0);

    [[self eventDispatcher]
        postMotionPlus:self
                report:&_report];
}

- (void)setSubExtension:(WiimoteExtension *)extension
{
    if (extension != nil && ![extension isSupportMotionPlus])
    {
        _isSubExtensionDisconnected = YES;
    }

    if (_subExtension == extension)
        return;

    _subExtension = extension;

    if (extension != nil && !_isSubExtensionDisconnected)
    {
        [[self eventDispatcher]
                postMotionPlus:self
            extensionConnected:extension];
    }
}

- (NSString *)name
{
    return @"Motion Plus";
}

- (void)disconnected
{
    [self disconnectSubExtension];
}

- (const WiimoteMotionPlusReport *)lastReport
{
    return (&_report);
}

- (WiimoteExtension *)subExtension
{
    if (_isSubExtensionDisconnected)
        return nil;

    return _subExtension;
}

- (void)disconnectSubExtension
{
    if (_isSubExtensionDisconnected || _subExtension == nil)
    {
        return;
    }

    _isSubExtensionDisconnected = YES;

    [[self eventDispatcher]
               postMotionPlus:self
        extensionDisconnected:_subExtension];
}

- (void)deactivate
{
    uint8_t data = WiimoteDeviceMotionPlusExtensionInitOrResetValue;

    [_iOManager writeMemory:WiimoteDeviceMotionPlusExtensionResetAddress
                       data:&data
                     length:sizeof(data)];

    usleep(50000);

    [[self owner] reconnectExtension];
}

@end
