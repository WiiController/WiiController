//
//  WiimoteWatchdog.m
//  Wiimote
//
//  Created by alxn1 on 27.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteWatchdog.h"
#import "Wiimote.h"

#import <Cocoa/Cocoa.h>

NSString *WiimoteWatchdogEnabledChangedNotification  = @"WiimoteWatchdogEnabledChangedNotification";
NSString *WiimoteWatchdogPingNotification            = @"WiimoteWatchdogPingNotification";

@interface WiimoteWatchdog (PrivatePart)

- (id)initInternal;

- (void)onTimer:(id)sender;

- (void)applicationWillTerminateNotification:(NSNotification*)notification;

@end

@implementation WiimoteWatchdog

+ (WiimoteWatchdog*)sharedWatchdog
{
    static WiimoteWatchdog *result = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        result = [[WiimoteWatchdog alloc] initInternal];
    });
    return result;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_timer invalidate];
}

- (BOOL)isEnabled
{
    return (_timer != nil);
}

- (void)setEnabled:(BOOL)enabled
{
    if([self isEnabled] == enabled)
        return;

    if(enabled)
    {
        _timer = [NSTimer scheduledTimerWithTimeInterval:2.5
                                                   target:self
                                                 selector:@selector(onTimer:)
                                                 userInfo:nil
                                                  repeats:YES];

        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];

        [[NSNotificationCenter defaultCenter]
                                addObserver:self
                                   selector:@selector(applicationWillTerminateNotification:)
                                       name:NSApplicationWillTerminateNotification
                                     object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [_timer invalidate];
        _timer = nil;
    }

    if(_isPingNotificationEnabled)
    {
        [[NSNotificationCenter defaultCenter]
                                postNotificationName:WiimoteWatchdogEnabledChangedNotification
                                              object:self];
    }
}

- (BOOL)isPingNotificationEnabled
{
    return _isPingNotificationEnabled;
}

- (void)setPingNotificationEnabled:(BOOL)enabled
{
    _isPingNotificationEnabled = enabled;
}

@end

@implementation WiimoteWatchdog (PrivatePart)

- (id)initInternal
{
    self = [super init];
    if(self == nil)
        return nil;

    _timer                     = nil;
    _isPingNotificationEnabled = YES;

    return self;
}

- (void)onTimer:(id)sender
{
    NSArray     *connectedDevices   = [Wiimote connectedDevices];
    NSUInteger   countDevices       = [connectedDevices count];

    for(NSUInteger i = 0; i < countDevices; i++)
    {
        Wiimote *device = [connectedDevices objectAtIndex:i];
        [device requestUpdateState];
    }

    [[NSNotificationCenter defaultCenter]
                            postNotificationName:WiimoteWatchdogPingNotification
                                          object:self];
}

- (void)applicationWillTerminateNotification:(NSNotification*)notification
{
    NSArray     *connectedDevices   = [[Wiimote connectedDevices] copy];
    NSUInteger   countDevices       = [connectedDevices count];

    for(NSUInteger i = 0; i < countDevices; i++)
        [[connectedDevices objectAtIndex:i] disconnect];
}

@end
