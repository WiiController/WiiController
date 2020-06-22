//
//  NotificationCenter.m
//  WJoy
//
//  Created by alxn1 on 27.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <Wiimote/Wiimote.h>

#import "NotificationCenter.h"

@implementation NotificationCenter {
    BOOL _discoveredDevice;
}

+ (void)start
{
    static NotificationCenter *singleton;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[NotificationCenter alloc] initInternal];
    });
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
                               selector:@selector(onDeviceConnected:)
                                   name:WiimoteConnectedNotification
                                 object:nil];

    [[NSNotificationCenter defaultCenter]
                            addObserver:self
                               selector:@selector(onDeviceBatteryStateChanged:)
                                   name:WiimoteBatteryLevelUpdatedNotification
                                 object:nil];

    [[NSNotificationCenter defaultCenter]
                            addObserver:self
                               selector:@selector(onDeviceDisconnected:)
                                   name:WiimoteDisconnectedNotification
                                 object:nil];

    [UserNotificationCenter setDelegate:self];

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onDiscoveryBegin
{
    [UserNotificationCenter
        deliver:[UserNotification
                    userNotificationWithTitle:@"Pairing Enabled"
                                         text:[NSString stringWithFormat:@"Press the red pairing button on your Nintendo device. Expires in %d seconds.", WIIMOTE_INQUIRY_TIME_IN_SECONDS]]];
}

- (void)onDiscoveryEnd
{
    // Don't overwrite "connected" notification
    if (_discoveredDevice)
    {
        _discoveredDevice = NO;
        return;
    }

    [UserNotificationCenter
        deliver:[UserNotification
                    userNotificationWithTitle:@"Pairing Disabled"
                                         text:@"Select Pair Device from the WiiController menu to re-enable pairing."]];
}

- (void)onDeviceConnected:(NSNotification *)notification
{
    _discoveredDevice = YES;
    Wiimote *device = [notification object];
    [UserNotificationCenter
        deliver:[UserNotification
                    userNotificationWithTitle:@"Device Connected"
                                         text:[NSString stringWithFormat:@"Connected to %@ / %@", [device marketingName], [device addressString]]]];
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
                    userNotificationWithTitle:@"Low Battery"
                                         text:[NSString stringWithFormat: @"%@ has %@ battery remaining.", [device marketingName], [device batteryLevelDescription]]]];
}

- (void)onDeviceDisconnected:(NSNotification *)notification
{
    Wiimote *device = [notification object];
    [UserNotificationCenter
        deliver:[UserNotification
                    userNotificationWithTitle:@"Device Disconnected"
                                         text:[NSString stringWithFormat: @"%@ disconnected.", [device marketingName]]]];
}

@end
