//
//  WiimoteNunchuck.h
//  Wiimote
//
//  Created by alxn1 on 31.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteGenericExtension.h"
#import "WiimoteEventDispatcher+Nunchuck.h"

@class WiimoteAccelerometer;

@interface WiimoteNunchuck : WiimoteGenericExtension <WiimoteNunchuckProtocol>

@end
