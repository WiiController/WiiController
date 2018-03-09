//
//  NotificationCenter.m
//  WJoy
//
//  Created by alxn1 on 27.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <Wiimote/Wiimote.h>
#import <UpdateChecker/UAppUpdateChecker.h>

#import "NotificationCenter.h"

@interface NotificationCenter (PrivatePart)

- (id)initInternal;

- (void)onDiscoveryBegin;
- (void)onDiscoveryEnd;
- (void)onDeviceConnected;
- (void)onDeviceBatteryStateChanged:(NSNotification*)notification;
- (void)onDeviceDisconnected;

@end

@implementation NotificationCenter

+ (void)start
{
    [[NotificationCenter alloc] initInternal];
}

- (BOOL)userNotificationCenter:(UserNotificationCenter*)center
     shouldDeliverNotification:(UserNotification*)notification
{
    return YES;
}

- (void)userNotificationCenter:(UserNotificationCenter*)center
           notificationClicked:(UserNotification*)notification
{
    NSString *url = [[notification userInfo] objectForKey:@"URL"];
    if(url != nil)
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

@end

@implementation NotificationCenter (PrivatePart)

- (id)init
{
    [[super init] release];
    return nil;
}

- (id)initInternal
{
    self = [super init];
    if(self == nil)
        return nil;

    [[NSNotificationCenter defaultCenter]
                            addObserver:self
                               selector:@selector(onDiscoveryBegin)
                                   name:WiimoteBeginDiscoveryNotification
                                 object:nil];

    [[NSNotificationCenter defaultCenter]
                            addObserver:self
                               selector:@selector(onDiscoveryEnd)
                                   name:WiimoteEndDiscoveryNotification
                                 object:nil];

    [[NSNotificationCenter defaultCenter]
                            addObserver:self
                               selector:@selector(onDeviceConnected)
                                   name:WiimoteConnectedNotification
                                 object:nil];

    [[NSNotificationCenter defaultCenter]
                            addObserver:self
                               selector:@selector(onDeviceBatteryStateChanged:)
                                   name:WiimoteBatteryLevelUpdatedNotification
                                 object:nil];

    [[NSNotificationCenter defaultCenter]
                            addObserver:self
                               selector:@selector(onDeviceDisconnected)
                                   name:WiimoteDisconnectedNotification
                                 object:nil];

    [[NSNotificationCenter defaultCenter]
                                addObserver:self
                                   selector:@selector(onCheckNewVersionFinished:)
                                       name:UAppUpdateCheckerDidFinishNotification
                                     object:nil];

    [UserNotificationCenter setDelegate:self];

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)onDiscoveryBegin
{
    [UserNotificationCenter
        deliver:[UserNotification
                    userNotificationWithTitle:@"Discovery Mode On"
                                         text:@"Press the red pairing button on your Nintendo device, or click the WJoy icon and enable ."]];
}

- (void)onDiscoveryEnd
{
    [UserNotificationCenter
        deliver:[UserNotification
                    userNotificationWithTitle:@"Discovery Mode Off"
                                         text:@"Click the WJoy icon to re-enable discovery."]];
}

- (void)onDeviceConnected
{
    [UserNotificationCenter
        deliver:[UserNotification
                    userNotificationWithTitle:@"Connected"
                                         text:@"A device connected."]];
}

- (void)onDeviceBatteryStateChanged:(NSNotification*)notification
{
    Wiimote *device = [notification object];

    if([device userInfo] != nil ||
      ![device isBatteryLevelLow])
    {
        return;
    }

    [device setUserInfo:[NSDictionary dictionary]];

    [UserNotificationCenter
        deliver:[UserNotification
                    userNotificationWithTitle:@"Battery is Low"
                                         text:@"Check the remaining battery of your devices."]];
}

- (void)onDeviceDisconnected
{
    [UserNotificationCenter
        deliver:[UserNotification
                    userNotificationWithTitle:@"Disconnected"
                                         text:@"A device disconnected."]];
}

- (void)onCheckNewVersionFinished:(NSNotification*)notification
{
    return;
}

@end
