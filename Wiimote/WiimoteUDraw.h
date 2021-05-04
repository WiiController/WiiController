//
//  WiimoteUDraw.h
//  Wiimote
//
//  Created by Michael Kessler on 10/4/14.
//

#import "WiimoteGenericExtension.h"
#import "WiimoteEventDispatcher+UDraw.h"

@interface WiimoteUDraw : WiimoteGenericExtension <
                              WiimoteUDrawProtocol>
{
@private
    BOOL _isPenPressed;
    NSPoint _penPosition;
    CGFloat _penPressure;
    BOOL _isPenButtonPressed;
}

@end