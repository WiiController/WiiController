//
//  WiimoteEventDispatcher.m
//  Wiimote
//
//  Created by alxn1 on 30.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteEventDispatcher+Private.h"
#import "WiimoteDelegate.h"

@implementation WiimoteEventDispatcher

- (void)postNotification:(NSString *)notification
{
    [self postNotification:notification sender:[self owner]];
}

- (void)postNotification:(NSString *)notification sender:(id)sender
{
    [self postNotification:notification params:nil sender:[self owner]];
}

- (void)postNotification:(NSString *)notification param:(id)param key:(NSString *)key
{
    [self postNotification:notification param:param key:key sender:[self owner]];
}

- (void)postNotification:(NSString *)notification param:(id)param key:(NSString *)key sender:(id)sender
{
    NSDictionary *params = nil;

    if (param != nil && key != nil)
        params = [NSDictionary dictionaryWithObject:param forKey:key];

    [self postNotification:notification
                    params:params
                    sender:sender];
}

- (void)postNotification:(NSString *)notification params:(NSDictionary *)params
{
    [self postNotification:notification params:params sender:[self owner]];
}

- (void)postNotification:(NSString *)notification params:(NSDictionary *)params sender:(id)sender
{
    [[NSNotificationCenter defaultCenter]
        postNotificationName:notification
                      object:sender
                    userInfo:params];
}

- (id)initWithOwner:(Wiimote *)owner
{
    self = [super init];
    if (self == nil)
        return nil;

    _owner = owner;
    _stateNotificationsEnabled = YES;

    return self;
}

- (void)postConnectedNotification
{
    [self postNotification:WiimoteConnectedNotification];
}

- (void)postDisconnectNotification
{
    [[self delegate] wiimoteDisconnected:[self owner]];
    [self postNotification:WiimoteDisconnectedNotification];
}

- (void)setStateNotificationsEnabled:(BOOL)flag
{
    _stateNotificationsEnabled = flag;
}

- (void)setDelegate:(id)delegate
{
    _delegate = delegate;
}

@end
