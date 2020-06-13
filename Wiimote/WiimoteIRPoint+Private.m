//
//  WiimoteIRPoint+Private.m
//  Wiimote
//
//  Created by alxn1 on 07.08.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteIRPoint+Private.h"

@implementation WiimoteIRPoint (Private)

+ (WiimoteIRPoint*)pointWithOwner:(Wiimote*)owner index:(NSUInteger)index
{
    return [[WiimoteIRPoint alloc] initWithOwner:owner index:index];
}

- (id)initWithOwner:(Wiimote*)owner index:(NSUInteger)index
{
    self = [super init];
    if(self == nil)
        return nil;

    _owner         = owner;
    _position      = NSZeroPoint;
    _isOutOfView   = YES;
    _index         = index;

    return self;
}

- (void)setPosition:(NSPoint)position
{
    _position = position;
}

- (void)setOutOfView:(BOOL)outOfView
{
    _isOutOfView = outOfView;
}

@end
