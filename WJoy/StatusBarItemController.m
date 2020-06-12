//
//  StatusBarItemController.m
//  WJoy
//
//  Created by alxn1 on 27.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <Wiimote/Wiimote.h>

#import "StatusBarItemController.h"

@interface StatusBarItemController (PrivatePart)

- (id)initInternal;

@end

@implementation StatusBarItemController

+ (void)start
{
    (void)[[StatusBarItemController alloc] initInternal];
}

@end

@implementation StatusBarItemController (PrivatePart)

- (id)initInternal
{
    self = [super init];
    if(self == nil)
        return nil;

    m_Menu              = [[NSMenu alloc] initWithTitle:@"WJoyStatusBarMenu"];
    m_Item              = [[NSStatusBar systemStatusBar]
                                    statusItemWithLength:NSSquareStatusItemLength];

    m_DiscoveryMenuItem = [[NSMenuItem alloc]
                                    initWithTitle:@"Begin Dicovery"
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
            [m_DiscoveryMenuItem setTitle:@"Discovering: Press red pairing button"];
        }
        else
        {
            [m_DiscoveryMenuItem setEnabled:YES];
            [m_DiscoveryMenuItem setTitle:@"Turn on Discovery"];
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

        NSMenuItem      *item         = [[NSMenuItem alloc]
                                            initWithTitle:[NSString stringWithFormat:
                                                                @"%@ #%li (%@ Battery) / %@",
                                                    [device modelName],
                                                                    i+1,
                                                                    batteryLevel,
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

    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Automatically connect when device powers on" action:@selector(toggleOneButtonClickConnection) keyEquivalent:@""];
    [item setTarget:self];
    [item setState:([Wiimote isUseOneButtonClickConnection])?(NSOnState):(NSOffState)];
    [m_Menu addItem:[NSMenuItem separatorItem]];
    [m_Menu addItem:item];

    item = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
    [item setTarget:[NSApplication sharedApplication]];
    [m_Menu addItem:[NSMenuItem separatorItem]];
    [m_Menu addItem:item];
}

@end
