//
//  WiimoteIRPart.h
//  Wiimote
//
//  Created by alxn1 on 07.08.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimotePart.h"

@class WiimoteIRPoint;

@interface WiimoteIRPart : WiimotePart
{
    @private
        BOOL         _isEnabled;
        BOOL         _isHardwareEnabled;
        NSInteger    _iRReportMode;
        NSInteger    _reportType;
        NSInteger    _reportCounter;

        NSArray     *_points;
}

- (BOOL)isEnabled;
- (void)setEnabled:(BOOL)enabled;

- (WiimoteIRPoint*)point:(NSUInteger)index;

@end
