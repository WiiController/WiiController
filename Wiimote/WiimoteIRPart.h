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

@property(nonatomic,getter=isEnabled) BOOL enabled;

- (WiimoteIRPoint*)point:(NSUInteger)index;

@end
