//
//  WiimoteUHeroGuitarDelegate.h
//  Wiimote
//

#import <Foundation/Foundation.h>

#define WiimoteHeroGuitarButtonCount 9

typedef enum : NSInteger
{
    WiimoteHeroGuitarButtonTypeGreen = 0,
    WiimoteHeroGuitarButtonTypeRed = 1,
    WiimoteHeroGuitarButtonTypeYellow = 2,
    WiimoteHeroGuitarButtonTypeBlue = 3,
    WiimoteHeroGuitarButtonTypeOrange = 4,
    WiimoteHeroGuitarButtonTypeUp = 5,
    WiimoteHeroGuitarButtonTypeDown = 6,
    WiimoteHeroGuitarButtonTypePlus = 7,
    WiimoteHeroGuitarButtonTypeMinus = 8,
} WiimoteHeroGuitarButtonType;

FOUNDATION_EXPORT NSString *WiimoteHeroGuitarButtonPressedNotification;
FOUNDATION_EXPORT NSString *WiimoteHeroGuitarButtonReleasedNotification;
FOUNDATION_EXPORT NSString *WiimoteHeroGuitarStickPositionChangedNotification;
FOUNDATION_EXPORT NSString *WiimoteHeroGuitarAnalogShiftPositionChangedNotification;

FOUNDATION_EXPORT NSString *WiimoteHeroGuitarButtonKey;
FOUNDATION_EXPORT NSString *WiimoteHeroGuitarStickPositionKey;
FOUNDATION_EXPORT NSString *WiimoteHeroGuitarAnalogShiftPositionKey;

FOUNDATION_EXPORT NSString *WiimoteHeroGuitarName;

@class Wiimote;
@class WiimoteExtension;
@class WiimoteAccelerometer;

@protocol WiimoteHeroGuitarProtocol <NSObject>

- (NSPoint)stickPosition;
/// Normalized value of the "whammy bar".
- (CGFloat)analogShiftPosition;
- (BOOL)isButtonPressed:(WiimoteHeroGuitarButtonType)button;

@end

typedef WiimoteExtension<WiimoteHeroGuitarProtocol> WiimoteHeroGuitarExtension;

@interface NSObject (WiimoteHeroGuitarDelegate)

- (void)wiimote:(Wiimote *)wiimote heroGuitar:(WiimoteHeroGuitarExtension *)heroGuitar buttonPressed:(WiimoteHeroGuitarButtonType)button;
- (void)wiimote:(Wiimote *)wiimote heroGuitar:(WiimoteHeroGuitarExtension *)heroGuitar buttonReleased:(WiimoteHeroGuitarButtonType)button;
- (void)wiimote:(Wiimote *)wiimote heroGuitar:(WiimoteHeroGuitarExtension *)heroGuitar stickPositionChanged:(NSPoint)position;
- (void)wiimote:(Wiimote *)wiimote heroGuitar:(WiimoteHeroGuitarExtension *)heroGuitar analogShiftPositionChanged:(CGFloat)position;

@end
