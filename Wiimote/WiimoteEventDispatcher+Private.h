//
//  WiimoteEventDispatcher+Private.h
//  Wiimote
//
//  Created by alxn1 on 30.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteEventDispatcher.h"

@interface WiimoteEventDispatcher (Private)

- (instancetype)initWithOwner:(Wiimote*)owner;

- (void)postConnectedNotification;
- (void)postDisconnectNotification;

@property(nonatomic,getter=isStateNotificationsEnabled) BOOL stateNotificationsEnabled;
@property(nonatomic) id delegate;

@end
