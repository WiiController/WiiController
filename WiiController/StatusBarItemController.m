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
{
    NSMenu          *_menu;
    NSStatusItem    *_item;
    NSMenuItem      *_discoveryMenuItem;
}

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

    _menu              = [[NSMenu alloc] initWithTitle:@"WiiController"];
    _item              = [[NSStatusBar systemStatusBar]
                                    statusItemWithLength:NSSquareStatusItemLength];

    _discoveryMenuItem = [[NSMenuItem alloc]
                                    initWithTitle:@"Pair Device"
                                           action:@selector(beginDiscovery)
                                    keyEquivalent:@""];

    [_discoveryMenuItem setTarget:[Wiimote class]];
    [_discoveryMenuItem setEnabled:![Wiimote isDiscovering]];
    [_menu addItem:_discoveryMenuItem];
    [_menu setAutoenablesItems:NO];
    [_menu setDelegate:(id)self];

    NSImage *icon = [[[NSApplication sharedApplication] applicationIconImage] copy];

    [icon setSize:NSMakeSize(20.0f, 20.0f)];

    [_item setImage:icon];
    [_item setMenu:_menu];
    [_item setHighlightMode:YES];

    [Wiimote setUseOneButtonClickConnection:
                [[NSUserDefaults standardUserDefaults] boolForKey:@"OneButtonClickConnection"]];

    return self;
}

- (void)dealloc
{
    [[NSStatusBar systemStatusBar] removeStatusItem:_item];
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

    while([_menu numberOfItems] > 1)
        [_menu removeItemAtIndex:1];

    if([Wiimote isBluetoothEnabled])
    {
        [_discoveryMenuItem setImage:nil];

        if([Wiimote isDiscovering])
        {
            [_discoveryMenuItem setEnabled:NO];
            [_discoveryMenuItem setTitle:@"Discovering: Press red pairing button on Nintendo device"];
        }
        else
        {
            NSImage *icon = [NSImage imageNamed:NSImageNameBluetoothTemplate];
            [_discoveryMenuItem setImage:icon];
            [_discoveryMenuItem setEnabled:YES];
            [_discoveryMenuItem setTitle:@"Pair Device"];
        }
    }
    else
    {
        NSImage *icon = [NSImage imageNamed:@"warning"];
        [icon setSize:NSMakeSize(16.0f, 16.0f)];
        [_discoveryMenuItem setImage:icon];
        [_discoveryMenuItem setEnabled:NO];
        [_discoveryMenuItem setTitle:@"Bluetooth is disabled!"];
    }

    NSArray     *connectedDevices   = [Wiimote connectedDevices];
    NSUInteger   countConnected     = [connectedDevices count];

    if(countConnected > 0)
        [_menu addItem:[NSMenuItem separatorItem]];

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

        [_menu addItem:item];
    }

    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Auto-connect to Paired Devices (Experimental)" action:@selector(toggleOneButtonClickConnection) keyEquivalent:@""];
    [item setTarget:self];
    [item setState:([Wiimote isUseOneButtonClickConnection])?(NSOnState):(NSOffState)];
    [_menu addItem:[NSMenuItem separatorItem]];
    [_menu addItem:item];

    item = [[NSMenuItem alloc] initWithTitle:@"Quit WiiController" action:@selector(terminate:) keyEquivalent:@"q"];
    [item setTarget:[NSApplication sharedApplication]];
    [_menu addItem:[NSMenuItem separatorItem]];
    [_menu addItem:item];
}

@end
