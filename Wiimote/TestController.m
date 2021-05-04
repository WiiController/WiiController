//
//  TestController.m
//  Wiimote
//
//  Created by alxn1 on 09.10.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "TestController.h"

#import <Wiimote/WiimoteEventSystem.h>
#import <Wiimote/WiimoteWatchdog.h>

@implementation TestController

- (void)updateWindowState
{
    [_discoveryButton setEnabled:
                          (!_isDiscovering) && (_connectedWiimotes == 0)];

    [_connectedTextField setStringValue:
                             ((_connectedWiimotes == 0) ? (@"No wii remote connected") : (@"Wii remote connected"))];
}

- (void)awakeFromNib
{
    [[OCLog sharedLog] setHandler:self];
    [[OCLog sharedLog] setLevel:OCLogLevelDebug];
    [[WiimoteWatchdog sharedWatchdog] setEnabled:YES];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(discoveryBegin)
               name:WiimoteBeginDiscoveryNotification
             object:nil];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(discoveryEnd)
               name:WiimoteEndDiscoveryNotification
             object:nil];

    [[WiimoteEventSystem defaultEventSystem] addObserver:self];
    [[WiimoteWatchdog sharedWatchdog] setEnabled:YES];

    [self updateWindowState];
    [self discovery:self];
}

- (IBAction)toggleUseOneButtonClickConnection:(id)sender
{
    [Wiimote setUseOneButtonClickConnection:[sender state] == NSOnState];
}

- (IBAction)toggleDebugOutput:(id)sender
{
    [[OCLog sharedLog] setLevel:
                           (([_debugCheckBox state] == NSOnState) ? (OCLogLevelDebug) : (OCLogLevelError))];
}

- (IBAction)discovery:(id)sender
{
    [Wiimote beginDiscovery];
}

- (IBAction)clearLog:(id)sender
{
    [_log setString:@""];
}

- (IBAction)detectMotionPlus:(id)sender
{
    for (Wiimote *wiimote in [Wiimote connectedDevices])
        [wiimote detectMotionPlus];
}

- (IBAction)toggleVibration:(id)sender
{
    for (Wiimote *wiimote in [Wiimote connectedDevices])
        [wiimote setVibrationEnabled:![wiimote isVibrationEnabled]];
}

- (void)log:(NSString *)logLine
{
    NSAttributedString *tmp = [[NSAttributedString alloc]
        initWithString:[NSString stringWithFormat:@"%@\n", logLine]];

    [[_log textStorage] appendAttributedString:tmp];
    [tmp release];
}

- (void)discoveryBegin
{
    _isDiscovering = YES;
    [self updateWindowState];
    [self log:@"Begin discovery..."];
}

- (void)discoveryEnd
{
    _isDiscovering = NO;
    [self updateWindowState];
    [self log:@"End discovery"];
}

- (void)wiimoteConnected
{
    _connectedWiimotes++;
    [self updateWindowState];
}

- (void)wiimoteDisconnected
{
    _connectedWiimotes--;
    [self updateWindowState];
}

- (void)wiimoteEvent:(WiimoteEvent *)event
{
    if ([[event path] isEqualToString:@"Connect"])
    {
        [[event wiimote] setHighlightedLEDMask:WiimoteLEDFlagOne];
        [[event wiimote] playConnectEffect];
        [self wiimoteConnected];
    }

    if ([[event path] isEqualToString:@"Disconnect"])
        [self wiimoteDisconnected];

    [self log:
              [NSString stringWithFormat:@"%@ (%@): %@: %lf",
                                         [[event wiimote] modelName],
                                         [[event wiimote] addressString],
                                         [event path],
                                         [event value]]];
}

- (void)log:(OCLog *)log
           level:(OCLogLevel)level
      sourceFile:(const char *)sourceFile
            line:(NSUInteger)line
    functionName:(const char *)functionName
         message:(NSString *)message
{
    [self log:
              [NSString stringWithFormat:
                            @"[%s (%llu)]:[%s]: %@",
                            sourceFile,
                            (unsigned long long)line,
                            functionName,
                            message]];
}

@end
