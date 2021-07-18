//
//  WiimoteEventDispatcher+HeroGuitar.h
//  Wiimote
//

#import "WiimoteEventDispatcher.h"
#import "WiimoteHeroGuitarDelegate.h"

@interface WiimoteEventDispatcher (HeroGuitar)

- (void)postHeroGuitar:(WiimoteHeroGuitarExtension*)heroGuitar buttonPressed:(WiimoteHeroGuitarButtonType)button;
- (void)postHeroGuitar:(WiimoteHeroGuitarExtension*)heroGuitar buttonReleased:(WiimoteHeroGuitarButtonType)button;
- (void)postHeroGuitar:(WiimoteHeroGuitarExtension*)heroGuitar stickPositionChanged:(NSPoint) position;
- (void)postHeroGuitar:(WiimoteHeroGuitarExtension*)heroGuitar analogShiftPositionChanged:(CGFloat)position;

@end
