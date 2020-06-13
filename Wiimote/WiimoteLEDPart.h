//
//  WiimoteLEDPart.h
//  Wiimote
//
//  Created by alxn1 on 30.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimotePart.h"

@class WiimoteDevice;

@interface WiimoteLEDPart : WiimotePart

@property(nonatomic) NSUInteger highlightedLEDMask;

- (void)setDevice:(WiimoteDevice*)device;

@end
