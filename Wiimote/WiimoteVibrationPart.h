//
//  WiimoteVibrationPart.h
//  Wiimote
//
//  Created by alxn1 on 30.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimotePart.h"

@class WiimoteDevice;

@interface WiimoteVibrationPart : WiimotePart

@property(nonatomic,getter=isVibrationEnabled) BOOL vibrationEnabled;

- (void)setDevice:(WiimoteDevice*)device;

@end
