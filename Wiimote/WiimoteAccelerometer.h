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
    BOOL _enabled;
    
    CGFloat _gravityX, _gravityY, _gravityZ;
    CGFloat _pitch, _roll;
    CGFloat _gravitySmoothQuant, _anglesSmoothQuant;
    uint16_t _zeroX, _zeroY, _zeroZ;
    uint16_t _1gX, _1gY, _1gZ;

    id _delegate;
}

@property(nonatomic,getter=isEnabled) BOOL enabled;

@property(nonatomic,readonly) CGFloat gravityX;
@property(nonatomic,readonly) CGFloat gravityY;
@property(nonatomic,readonly) CGFloat gravityZ;

@property(nonatomic,readonly) CGFloat pitch;
@property(nonatomic,readonly) CGFloat roll;

@property(nonatomic) CGFloat gravitySmoothQuant;
@property(nonatomic) CGFloat anglesSmoothQuant;

@end
