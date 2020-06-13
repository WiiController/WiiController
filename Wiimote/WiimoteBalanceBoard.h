//
//  WiimoteBalanceBoard.h
//  WiimoteBalanceBoard
//
//  Created by alxn1 on 10.08.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteGenericExtension.h"
#import "WiimoteEventDispatcher+BalanceBoard.h"

@interface WiimoteBalanceBoard : WiimoteGenericExtension<
                                                WiimoteBalanceBoardProtocol>
{
    @private
        BOOL                                _isCalibrationDataReaded;

        double                              _topLeftPress;
        double                              _topRightPress;
        double                              _bottomLeftPress;
        double                              _bottomRightPress;

        WiimoteBalanceBoardCalibrationData  _calibrationData;
}

@end
