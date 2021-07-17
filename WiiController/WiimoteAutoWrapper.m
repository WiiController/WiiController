//
//  WiimoteAutoWrapper.m
//  WJoy
//
//  Created by alxn1 on 27.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteAutoWrapper.h"
#import "UserActivityNotifier.h"
#import "ButtonConfiguration.h"

#import <Wiimote/WiimoteClassicControllerDelegate.h>
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
    NSPoint uProMinL, uProMaxL, uProMinR, uProMaxR;
    NSPoint heroGuitarMinStick, heroGuitarMaxStick;
    CGFloat heroGuitarMinShift, heroGuitarMaxShift;
}

static NSUInteger maxConnectedDevices = 0;
static id<ProfileProvider> profileProvider;

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

+ (void)setProfileProvider:(id<ProfileProvider>)provider
{
    profileProvider = provider;
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

- (ButtonConfiguration *)profile
{
    return [profileProvider profileForDevice:_device];
}

- (void)wiimote:(Wiimote *)wiimote buttonPressed:(WiimoteButtonType)button
{
    [_hidState setButton:[[self profile] buttonNumberForExtensionName:@"Wiimote" buttonNumber:button] pressed:YES];
}

- (void)wiimote:(Wiimote *)wiimote buttonReleased:(WiimoteButtonType)button
{
    [_hidState setButton:[[self profile] buttonNumberForExtensionName:@"Wiimote" buttonNumber:button] pressed:NO];
}

- (void)wiimoteDisconnected:(Wiimote *)wiimote
{
}

- (void)wiimote:(Wiimote *)wiimote nunchuck:(WiimoteNunchuckExtension *)nunchuck buttonPressed:(WiimoteNunchuckButtonType)button
{
    [_hidState setButton:[[self profile] buttonNumberForExtensionName:nunchuck.name buttonNumber:button] pressed:YES];
}

- (void)wiimote:(Wiimote *)wiimote nunchuck:(WiimoteNunchuckExtension *)nunchuck buttonReleased:(WiimoteNunchuckButtonType)button
{
    [_hidState setButton:[[self profile] buttonNumberForExtensionName:nunchuck.name buttonNumber:button] pressed:NO];
}

- (void)wiimote:(Wiimote *)wiimote nunchuck:(WiimoteNunchuckExtension *)nunchuck stickPositionChanged:(NSPoint)position
{
    [_hidState setPointer:[[self profile] axisNumberForExtensionName:nunchuck.name axisNumber:0] position:position];
}

- (void)wiimote:(Wiimote *)wiimote
    classicController:(WiimoteClassicControllerExtension *)classic
        buttonPressed:(WiimoteClassicControllerButtonType)button
{
    [_hidState setButton:[[self profile] buttonNumberForExtensionName:classic.name buttonNumber:button] pressed:YES];
}

- (void)wiimote:(Wiimote *)wiimote
    classicController:(WiimoteClassicControllerExtension *)classic
       buttonReleased:(WiimoteClassicControllerButtonType)button
{
    [_hidState setButton:[[self profile] buttonNumberForExtensionName:classic.name buttonNumber:button] pressed:NO];
}

- (void)wiimote:(Wiimote *)wiimote
    classicController:(WiimoteClassicControllerExtension *)classic
                stick:(WiimoteClassicControllerStickType)stick
      positionChanged:(NSPoint)position
{
    [_hidState setPointer:[[self profile] axisNumberForExtensionName:classic.name axisNumber:stick] position:position];
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

    [_hidState setPointer:[[self profile] axisNumberForExtensionName:classic.name axisNumber:WiimoteClassicControllerStickCount] position:_shiftsState];
}

- (void)wiimote:(Wiimote *)wiimote
    uProController:(WiimoteUProControllerExtension *)uPro
     buttonPressed:(WiimoteUProControllerButtonType)button
{
    [_hidState setButton:[[self profile] buttonNumberForExtensionName:uPro.name buttonNumber:button] pressed:YES];
}

- (void)wiimote:(Wiimote *)wiimote
    uProController:(WiimoteUProControllerExtension *)uPro
    buttonReleased:(WiimoteUProControllerButtonType)button
{
    [_hidState setButton:[[self profile] buttonNumberForExtensionName:uPro.name buttonNumber:button] pressed:NO];
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
        uProMinL.x = MIN(uProMinL.x, position.x);
        uProMinL.y = MIN(uProMinL.y, position.y);

        uProMaxL.x = MAX(uProMaxL.x, position.x);
        uProMaxL.y = MAX(uProMaxL.y, position.y);

        position.x = (position.x - uProMinL.x) / (uProMaxL.x - uProMinL.x) * 2 - 1;
        position.y = (position.y - uProMinL.y) / (uProMaxL.y - uProMinL.y) * 2 - 1;
        break;
    case WiimoteUProControllerStickTypeRight:
        uProMinR.x = MIN(uProMinR.x, position.x);
        uProMinR.y = MIN(uProMinR.y, position.y);

        uProMaxR.x = MAX(uProMaxR.x, position.x);
        uProMaxR.y = MAX(uProMaxR.y, position.y);

        position.x = (position.x - uProMinR.x) / (uProMaxR.x - uProMinR.x) * 2 - 1;
        position.y = (position.y - uProMinR.y) / (uProMaxR.y - uProMinR.y) * 2 - 1;
        break;
    }

    //    NSLog(@"\nMinLx: %f\tMinLy: %f\tMaxLx: %f\tMaxLy: %f", minL.x, minL.y, maxL.x, maxL.y);
    //    NSLog(@"\nMinRx: %f\tMinRy: %f\tMaxRx: %f\tMaxRy: %f", minR.x, minR.y, maxR.x, maxR.y);

    [_hidState setPointer:[[self profile] axisNumberForExtensionName:uPro.name axisNumber:stick] position:position];
}

- (void)wiimote:(Wiimote *)wiimote heroGuitar:(WiimoteHeroGuitarExtension *)heroGuitar buttonPressed:(WiimoteHeroGuitarButtonType)button
{
    [_hidState setButton:[[self profile] buttonNumberForExtensionName:heroGuitar.name buttonNumber:button] pressed:YES];
}

- (void)wiimote:(Wiimote *)wiimote heroGuitar:(WiimoteHeroGuitarExtension *)heroGuitar buttonReleased:(WiimoteHeroGuitarButtonType)button
{
    [_hidState setButton:[[self profile] buttonNumberForExtensionName:heroGuitar.name buttonNumber:button] pressed:NO];
}

- (void)wiimote:(Wiimote *)wiimote heroGuitar:(WiimoteHeroGuitarExtension *)heroGuitar stickPositionChanged:(NSPoint)position
{
    // Calibrate on the fly, like U Pro controller
    heroGuitarMinStick.x = MIN(heroGuitarMinStick.x, position.x);
    heroGuitarMinStick.y = MIN(heroGuitarMinStick.y, position.y);
    
    heroGuitarMaxStick.x = MAX(heroGuitarMaxStick.x, position.x);
    heroGuitarMaxStick.y = MAX(heroGuitarMaxStick.y, position.y);
    
    position.x = (position.x - heroGuitarMinStick.x) / (heroGuitarMaxStick.x - heroGuitarMinStick.x) * 2 - 1;
    position.y = (position.y - heroGuitarMinStick.y) / (heroGuitarMaxStick.y - heroGuitarMinStick.y) * 2 - 1;
    
    [_hidState setPointer:[[self profile] axisNumberForExtensionName:heroGuitar.name axisNumber:0] position:position];
}

- (void)wiimote:(Wiimote *)wiimote heroGuitar:(WiimoteHeroGuitarExtension *)heroGuitar analogShiftPositionChanged:(CGFloat)position
{
    // Calibrate on the fly, like U Pro controller
    heroGuitarMinShift = MIN(heroGuitarMinShift, position);
    heroGuitarMaxShift = MAX(heroGuitarMaxShift, position);
    position = (position - heroGuitarMinShift) / (heroGuitarMaxShift - heroGuitarMinShift) * 2 - 1;
    
    [_hidState setPointer:[[self profile] axisNumberForExtensionName:heroGuitar.name axisNumber:1] position:(CGPoint){ 0, position }];
}

- (void)wiimote:(Wiimote *)wiimote extensionDisconnected:(WiimoteExtension *)extension
{
    _shiftsState = NSZeroPoint;

    for (NSUInteger i = 0; i <= WiimoteClassicControllerStickCount; i++)
        [_hidState setPointer:[[self profile] axisNumberForExtensionName:WiimoteClassicControllerName axisNumber:i] position:NSZeroPoint];

    for (NSUInteger i = 0; i < WiimoteClassicControllerButtonCount; i++)
        [_hidState setButton:[[self profile] buttonNumberForExtensionName:WiimoteClassicControllerName buttonNumber:i] pressed:NO];
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
