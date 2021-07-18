//
//  WiimoteHeroGuitarDelegate.m
//  Wiimote
//

#import "WiimoteHeroGuitarDelegate.h"

NSString *WiimoteHeroGuitarButtonPressedNotification = @"WiimoteHeroGuitarButtonPressedNotification";
NSString *WiimoteHeroGuitarButtonReleasedNotification = @"WiimoteHeroGuitarButtonReleasedNotification";
NSString *WiimoteHeroGuitarStickPositionChangedNotification = @"WiimoteHeroGuitarStickPositionChangedNotification";
NSString *WiimoteHeroGuitarAnalogShiftPositionChangedNotification = @"WiimoteHeroGuitarAnalogShiftPositionChangedNotification";

NSString *WiimoteHeroGuitarButtonKey = @"WiimoteHeroGuitarButtonKey";
NSString *WiimoteHeroGuitarAnalogShiftKey = @"WiimoteHeroGuitarAnalogShiftKey";
NSString *WiimoteHeroGuitarStickPositionKey = @"WiimoteHeroGuitarStickPositionKey";
NSString *WiimoteHeroGuitarAnalogShiftPositionKey = @"WiimoteHeroGuitarAnalogShiftPositionKey";

NSString *WiimoteHeroGuitarName = @"Guitar Hero Guitar";

@implementation NSObject (WiimoteHeroGuitarDelegate)

- (void)wiimote:(Wiimote *)wiimote heroGuitar:(WiimoteHeroGuitarExtension *)heroGuitar buttonPressed:(WiimoteHeroGuitarButtonType)button
{
}
- (void)wiimote:(Wiimote *)wiimote heroGuitar:(WiimoteHeroGuitarExtension *)heroGuitar buttonReleased:(WiimoteHeroGuitarButtonType)button
{
}
- (void)wiimote:(Wiimote *)wiimote heroGuitar:(WiimoteHeroGuitarExtension *)heroGuitar stickPositionChanged:(NSPoint)position
{
}
- (void)wiimote:(Wiimote *)wiimote heroGuitar:(WiimoteHeroGuitarExtension *)heroGuitar analogShiftPositionChanged:(CGFloat)position
{
}

@end
