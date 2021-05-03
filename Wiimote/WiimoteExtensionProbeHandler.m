//
//  WiimoteExtensionProbeHandler.m
//  Wiimote
//
//  Created by alxn1 on 31.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteExtensionProbeHandler.h"
#import "WiimoteExtension+PlugIn.h"

#import "WiimoteLog.h"

@interface WiimoteExtensionRoutineProbeHandler : WiimoteExtensionProbeHandler
{
    NSArray<NSData *> *_signatures;
}

- (id)initWithIOManager:(WiimoteIOManager *)manager
             signatures:(NSArray *)signatures
                 target:(id)target
                 action:(SEL)action;

@end

@implementation WiimoteExtensionRoutineProbeHandler

- (id)initWithIOManager:(WiimoteIOManager *)manager
             signatures:(NSArray *)signatures
                 target:(id)target
                 action:(SEL)action
{
    self = [super initWithIOManager:manager target:target action:action];
    if (self == nil)
        return nil;

    _signatures = signatures;

    if (!_signatures || _signatures.count == 0)
    {
        [self probeFinished:NO];
        return nil;
    }

    NSRange memRange = NSMakeRange(WiimoteDeviceRoutineExtensionProbeAddress, [[_signatures objectAtIndex:0] length]);
    BOOL success = [manager readMemory:memRange then:^(NSData *data) {
        if (!data) return;

        if (data.length < self->_signatures[0].length)
        {
            W_ERROR(@"read data chunk too small");
            [self probeFinished:NO];
            return;
        }

        BOOL isOk = NO;
        for (NSData *signature in self->_signatures)
        {
            if ([signature isEqualToData:data])
            {
                isOk = YES;
                break;
            }
        }

        W_DEBUG_F(@"probe finished (%@): %@", data, ((isOk) ? (@"Ok") : (@"Not Ok")));
        [self probeFinished:isOk];
    }];

    if (!success)
    {
        W_ERROR(@"[WiimoteIOManager readMemory: target: action:] failed");
        [self probeFinished:NO];
        return nil;
    }

    return self;
}

@end

@implementation WiimoteExtensionProbeHandler
{
    id _target;
    SEL _action;
}

+ (void)routineProbe:(WiimoteIOManager *)manager
           signature:(NSData *)signature
              target:(id)target
              action:(SEL)action
{
    (void)[[WiimoteExtensionRoutineProbeHandler alloc]
        initWithIOManager:manager
               signatures:[NSArray arrayWithObject:signature]
                   target:target
                   action:action];
}

+ (void)routineProbe:(WiimoteIOManager *)manager
          signatures:(NSArray *)signatures
              target:(id)target
              action:(SEL)action
{
    (void)[[WiimoteExtensionRoutineProbeHandler alloc]
        initWithIOManager:manager
               signatures:signatures
                   target:target
                   action:action];
}

- (id)initWithIOManager:(WiimoteIOManager *)manager
                 target:(id)target
                 action:(SEL)action
{
    self = [super init];
    if (self == nil)
        return nil;

    _target = target;
    _action = action;

    return self;
}

- (void)probeFinished:(BOOL)result
{
    [WiimoteExtension probeFinished:result target:_target action:_action];
}

@end
