//
//  WiimoteUProController.m
//  Wiimote
//
//  Created by alxn1 on 16.06.13.
//

#import "WiimoteUProController.h"

@interface WiimoteUProController (PrivatePart)

- (void)reset;

@end

@implementation WiimoteUProController

+ (void)load
{
    [WiimoteExtension registerExtensionClass:[WiimoteUProController class]];
}

+ (NSData *)extensionSignature;
{
    static const uint8_t signature[] = { 0x00, 0x00, 0xA4, 0x20, 0x01, 0x20 };
    static NSData *result = nil;

    if (result == nil)
    {
        result = [[NSData alloc]
            initWithBytes:signature
                   length:sizeof(signature)];
    }

    return result;
}

+ (WiimoteExtensionMeritClass)meritClass
{
    return WiimoteExtensionMeritClassSystem;
}

+ (NSUInteger)minReportDataSize
{
    return sizeof(WiimoteDeviceUProControllerReport);
}

- (id)initWithOwner:(Wiimote *)owner
    eventDispatcher:(WiimoteEventDispatcher *)dispatcher
{
    self = [super initWithOwner:owner eventDispatcher:dispatcher];
    if (self == nil)
        return nil;

    [self reset];
    return self;
}

- (NSString *)name
{
    return WiimoteUProControllerName;
}

- (NSPoint)stickPosition:(WiimoteUProControllerStickType)stick
{
    return _stickPositions[stick];
}

- (BOOL)isButtonPressed:(WiimoteUProControllerButtonType)button
{
    return _buttonState[button];
}

- (NSPoint)normalizeStick:(WiimoteUProControllerStickType)stick position:(NSPoint)position
{
    // TODO: Implement normalization (if needed)
    // it seems like the WiiUPro sticks range between -0.6 and 0.6 with the current adjustments being applied in the handleReport method
    return position;
}

- (void)setStick:(WiimoteUProControllerStickType)stick position:(NSPoint)newPosition
{
    newPosition = [self normalizeStick:stick position:newPosition];

    if (WiimoteDeviceIsPointEqual(_stickPositions[stick], newPosition))
        return;

    _stickPositions[stick] = newPosition;

    [[self eventDispatcher]
        postUProController:self
                     stick:stick
           positionChanged:newPosition];
}

- (void)setButton:(WiimoteUProControllerButtonType)button pressed:(BOOL)pressed
{
    if (_buttonState[button] == pressed)
        return;

    _buttonState[button] = pressed;

    if (pressed)
    {
        [[self eventDispatcher]
            postUProController:self
                 buttonPressed:button];
    }
    else
    {
        [[self eventDispatcher]
            postUProController:self
                buttonReleased:button];
    }
}

- (void)handleButtonState:(uint16_t)state
{
    static const struct
    {
        WiimoteUProControllerButtonType type;
        WiimoteDeviceUProControllerReportButtonMask mask;
    } buttonMasks[] = {
        { WiimoteUProControllerButtonTypeA, WiimoteDeviceUProControllerReportButtonMaskA },
        { WiimoteUProControllerButtonTypeB, WiimoteDeviceUProControllerReportButtonMaskB },
        { WiimoteUProControllerButtonTypeX, WiimoteDeviceUProControllerReportButtonMaskX },
        { WiimoteUProControllerButtonTypeY, WiimoteDeviceUProControllerReportButtonMaskY },
        { WiimoteUProControllerButtonTypeUp, WiimoteDeviceUProControllerReportButtonMaskUp },
        { WiimoteUProControllerButtonTypeDown, WiimoteDeviceUProControllerReportButtonMaskDown },
        { WiimoteUProControllerButtonTypeLeft, WiimoteDeviceUProControllerReportButtonMaskLeft },
        { WiimoteUProControllerButtonTypeRight, WiimoteDeviceUProControllerReportButtonMaskRight },
        { WiimoteUProControllerButtonTypeL, WiimoteDeviceUProControllerReportButtonMaskL },
        { WiimoteUProControllerButtonTypeR, WiimoteDeviceUProControllerReportButtonMaskR },
        { WiimoteUProControllerButtonTypeZL, WiimoteDeviceUProControllerReportButtonMaskZL },
        { WiimoteUProControllerButtonTypeZR, WiimoteDeviceUProControllerReportButtonMaskZR }
    };

    for (NSUInteger i = 0; i < WiimoteUProControllerButtonCount - 2; i++)
        [self setButton:buttonMasks[i].type pressed:((state & buttonMasks[i].mask) == 0)];
}

- (void)handleAdditionalState:(uint8_t)state
{
    [self setButton:WiimoteUProControllerButtonTypeStickL
            pressed:((state & WiimoteDeviceUProControllerReportButtonMaskStrickL) == 0)];

    [self setButton:WiimoteUProControllerButtonTypeStickR
            pressed:((state & WiimoteDeviceUProControllerReportButtonMaskStrickR) == 0)];
}

- (void)handleReport:(const uint8_t *)extensionData length:(NSUInteger)length
{
    if (length < sizeof(WiimoteDeviceUProControllerReport))
        return;

    const WiimoteDeviceUProControllerReport *report = (const WiimoteDeviceUProControllerReport *)extensionData;

    [self setStick:WiimoteUProControllerStickTypeLeft
          position:NSMakePoint(
                       (((CGFloat)(report->leftStrickX & 0x0FFF)) / 2048.0) - 1.0f,
                       (((CGFloat)(report->leftStrickY & 0x0FFF)) / 2048.0) - 1.0f)];

    [self setStick:WiimoteUProControllerStickTypeRight
          position:NSMakePoint(
                       (((CGFloat)(report->rightStrickX & 0x0FFF)) / 2048.0) - 1.0f,
                       (((CGFloat)(report->rightStrickY & 0x0FFF)) / 2048.0) - 1.0f)];

    [self handleButtonState:report->buttonState];
    [self handleAdditionalState:report->additionalButtonState];
}

@end

@implementation WiimoteUProController (PrivatePart)

- (void)reset
{
    for (NSUInteger i = 0; i < WiimoteUProControllerButtonCount; i++)
        _buttonState[i] = NO;

    for (NSUInteger i = 0; i < WiimoteUProControllerStickCount; i++)
        _stickPositions[i] = NSZeroPoint;
}

@end
