//
//  WiimoteUDraw.h
//  Wiimote
//

#import "WiimoteGenericExtension.h"
#import "WiimoteEventDispatcher+HeroGuitar.h"

@interface WiimoteHeroGuitar : WiimoteGenericExtension <WiimoteHeroGuitarProtocol>
{
@private
    BOOL _buttonState[WiimoteHeroGuitarButtonCount];
    NSPoint _stickPosition;
    CGFloat _analogShiftPosition;
}

@end
