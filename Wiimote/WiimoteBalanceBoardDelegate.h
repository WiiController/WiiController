//
//  WiimoteBalanceBoardDelegate.h
//  WiimoteBalanceBoard
//
//  Created by alxn1 on 10.08.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *WiimoteBalanceBoardPressChangedNotification;

FOUNDATION_EXPORT NSString *WiimoteBalanceBoardTopLeftPressKey;
FOUNDATION_EXPORT NSString *WiimoteBalanceBoardTopRightPressKey;
FOUNDATION_EXPORT NSString *WiimoteBalanceBoardBottomLeftPressKey;
FOUNDATION_EXPORT NSString *WiimoteBalanceBoardBottomRightPressKey;

FOUNDATION_EXPORT NSString *WiimoteBalanceBoardName;

@class Wiimote;
@class WiimoteExtension;

@protocol WiimoteBalanceBoardProtocol <NSObject>

- (double)topLeftPress;
- (double)topRightPress;
- (double)bottomLeftPress;
- (double)bottomRightPress;

@end

typedef WiimoteExtension<WiimoteBalanceBoardProtocol> WiimoteBalanceBoardExtension;

@interface NSObject (WiimoteBalanceBoardDelegate)

- (void)wiimote:(Wiimote *)wiimote
        balanceBoard:(WiimoteBalanceBoardExtension *)balanceBoard
        topLeftPress:(double)topLeft
       topRightPress:(double)topRight
     bottomLeftPress:(double)bottomLeft
    bottomRightPress:(double)bottomRight;

@end
