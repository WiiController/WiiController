//
//  WiimoteMotionPlusDetector.m
//  WMouse
//
//  Created by alxn1 on 12.09.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteMotionPlusDetector.h"

#import "WiimoteLog.h"

#import <objc/message.h>

#define WiimoteDeviceMotionPlusDetectTriesCount      4
#define WiimoteDeviceMotionPlusLastTryDelay          8.0

@implementation WiimoteMotionPlusDetector
{
    @private
        WiimoteIOManager *_iOManager;

        id                _target;
        SEL               _action;

        NSUInteger        _cancelCount;
        NSUInteger        _readTryCount;

        NSTimer          *_lastTryTimer;
}

+ (NSArray*)motionPlusSignatures
{ 
    static const uint8_t  signature1[]   = { 0x00, 0x00, 0xA6, 0x20, 0x00, 0x05 };
	static const uint8_t  signature2[]   = { 0x00, 0x00, 0xA6, 0x20, 0x04, 0x05 };
	static const uint8_t  signature3[]   = { 0x00, 0x00, 0xA6, 0x20, 0x05, 0x05 };
	static const uint8_t  signature4[]   = { 0x00, 0x00, 0xA6, 0x20, 0x07, 0x05 };
    static const uint8_t  signature5[]   = { 0x00, 0x00, 0xA4, 0x20, 0x00, 0x05 };
    static const uint8_t  signature6[]   = { 0x01, 0x00, 0xA4, 0x20, 0x00, 0x05 };

    static NSArray       *result         = nil;

    if(result == nil)
	{
		result = [[NSArray alloc] initWithObjects:
					[NSData dataWithBytes:signature1 length:sizeof(signature1)],
					[NSData dataWithBytes:signature2 length:sizeof(signature2)],
					[NSData dataWithBytes:signature3 length:sizeof(signature3)],
					[NSData dataWithBytes:signature4 length:sizeof(signature4)],
                    [NSData dataWithBytes:signature5 length:sizeof(signature5)],
                    [NSData dataWithBytes:signature6 length:sizeof(signature6)],
					nil];
	}

    return result;

}

+ (NSRange)motionPlusSignatureMemRange
{
    return NSMakeRange(
                WiimoteDeviceMotionPlusExtensionProbeAddress,
                [[[WiimoteMotionPlusDetector motionPlusSignatures] objectAtIndex:0] length]);
}

+ (void)activateMotionPlus:(WiimoteIOManager*)ioManager
              subExtension:(WiimoteExtension*)subExtension
{
	uint8_t data = WiimoteDeviceMotionPlusModeOther;

    if(subExtension != nil &&
      [subExtension isSupportMotionPlus])
    {
        data = [subExtension motionPlusMode];
    }

    [ioManager writeMemory:WiimoteDeviceMotionPlusExtensionSetModeAddress
                      data:&data
                    length:sizeof(data)];

    usleep(50000);
}

- (instancetype)initWithIOManager:(WiimoteIOManager*)ioManager
                           target:(id)target
                           action:(SEL)action
{
    self = [super init];
    if(self == nil)
        return nil;

    _iOManager     = ioManager;
    _target        = target;
    _action        = action;
    _isRun         = NO;
    _cancelCount   = 0;

    return self;
}

- (void)dealloc
{
    [self cancel];
}

- (void)run
{
    if(_isRun)
        return;

    _isRun = YES;
    _readTryCount = 0;
    [self initializeMotionPlus];
    [self beginReadSignature];
}

- (void)cancel
{
    if(!_isRun)
        return;

    _cancelCount++;
    if(_lastTryTimer != nil)
    {
        [_lastTryTimer invalidate];
        _cancelCount--;
    }

    _isRun = NO;
}

- (void)initializeMotionPlus
{
    uint8_t data = WiimoteDeviceMotionPlusExtensionInitOrResetValue;

    [_iOManager writeMemory:WiimoteDeviceMotionPlusExtensionInitAddress
                        data:&data
                      length:sizeof(data)];

    usleep(50000);
}

- (void)beginReadSignature
{
    _readTryCount++;
    _lastTryTimer = nil;

    [_iOManager readMemory:[WiimoteMotionPlusDetector motionPlusSignatureMemRange]
                     target:self
                     action:@selector(signatureReaded:)];

}

- (void)signatureReaded:(NSData*)data
{
    W_DEBUG_F(@"Possible wiimote ID: %@", data);

    if(_cancelCount > 0)
    {
        _cancelCount--;
        return;
    }

    if(data == nil)
    {
        [self detectionFinished:NO];
        return;
    }

	NSArray		*signatures		 = [WiimoteMotionPlusDetector motionPlusSignatures];
	NSUInteger   countSignatures = [signatures count];

	for(NSUInteger i = 0; i < countSignatures; i++)
	{
		if([data isEqualToData:[signatures objectAtIndex:i]])
		{
			[self detectionFinished:YES];
			return;
		}
	}

    if(_readTryCount >= WiimoteDeviceMotionPlusDetectTriesCount)
    {
        [self detectionFinished:NO];
        return;
    }

    if(_readTryCount < (WiimoteDeviceMotionPlusDetectTriesCount - 1))
    {
        usleep(50000);
        [self beginReadSignature];
        return;
    }

    _lastTryTimer = [NSTimer scheduledTimerWithTimeInterval:WiimoteDeviceMotionPlusLastTryDelay
                                                      target:self
                                                    selector:@selector(beginReadSignature)
                                                    userInfo:nil
                                                     repeats:NO];
}

- (void)detectionFinished:(BOOL)detected
{
    _isRun = NO;
    ((void(*)(id self, SEL _cmd, NSNumber *detected))objc_msgSend)
        (_target, _action, @(detected));
}

@end
