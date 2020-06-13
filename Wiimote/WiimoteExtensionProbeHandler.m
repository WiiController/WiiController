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
    @private
        NSArray *_signatures;
}

- (id)initWithIOManager:(WiimoteIOManager*)manager
             signatures:(NSArray*)signatures
                 target:(id)target
                 action:(SEL)action;

- (void)ioManagerDataReaded:(NSData*)data;

@end

@implementation WiimoteExtensionRoutineProbeHandler

- (id)initWithIOManager:(WiimoteIOManager*)manager
             signatures:(NSArray*)signatures
                 target:(id)target
                 action:(SEL)action
{
    self = [super initWithIOManager:manager target:target action:action];
    if(self == nil)
        return nil;

    _signatures = signatures;

    if(_signatures			== nil ||
      [_signatures count]  == 0)
    {
        [self probeFinished:NO];
        return nil;
    }

    if(![manager readMemory:NSMakeRange(
								WiimoteDeviceRoutineExtensionProbeAddress,
								[[_signatures objectAtIndex:0] length])
                     target:self
                     action:@selector(ioManagerDataReaded:)])
    {
        W_ERROR(@"[WiimoteIOManager readMemory: target: action:] failed");
        [self probeFinished:NO];
        return nil;
    } 

    return self;
}


- (void)ioManagerDataReaded:(NSData*)data
{
    if(data == nil)
    {
        return;
    }

    if([data length] < [[_signatures objectAtIndex:0] length])
    {
        W_ERROR(@"readed data chunk too small");
        [self probeFinished:NO];
        return;
    }

    BOOL		isOk			= NO;
	NSUInteger	countSignatures = [_signatures count];

	for(NSUInteger i = 0; i < countSignatures; i++)
	{
		if([[_signatures objectAtIndex:i] isEqualToData:data])
		{
            isOk = YES;
			break;
		}
	}

    W_DEBUG_F(@"probe finished (%@): %@", data, ((isOk)?(@"Ok"):(@"Not Ok")));
    [self probeFinished:isOk];
}

@end

@implementation WiimoteExtensionProbeHandler
{
    id       _target;
    SEL      _action;
}

+ (void)routineProbe:(WiimoteIOManager*)manager
           signature:(NSData*)signature
              target:(id)target
              action:(SEL)action
{
	(void)[[WiimoteExtensionRoutineProbeHandler alloc]
										initWithIOManager:manager
                                               signatures:[NSArray arrayWithObject:signature]
												   target:target
												   action:action];
}

+ (void)routineProbe:(WiimoteIOManager*)manager
		  signatures:(NSArray*)signatures
              target:(id)target
              action:(SEL)action
{
	(void)[[WiimoteExtensionRoutineProbeHandler alloc]
										initWithIOManager:manager
                                               signatures:signatures
												   target:target
												   action:action];
}

- (id)initWithIOManager:(WiimoteIOManager*)manager
                 target:(id)target
                 action:(SEL)action
{
    self = [super init];
    if(self == nil)
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
