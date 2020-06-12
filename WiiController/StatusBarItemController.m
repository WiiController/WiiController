//
//  StatusBarItemController.m
//  WJoy
//
//  Created by alxn1 on 27.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <Wiimote/Wiimote.h>

#import "StatusBarItemController.h"

@implementation StatusBarItemController

+ (void)start
{
    static StatusBarItemController *singleton;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[StatusBarItemController alloc] initInternal];
    });
}

- (id)initInternal
{
    self = [super init];
    if(self == nil)
        return nil;

    m_Menu              = [[NSMenu alloc] initWithTitle:@"WJoyStatusBarMenu"];
    m_Item              = [[NSStatusBar systemStatusBar]
                                    statusItemWithLength:NSSquareStatusItemLength];

    m_DiscoveryMenuItem = [[NSMenuItem alloc]
                                    initWithTitle:@"Pair Device"
                                           action:@selector(beginDiscovery)
                                    keyEquivalent:@""];

    [m_DiscoveryMenuItem setTarget:[Wiimote class]];
    [m_DiscoveryMenuItem setEnabled:![Wiimote isDiscovering]];
    [m_Menu addItem:m_DiscoveryMenuItem];
    [m_Menu setAutoenablesItems:NO];
    [m_Menu setDelegate:(id)self];

    NSImage *icon = [[[NSApplication sharedApplication] applicationIconImage] copy];

    [icon setSize:NSMakeSize(20.0f, 20.0f)];

    [m_Item setImage:icon];
    [m_Item setMenu:m_Menu];
    [m_Item setHighlightMode:YES];

    [Wiimote setUseOneButtonClickConnection:
                [[NSUserDefaults standardUserDefaults] boolForKey:@"OneButtonClickConnection"]];

    return self;
}

- (void)dealloc
{
    [[NSStatusBar systemStatusBar] removeStatusItem:m_Item];
}

- (void)toggleOneButtonClickConnection
{
    [Wiimote setUseOneButtonClickConnection:
                    ![Wiimote isUseOneButtonClickConnection]];

    [[NSUserDefaults standardUserDefaults]
                                        setBool:[Wiimote isUseOneButtonClickConnection]
                                         forKey:@"OneButtonClickConnection"];
}

- (void)menuNeedsUpdate:(NSMenu*)menu
{
    for(Wiimote *wiimote in [Wiimote connectedDevices]) {
        [wiimote requestUpdateState];
    }

    while([m_Menu numberOfItems] > 1)
        [m_Menu removeItemAtIndex:1];

    if([Wiimote isBluetoothEnabled])
    {
        [m_DiscoveryMenuItem setImage:nil];

        if([Wiimote isDiscovering])
        {
            [m_DiscoveryMenuItem setEnabled:NO];
            [m_DiscoveryMenuItem setTitle:@"Discovering: Press red pairing button on Nintendo device"];
        }
        else
        {
            NSImage *icon = [NSImage imageNamed:NSImageNameBluetoothTemplate];
            [m_DiscoveryMenuItem setImage:icon];
            [m_DiscoveryMenuItem setEnabled:YES];
            [m_DiscoveryMenuItem setTitle:@"Pair Device"];
        }
    }
    else
    {
        NSImage *icon = [NSImage imageNamed:@"warning"];
        [icon setSize:NSMakeSize(16.0f, 16.0f)];
        [m_DiscoveryMenuItem setImage:icon];
        [m_DiscoveryMenuItem setEnabled:NO];
        [m_DiscoveryMenuItem setTitle:@"Bluetooth is disabled!"];
    }

    NSArray     *connectedDevices   = [Wiimote connectedDevices];
    NSUInteger   countConnected     = [connectedDevices count];

    if(countConnected > 0)
        [m_Menu addItem:[NSMenuItem separatorItem]];

    for(NSUInteger i = 0; i < countConnected; i++)
    {
        Wiimote         *device       = [connectedDevices objectAtIndex:i];
        NSString        *batteryLevel = @"-";

        if([device batteryLevel] >= 0.0)
            batteryLevel = [NSString stringWithFormat:@"%.0lf%%", [device batteryLevel]];

        NSMenuItem *item = [[NSMenuItem alloc]
            initWithTitle:[NSString stringWithFormat:@"%@ #%li (%@ Battery) / %@",
                [device marketingName],
                i+1,
                [device batteryLevelDescription],
                [device addressString]]
            action:nil
            keyEquivalent:@""];

        if([device isBatteryLevelLow])
        {
            NSImage *icon = [NSImage imageNamed:@"warning"];
            [icon setSize:NSMakeSize(16.0f, 16.0f)];
            [item setImage:icon];
        }

        [m_Menu addItem:item];
    }

    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Auto-connect to Paired Devices (Experimental)" action:@selector(toggleOneButtonClickConnection) keyEquivalent:@""];
    [item setTarget:self];
    [item setState:([Wiimote isUseOneButtonClickConnection])?(NSOnState):(NSOffState)];
    [m_Menu addItem:[NSMenuItem separatorItem]];
    [m_Menu addItem:item];

    item = [[NSMenuItem alloc] initWithTitle:@"Quit WJoy" action:@selector(terminate:) keyEquivalent:@"q"];
    [item setTarget:[NSApplication sharedApplication]];
    [m_Menu addItem:[NSMenuItem separatorItem]];
    [m_Menu addItem:item];
}

@end
