//
//  WiimoteClassicController.h
//  Wiimote
//
//  Created by alxn1 on 31.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteGenericExtension.h"
#import "WiimoteEventDispatcher+ClassicController.h"

@interface WiimoteClassicController : WiimoteGenericExtension <
                                          WiimoteClassicControllerProtocol>
{
@private
    BOOL _buttonState[WiimoteClassicControllerButtonCount];
    NSPoint _stickPositions[WiimoteClassicControllerStickCount];
    CGFloat _analogShiftPositions[WiimoteClassicControllerAnalogShiftCount];
    BOOL _isCalibrationDataReaded;
    WiimoteDeviceClassicControllerCalibrationData _calibrationData;
}

@end
