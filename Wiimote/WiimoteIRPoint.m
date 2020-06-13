//
//  WiimoteIRPoint.m
//  Wiimote
//
//  Created by alxn1 on 07.08.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteIRPoint.h"

@implementation WiimoteIRPoint

- (NSUInteger)index
{
    return _index;
}

- (BOOL)isOutOfView
{
    return _isOutOfView;
}

- (NSPoint)position
{
    return _position;
}

- (Wiimote*)owner
{
    return _owner;
}

@end
