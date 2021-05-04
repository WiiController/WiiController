//
//  WiimoteExtension+PlugIn.m
//  Wiimote
//
//  Created by alxn1 on 28.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteExtension+PlugIn.h"

#import "Wiimote.h"
#import "WiimoteExtensionPart.h"

#import "WiimoteLog.h"

@implementation WiimoteExtension (PlugIn)

+ (void)registerExtensionClass:(Class)cls
{
    [WiimoteExtensionPart registerExtensionClass:cls];
}

+ (NSUInteger)merit
{
    static NSUInteger result = 0;

    if (result == 0)
    {
        result = [WiimoteExtension
            nextFreedomMeritInClass:
                WiimoteExtensionMeritClassUnknown];
    }

    return result;
}

+ (NSUInteger)minReportDataSize
{
    return 0;
}

+ (void)probe:(WiimoteIOManager *)ioManager
       target:(id)target
       action:(SEL)action
{
    [WiimoteExtension probeFinished:NO target:target action:action];
}

- (id)initWithOwner:(Wiimote *)owner
    eventDispatcher:(WiimoteEventDispatcher *)dispatcher
{
    self = [super init];
    if (self == nil)
        return nil;

    _owner = owner;
    _eventDispatcher = dispatcher;

    return self;
}

- (WiimoteEventDispatcher *)eventDispatcher
{
    return _eventDispatcher;
}

- (void)calibrate:(WiimoteIOManager *)ioManager
{
}

- (void)handleReport:(const uint8_t *)extensionData length:(NSUInteger)length
{
}

- (void)disconnected
{
}

@end

@implementation WiimoteExtension (CalibrationUtils)

- (BOOL)beginReadCalibrationData:(WiimoteIOManager *)ioManager
                     memoryRange:(NSRange)memoryRange
{

    BOOL success = [ioManager readMemory:memoryRange then:^(NSData *data) {
        if (!data) return;
        [self handleCalibrationData:(const uint8_t *)data.bytes length:data.length];
    }];

    if (!success)
    {
        W_ERROR(@"[WiimoteIOManager readMemory: target: action:] failed");

        return NO;
    }

    return YES;
}

- (void)handleCalibrationData:(const uint8_t *)data length:(NSUInteger)length
{
}

@end

@implementation WiimoteExtension (PlugInUtils)

+ (NSUInteger)nextFreedomMeritInClass:(WiimoteExtensionMeritClass)meritClass
{
    static NSMutableDictionary *counterDict = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        counterDict = [NSMutableDictionary dictionaryWithCapacity:5];
    });

    NSNumber *key = @(meritClass);
    NSNumber *merit = counterDict[key];

    if (merit) merit = @(merit.integerValue + 1);
    else
        merit = @(meritClass + 1);

    counterDict[key] = merit;

    return merit.integerValue;
}

+ (void)probeFinished:(BOOL)result
               target:(id)target
               action:(SEL)action
{
    if (!target || !action) return;

    [target performSelector:action
                 withObject:@(result)
                 afterDelay:0.0];
}

@end

@implementation WiimoteExtension (SubExtension)

- (void)setSubExtension:(WiimoteExtension *)extension
{
}

@end

@implementation WiimoteExtension (MotionPlus)

- (BOOL)isSupportMotionPlus
{
    return NO;
}

- (WiimoteDeviceMotionPlusMode)motionPlusMode
{
    return WiimoteDeviceMotionPlusModeOther;
}

- (void)handleMotionPlusReport:(const uint8_t *)extensionData
                        length:(NSUInteger)length
{
}

@end
