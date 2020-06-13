//
//  WiimoteAccelerometer.h
//  Wiimote
//
//  Created by alxn1 on 06.08.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WiimoteAccelerometer : NSObject
{
    @private
        BOOL        _isEnabled;

        CGFloat     _gravityX;
        CGFloat     _gravityY;
        CGFloat     _gravityZ;

        CGFloat     _pitch;
        CGFloat     _roll;

        CGFloat     _gravitySmoothQuant;
        CGFloat     _anglesSmoothQuant;

        uint16_t    _zeroX;
        uint16_t    _zeroY;
        uint16_t    _zeroZ;

        uint16_t    m_1gX;
        uint16_t    m_1gY;
        uint16_t    m_1gZ;

        id          _delegate;
}

- (BOOL)isEnabled;
- (void)setEnabled:(BOOL)enabled;

- (CGFloat)gravityX;
- (CGFloat)gravityY;
- (CGFloat)gravityZ;

- (CGFloat)pitch;
- (CGFloat)roll;

- (CGFloat)gravitySmoothQuant;
- (void)setGravitySmoothQuant:(CGFloat)quant;

- (CGFloat)anglesSmoothQuant;
- (void)setAnglesSmoothQuant:(CGFloat)quant;

@end
