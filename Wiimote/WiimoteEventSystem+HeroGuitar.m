//
//  WiimoteEventSystem+HeroGuitar.m
//  Wiimote
//

#import "WiimoteEventSystem+HeroGuitar.h"

@implementation WiimoteEventSystem (HeroGuitar)

+ (void)load
{
    [WiimoteEventSystem
     registerNotification:WiimoteHeroGuitarButtonPressedNotification
     selector:@selector(wiimoteHeroGuitarButtonPressedNotification:)];
    
    [WiimoteEventSystem
     registerNotification:WiimoteHeroGuitarButtonReleasedNotification
     selector:@selector(wiimoteHeroGuitarButtonReleasedNotification:)];
    
    [WiimoteEventSystem
     registerNotification:WiimoteHeroGuitarStickPositionChangedNotification
     selector:@selector(wiimoteHeroGuitarStickPositionChangedNotification:)];
    
    [WiimoteEventSystem
     registerNotification:WiimoteHeroGuitarAnalogShiftPositionChangedNotification
     selector:@selector(wiimoteHeroGuitarAnalogShiftPositionChangedNotification:)];
}

- (NSString *)pathForHeroGuitarButton:(NSDictionary *)userInfo
{
    static NSString *result[] = {
        @"Button.Green",
        @"Button.Red",
        @"Button.Yellow",
        @"Button.Blue",
        @"Button.Orange",
        @"Button.Up",
        @"Button.Down",
        @"Button.Plus",
        @"Button.Minus",
    };
    
    WiimoteHeroGuitarButtonType type = [[userInfo objectForKey:WiimoteUProControllerButtonKey] integerValue];
    
    return result[type];
}

- (void)wiimoteHeroGuitarButtonPressedNotification:(NSNotification *)notification
{
    [self postEventForWiimoteExtension:[notification object]
                                  path:[self pathForHeroGuitarButton:[notification userInfo]]
                                 value:WIIMOTE_EVENT_VALUE_PRESS];
}

- (void)wiimoteHeroGuitarButtonReleasedNotification:(NSNotification *)notification
{
    [self postEventForWiimoteExtension:[notification object]
                                  path:[self pathForHeroGuitarButton:[notification userInfo]]
                                 value:WIIMOTE_EVENT_VALUE_RELEASE];
}

- (void)wiimoteHeroGuitarStickPositionChangedNotification:(NSNotification *)notification
{
    NSPoint position = [[[notification userInfo] objectForKey:WiimoteHeroGuitarStickPositionKey] pointValue];
    
    [self postEventForWiimoteExtension:[notification object]
                                  path:@"Stick.X"
                                 value:position.x];
    [self postEventForWiimoteExtension:[notification object]
                                  path:@"Stick.Y"
                                 value:position.y];
}

- (void)wiimoteHeroGuitarAnalogShiftPositionChangedNotification:(NSNotification *)notification
{
    CGFloat position = [[[notification userInfo] objectForKey:WiimoteHeroGuitarAnalogShiftPositionKey] doubleValue];
    
    [self postEventForWiimoteExtension:[notification object]
                                  path:@"Shift"
                                 value:position];
}

@end
