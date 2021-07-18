//
//  WiimoteHeroGuitar.m
//  Wiimote
//

#import "WiimoteHeroGuitar.h"

@implementation WiimoteHeroGuitar

+ (void)load
{
    [WiimoteExtension registerExtensionClass:self];
}

+ (NSData *)extensionSignature
{
    static const uint8_t signature[] = { 0x00, 0x00, 0xA4, 0x20, 0x01, 0x03 };

    static NSData *result = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        result = [NSData dataWithBytes:signature length:sizeof(signature)];
    });

    return result;
}

+ (WiimoteExtensionMeritClass)meritClass
{
    return WiimoteExtensionMeritClassSystem;
}

+ (NSUInteger)minReportDataSize
{
    return sizeof(WiimoteDeviceHeroGuitarReport);
}

- (id)initWithOwner:(Wiimote *)owner
    eventDispatcher:(WiimoteEventDispatcher *)dispatcher
{
    self = [super initWithOwner:owner eventDispatcher:dispatcher];
    if (self == nil)
        return nil;
    
    return self;
}

- (NSString *)name
{
    return WiimoteHeroGuitarName;
}

- (NSPoint)stickPosition
{
    return _stickPosition;
}

- (CGFloat)analogShiftPosition
{
    return _analogShiftPosition;
}

- (BOOL)isButtonPressed:(WiimoteHeroGuitarButtonType)button
{
    return _buttonState[button];
}

- (NSPoint)normalizeStickPosition:(NSPoint)position
{
    return position;
}

- (void)setStickPosition:(NSPoint)newPosition
{
    newPosition = [self normalizeStickPosition:newPosition];
    
    if (WiimoteDeviceIsPointEqual(_stickPosition, newPosition))
        return;
    
    _stickPosition = newPosition;
    
    [[self eventDispatcher] postHeroGuitar:self stickPositionChanged:newPosition];
}

- (void)setButton:(WiimoteHeroGuitarButtonType)button pressed:(BOOL)pressed
{
    if (_buttonState[button] == pressed)
        return;
    
    _buttonState[button] = pressed;
    
    if (pressed)
        [[self eventDispatcher] postHeroGuitar:self buttonPressed:button];
    else
        [[self eventDispatcher] postHeroGuitar:self buttonReleased:button];
}

- (void)setAnalogShiftPosition:(CGFloat)newPosition
{
    if (WiimoteDeviceIsFloatEqual(_analogShiftPosition, newPosition))
        return;
    
    _analogShiftPosition = newPosition;
    
    [[self eventDispatcher] postHeroGuitar:self analogShiftPositionChanged:newPosition];
}

- (void)handleButtonState:(uint16_t)state
{
    static const struct
    {
        WiimoteHeroGuitarButtonType type;
        WiimoteDeviceHeroGuitarReportButtonMask mask;
    } buttonMasks[] = {
        { WiimoteHeroGuitarButtonTypeGreen, WiimoteDeviceHeroGuitarReportButtonMaskGreen },
        { WiimoteHeroGuitarButtonTypeRed, WiimoteDeviceHeroGuitarReportButtonMaskRed },
        { WiimoteHeroGuitarButtonTypeYellow, WiimoteDeviceHeroGuitarReportButtonMaskYellow },
        { WiimoteHeroGuitarButtonTypeBlue, WiimoteDeviceHeroGuitarReportButtonMaskBlue },
        { WiimoteHeroGuitarButtonTypeOrange, WiimoteDeviceHeroGuitarReportButtonMaskOrange },
        { WiimoteHeroGuitarButtonTypeUp, WiimoteDeviceHeroGuitarReportButtonMaskUp },
        { WiimoteHeroGuitarButtonTypeDown, WiimoteDeviceHeroGuitarReportButtonMaskDown },
        { WiimoteHeroGuitarButtonTypePlus, WiimoteDeviceHeroGuitarReportButtonMaskPlus },
    };
    
    for (NSUInteger i = 0; i < sizeof buttonMasks / sizeof(buttonMasks[0]); i++)
        [self setButton:buttonMasks[i].type pressed:((state & buttonMasks[i].mask) == 0)];
}

- (void)handleReport:(const uint8_t *)extensionData length:(NSUInteger)length
{
    if (length < sizeof(WiimoteDeviceHeroGuitarReport))
        return;
    
    const WiimoteDeviceHeroGuitarReport *report = (const WiimoteDeviceHeroGuitarReport *)extensionData;
    
    [self setStickPosition:(NSPoint){(report->stickX.pos + 1.0f) * 0.5f, (report->stickY.pos + 1.0f) * 0.5f}];
    [self setAnalogShiftPosition:(report->whammyBar.value + 1.0f) * 0.5f];
    [self handleButtonState:CFSwapInt16BigToHost(report->buttonState)];
}

@end
