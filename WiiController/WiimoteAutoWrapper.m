//
//  WiimoteAutoWrapper.m
//  WJoy
//
//  Created by alxn1 on 27.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteAutoWrapper.h"
#import "UserActivityNotifier.h"

#import <Cocoa/Cocoa.h>

@interface WiimoteAutoWrapper () <WiimoteDelegate>

@end

@implementation WiimoteAutoWrapper
{
    Wiimote *_device;
    VHIDDevice *_hidState;
    NSPoint _shiftsState;
    WJoyDevice *_wJoy;
    // For calibration of the analog sticks
    NSPoint minL, maxL, minR, maxR;
}

static NSUInteger maxConnectedDevices = 0;

+ (NSUInteger)maxConnectedDevices
{
    return maxConnectedDevices;
}

+ (void)setMaxConnectedDevices:(NSUInteger)count
{
    if (maxConnectedDevices == count)
        return;

    maxConnectedDevices = count;

    while ([[Wiimote connectedDevices] count] > count)
    {
        NSArray *connectedDevices = [Wiimote connectedDevices];
        Wiimote *device = [connectedDevices objectAtIndex:[connectedDevices count] - 1];

        [device disconnect];
    }
}

+ (void)start
{
    if (![WJoyDevice prepare])
    {
        [[NSApplication sharedApplication] terminate:self];
        return;
    }

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(newWiimoteDeviceNotification:)
               name:WiimoteConnectedNotification
             object:nil];
}

- (void)wiimote:(Wiimote *)wiimote buttonPressed:(WiimoteButtonType)button
{
    [_hidState setButton:button pressed:YES];
}

- (void)wiimote:(Wiimote *)wiimote buttonReleased:(WiimoteButtonType)button
{
    [_hidState setButton:button pressed:NO];
}

- (void)wiimoteDisconnected:(Wiimote *)wiimote
{
}

- (void)wiimote:(Wiimote *)wiimote nunchuck:(WiimoteNunchuckExtension *)nunchuck buttonPressed:(WiimoteNunchuckButtonType)button
{
    [_hidState setButton:WiimoteButtonCount + button pressed:YES];
}

- (void)wiimote:(Wiimote *)wiimote nunchuck:(WiimoteNunchuckExtension *)nunchuck buttonReleased:(WiimoteNunchuckButtonType)button
{
    [_hidState setButton:WiimoteButtonCount + button pressed:NO];
}

- (void)wiimote:(Wiimote *)wiimote nunchuck:(WiimoteNunchuckExtension *)nunchuck stickPositionChanged:(NSPoint)position
{
    [_hidState setPointer:0 position:position];
}

- (void)wiimote:(Wiimote *)wiimote
    classicController:(WiimoteClassicControllerExtension *)classic
        buttonPressed:(WiimoteClassicControllerButtonType)button
{
    [_hidState setButton:WiimoteButtonCount + button pressed:YES];
}

- (void)wiimote:(Wiimote *)wiimote
    classicController:(WiimoteClassicControllerExtension *)classic
       buttonReleased:(WiimoteClassicControllerButtonType)button
{
    [_hidState setButton:WiimoteButtonCount + button pressed:NO];
}

- (void)wiimote:(Wiimote *)wiimote
    classicController:(WiimoteClassicControllerExtension *)classic
                stick:(WiimoteClassicControllerStickType)stick
      positionChanged:(NSPoint)position
{
    [_hidState setPointer:stick position:position];
}

- (void)wiimote:(Wiimote *)wiimote
    classicController:(WiimoteClassicControllerExtension *)classic
          analogShift:(WiimoteClassicControllerAnalogShiftType)shift
      positionChanged:(CGFloat)position
{
    switch (shift)
    {
    case WiimoteClassicControllerAnalogShiftTypeLeft:
        _shiftsState.x = position;
        break;

    case WiimoteClassicControllerAnalogShiftTypeRight:
        _shiftsState.y = position;
        break;
    }

    [_hidState setPointer:WiimoteClassicControllerStickCount position:_shiftsState];
}

- (void)wiimote:(Wiimote *)wiimote
    uProController:(WiimoteUProControllerExtension *)uPro
     buttonPressed:(WiimoteUProControllerButtonType)button
{
    [_hidState setButton:WiimoteButtonCount + button pressed:YES];
}

- (void)wiimote:(Wiimote *)wiimote
    uProController:(WiimoteUProControllerExtension *)uPro
    buttonReleased:(WiimoteUProControllerButtonType)button
{
    [_hidState setButton:WiimoteButtonCount + button pressed:NO];
}

- (void)wiimote:(Wiimote *)wiimote
     uProController:(WiimoteUProControllerExtension *)uPro
              stick:(WiimoteUProControllerStickType)stick
    positionChanged:(NSPoint)position
{
    // Calibrate the analog sticks on the fly
    // Thanks to Kametrixom for the fix ( https://github.com/Kametrixom/wjoy-1/commit/686c49a5de411ba77f459ba1325b17ba1b44c343 )
    switch (stick)
    {
    case WiimoteUProControllerStickTypeLeft:
        minL.x = MIN(minL.x, position.x);
        minL.y = MIN(minL.y, position.y);

        maxL.x = MAX(maxL.x, position.x);
        maxL.y = MAX(maxL.y, position.y);

        position.x = (position.x - minL.x) / (maxL.x - minL.x) * 2 - 1;
        position.y = (position.y - minL.y) / (maxL.y - minL.y) * 2 - 1;
        break;
    case WiimoteUProControllerStickTypeRight:
        minR.x = MIN(minR.x, position.x);
        minR.y = MIN(minR.y, position.y);

        maxR.x = MAX(maxR.x, position.x);
        maxR.y = MAX(maxR.y, position.y);

        position.x = (position.x - minR.x) / (maxR.x - minR.x) * 2 - 1;
        position.y = (position.y - minR.y) / (maxR.y - minR.y) * 2 - 1;
        break;
    }

//    NSLog(@"\nMinLx: %f\tMinLy: %f\tMaxLx: %f\tMaxLy: %f", minL.x, minL.y, maxL.x, maxL.y);
//    NSLog(@"\nMinRx: %f\tMinRy: %f\tMaxRx: %f\tMaxRy: %f", minR.x, minR.y, maxR.x, maxR.y);

    [_hidState setPointer:stick position:position];
}

- (void)wiimote:(Wiimote *)wiimote extensionDisconnected:(WiimoteExtension *)extension
{
    _shiftsState = NSZeroPoint;

    for (NSUInteger i = 0; i <= WiimoteClassicControllerStickCount; i++)
        [_hidState setPointer:0 position:NSZeroPoint];

    for (NSUInteger i = 0; i < WiimoteClassicControllerButtonCount; i++)
        [_hidState setButton:WiimoteButtonCount + i pressed:NO];
}

- (void)VHIDDevice:(VHIDDevice *)device stateChanged:(NSData *)state
{
    [[UserActivityNotifier sharedNotifier] notify];
    [_wJoy updateHIDState:state];
}

- (void)applicationWillTerminateNotification:(NSNotification *)notification
{
    [_device disconnect];
}

+ (NSString *)wjoyNameFromWiimote:(Wiimote *)device
{
    return [NSString stringWithFormat:@"%@ (%@)", [device marketingName], [device addressString]];
}

+ (void)newWiimoteDeviceNotification:(NSNotification *)notification
{
    (void)[[WiimoteAutoWrapper alloc]
        initWithWiimote:(Wiimote *)[notification object]];
}

- (id)initWithWiimote:(Wiimote *)device
{
    self = [super init];
    if (self == nil)
        return nil;

    if ([[Wiimote connectedDevices] count] > [WiimoteAutoWrapper maxConnectedDevices])
    {
        [device disconnect];
        return nil;
    }

    _device = device;
    _hidState = [[VHIDDevice alloc] initWithType:VHIDDeviceTypeJoystick
                                    pointerCount:WiimoteClassicControllerStickCount + 1
                                     buttonCount:WiimoteButtonCount + WiimoteClassicControllerButtonCount
                                      isRelative:NO];

    _wJoy = [[WJoyDevice alloc]
        initWithHIDDescriptor:[_hidState descriptor]
                productString:[WiimoteAutoWrapper wjoyNameFromWiimote:device]];

    if (_hidState == nil || _wJoy == nil)
    {
        [device disconnect];
        return nil;
    }

    [_device setDelegate:self];
    [_hidState setDelegate:self];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(applicationWillTerminateNotification:)
               name:NSApplicationWillTerminateNotification
             object:[NSApplication sharedApplication]];

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
