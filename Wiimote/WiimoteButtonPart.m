//
//  WiimoteButtonPart.m
//  Wiimote
//
//  Created by alxn1 on 30.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteButtonPart.h"
#import "WiimoteEventDispatcher+Button.h"
#import "WiimoteProtocol.h"

@implementation WiimoteButtonPart
{
@private
    BOOL _buttonState[WiimoteButtonCount];
}

+ (void)load
{
    [WiimotePart registerPartClass:[WiimoteButtonPart class]];
}

- (id)initWithOwner:(Wiimote *)owner
    eventDispatcher:(WiimoteEventDispatcher *)dispatcher
          ioManager:(WiimoteIOManager *)ioManager;
{
    self = [super initWithOwner:owner eventDispatcher:dispatcher ioManager:ioManager];
    if (self == nil)
        return nil;

    [self reset];
    return self;
}

- (BOOL)isButtonPressed:(WiimoteButtonType)button
{
    return _buttonState[button];
}

- (void)handleReport:(WiimoteDeviceReport *)report
{
    if ([report length] < sizeof(WiimoteDeviceButtonState))
        return;

    const WiimoteDeviceButtonState *buttonReport = (const WiimoteDeviceButtonState *)[report data];

    WiimoteDeviceButtonState state = OSSwapBigToHostConstInt16(*buttonReport);

    [self setButton:WiimoteButtonTypeLeft pressed:((state & WiimoteDeviceButtonStateFlagLeft) != 0)];
    [self setButton:WiimoteButtonTypeRight pressed:((state & WiimoteDeviceButtonStateFlagRight) != 0)];
    [self setButton:WiimoteButtonTypeDown pressed:((state & WiimoteDeviceButtonStateFlagDown) != 0)];
    [self setButton:WiimoteButtonTypeUp pressed:((state & WiimoteDeviceButtonStateFlagUp) != 0)];
    [self setButton:WiimoteButtonTypePlus pressed:((state & WiimoteDeviceButtonStateFlagPlus) != 0)];
    [self setButton:WiimoteButtonTypeTwo pressed:((state & WiimoteDeviceButtonStateFlagTwo) != 0)];
    [self setButton:WiimoteButtonTypeOne pressed:((state & WiimoteDeviceButtonStateFlagOne) != 0)];
    [self setButton:WiimoteButtonTypeB pressed:((state & WiimoteDeviceButtonStateFlagB) != 0)];
    [self setButton:WiimoteButtonTypeA pressed:((state & WiimoteDeviceButtonStateFlagA) != 0)];
    [self setButton:WiimoteButtonTypeMinus pressed:((state & WiimoteDeviceButtonStateFlagMinus) != 0)];
    [self setButton:WiimoteButtonTypeHome pressed:((state & WiimoteDeviceButtonStateFlagHome) != 0)];
}

- (void)disconnected
{
    [self reset];
}

- (void)setButton:(WiimoteButtonType)button pressed:(BOOL)pressed
{
    if (_buttonState[button] == pressed)
        return;

    _buttonState[button] = pressed;

    if (pressed)
        [[self eventDispatcher] postButtonPressedNotification:button];
    else
        [[self eventDispatcher] postButtonReleasedNotification:button];
}

- (void)reset
{
    for (NSUInteger i = 0; i < WiimoteButtonCount; i++)
        _buttonState[i] = NO;
}

@end
