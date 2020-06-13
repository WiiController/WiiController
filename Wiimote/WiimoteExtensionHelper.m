//
//  WiimoteExtensionHelper.m
//  Wiimote
//
//  Created by alxn1 on 31.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteExtensionHelper.h"

@implementation WiimoteExtensionHelper {
    id _retainedSelf;
}

- (id)initWithWiimote:(Wiimote*)wiimote
      eventDispatcher:(WiimoteEventDispatcher*)dispatcher
            ioManager:(WiimoteIOManager*)ioManager
     extensionClasses:(NSArray*)extensionClasses
         subExtension:(WiimoteExtension*)extension
               target:(id)target
               action:(SEL)action
{
    self = [super init];
    if(self == nil)
        return nil;

    _wiimote           = wiimote;
    _eventDispatcher   = dispatcher;
    _iOManager         = ioManager;
    _extensionClasses  = [extensionClasses mutableCopy];
    _currentClass      = nil;
    _extension         = nil;
    _subExtension      = extension;

    _isInitialized     = NO;
    _isStarted         = NO;
    _isCanceled        = NO;

    _target            = target;
    _action            = action;

    return self;
}


- (void)initializeExtensionPort
{
    uint8_t data;

    data = WiimoteDeviceRoutineExtensionInitValue1;
    [_iOManager writeMemory:WiimoteDeviceRoutineExtensionInitAddress1 data:&data length:sizeof(data)];
	usleep(50000);

    data = WiimoteDeviceRoutineExtensionInitValue2;
    [_iOManager writeMemory:WiimoteDeviceRoutineExtensionInitAddress2 data:&data length:sizeof(data)];
	usleep(50000);

    _isInitialized = YES;
}

- (void)beginProbe
{
    _retainedSelf = self;
}

- (void)endProbe
{
    _retainedSelf = nil;
}

- (void)probeFinished:(WiimoteExtension*)extension
{
    if(_target != nil && _action != nil)
        [_target performSelector:_action withObject:extension afterDelay:0.0];

    [self endProbe];
}

- (void)probeNextClass
{
    if(_isCanceled)
    {
        [self endProbe];
        return;
    }

    if([_extensionClasses count] == 0)
    {
        [self probeFinished:nil];
        return;
    }

    _currentClass = [_extensionClasses objectAtIndex:0];
    [_extensionClasses removeObjectAtIndex:0];

    if(!_isInitialized &&
       [_currentClass merit] >= WiimoteExtensionMeritClassSystemHigh)
    {
        [self initializeExtensionPort];
    }

    [_currentClass probe:_iOManager
                   target:self
                   action:@selector(currentClassProbeFinished:)];
}

- (void)currentClassProbeFinished:(NSNumber*)result
{
    if(_isCanceled)
    {
        [self endProbe];
        return;
    }

    if(![result boolValue])
    {
        [self probeNextClass];
        return;
    }

    _extension = [[_currentClass alloc] initWithOwner:_wiimote
                                        eventDispatcher:_eventDispatcher];

    if(_extension == nil)
    {
        [self probeNextClass];
        return;
    }

    [_extension calibrate:_iOManager];
	[self probeFinished:_extension];
}

- (WiimoteExtension*)subExtension
{
	return _subExtension;
}

- (void)start
{
    if(_isStarted)
        return;

    _isInitialized = NO;
	[self beginProbe];
    [self probeNextClass];
}

- (void)cancel
{
    _isCanceled = YES;
}

@end
