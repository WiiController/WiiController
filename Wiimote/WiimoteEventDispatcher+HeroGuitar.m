//
//  WiimoteEventDispatcher+HeroGuitar.m
//  Wiimote
//

#import "WiimoteEventDispatcher+HeroGuitar.h"

@implementation WiimoteEventDispatcher (HeroGuitar)

- (void)postHeroGuitar:(WiimoteHeroGuitarExtension*)heroGuitar buttonPressed:(WiimoteHeroGuitarButtonType)button
{
    [self.delegate wiimote:self.owner heroGuitar:heroGuitar buttonPressed:button];
    
    if ([self isStateNotificationsEnabled])
    {
        [self postNotification:WiimoteHeroGuitarButtonPressedNotification
                         param:@(button)
                           key:WiimoteHeroGuitarButtonKey
                        sender:heroGuitar];
    }
}


- (void)postHeroGuitar:(WiimoteHeroGuitarExtension*)heroGuitar buttonReleased:(WiimoteHeroGuitarButtonType)button
{
    [self.delegate wiimote:self.owner heroGuitar:heroGuitar buttonReleased:button];
    
    if ([self isStateNotificationsEnabled])
    {
        [self postNotification:WiimoteHeroGuitarButtonReleasedNotification
                         param:@(button)
                           key:WiimoteHeroGuitarButtonKey
                        sender:heroGuitar];
    }
}

- (void)postHeroGuitar:(WiimoteHeroGuitarExtension*)heroGuitar stickPositionChanged:(NSPoint)position
{
    [self.delegate wiimote:self.owner heroGuitar:heroGuitar stickPositionChanged:position];
    
    if ([self isStateNotificationsEnabled])
    {
        [self postNotification:WiimoteHeroGuitarStickPositionChangedNotification
                         param:@(position)
                           key:WiimoteHeroGuitarStickPositionKey
                        sender:heroGuitar];
    }
}

- (void)postHeroGuitar:(WiimoteHeroGuitarExtension*)heroGuitar analogShiftPositionChanged:(CGFloat)position
{
    [self.delegate wiimote:self.owner heroGuitar:heroGuitar analogShiftPositionChanged:position];
    
    if ([self isStateNotificationsEnabled])
    {
        [self postNotification:WiimoteHeroGuitarAnalogShiftPositionChangedNotification
                        param:@(position)
                          key:WiimoteHeroGuitarAnalogShiftPositionKey
                        sender:heroGuitar];
    }
}

@end
