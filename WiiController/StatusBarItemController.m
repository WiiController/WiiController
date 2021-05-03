//
//  StatusBarItemController.m
//  WJoy
//
//  Created by alxn1 on 27.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <Wiimote/Wiimote.h>

#import "StatusBarItemController.h"

@interface StatusBarItemController () <NSMenuDelegate>

@end

@implementation StatusBarItemController
{
    NSMenu *_menu;
    NSStatusItem *_item;
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
    if (self == nil)
        return nil;

    _menu = [[NSMenu alloc] initWithTitle:@"WiiController"];
    _item = [[NSStatusBar systemStatusBar]
        statusItemWithLength:NSSquareStatusItemLength];

    [_menu setDelegate:self];

    NSImage *icon = [NSImage imageNamed:@"wiimote"];

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

- (void)menuNeedsUpdate:(NSMenu *)menu
{
    for (Wiimote *wiimote in [Wiimote connectedDevices])
    {
        [wiimote requestUpdateState];
    }

    [_menu removeAllItems];

    __auto_type discoveryItem = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];

    if (wiimoteIsBluetoothEnabled())
    {
        if ([Wiimote isDiscovering])
        {
            [discoveryItem setTitle:@"Discovering: Press red pairing button on Nintendo device"];
        }
        else
        {
            NSImage *icon = [NSImage imageNamed:NSImageNameBluetoothTemplate];
            [discoveryItem setImage:icon];
            [discoveryItem setTitle:@"Pair Device"];
            [discoveryItem setTarget:[Wiimote class]];
            [discoveryItem setAction:@selector(beginDiscovery)];
        }
    }
    else
    {
        NSImage *icon = [NSImage imageNamed:@"warning"];
        [icon setSize:NSMakeSize(16.0f, 16.0f)];
        [discoveryItem setImage:icon];
        [discoveryItem setTitle:@"Bluetooth is disabled!"];
    }

    [_menu addItem:discoveryItem];

    [_menu addItem:[NSMenuItem separatorItem]];

    NSArray *connectedDevices = [Wiimote connectedDevices];
    NSUInteger countConnected = [connectedDevices count];

    [_menu addItem:[[NSMenuItem alloc] initWithTitle:(countConnected ? @"Connected:" : @"No Devices Connected") action:nil keyEquivalent:@""]];
    for (NSUInteger i = 0; i < countConnected; i++)
    {
        Wiimote *device = [connectedDevices objectAtIndex:i];
        NSString *batteryLevel = @"-";

        if ([device batteryLevel] >= 0.0)
            batteryLevel = [NSString stringWithFormat:@"%.0lf%%", [device batteryLevel]];

        NSMenuItem *item = [[NSMenuItem alloc]
            initWithTitle:[NSString stringWithFormat:@"%@ #%li (%@ Battery) / %@",
                                                     [device marketingName],
                                                     i + 1,
                                                     [device batteryLevelDescription],
                                                     [device addressString]]
                   action:nil
            keyEquivalent:@""];
        [item setIndentationLevel:1];

        if ([device isBatteryLevelLow])
        {
            NSImage *icon = [NSImage imageNamed:@"warning"];
            [icon setSize:NSMakeSize(16.0f, 16.0f)];
            [item setImage:icon];
        }

        [_menu addItem:item];
    }

    [_menu addItem:[NSMenuItem separatorItem]];

    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Auto-connect to Paired Devices (Experimental)" action:@selector(toggleOneButtonClickConnection) keyEquivalent:@""];
    [item setTarget:self];
    [item setState:([Wiimote isUseOneButtonClickConnection]) ? (NSOnState) : (NSOffState)];
    [_menu addItem:item];

    [_menu addItem:[NSMenuItem separatorItem]];

    item = [[NSMenuItem alloc] initWithTitle:@"About WiiController" action:@selector(showAboutPanel:) keyEquivalent:@""];
    [item setTarget:self];
    [_menu addItem:item];

    [_menu addItem:[NSMenuItem separatorItem]];

    item = [[NSMenuItem alloc] initWithTitle:@"Quit WiiController" action:@selector(terminate:) keyEquivalent:@"q"];
    [item setTarget:[NSApplication sharedApplication]];
    [_menu addItem:item];
}

- (void)showAboutPanel:(id)sender
{
    __auto_type app = [NSApplication sharedApplication];
    [app orderFrontStandardAboutPanel:nil];
    [app unhide:nil];
}

@end
