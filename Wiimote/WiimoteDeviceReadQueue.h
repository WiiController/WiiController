//
//  WiimoteDeviceReadQueue.h
//  Wiimote
//
//  Created by alxn1 on 02.08.12.
//  Copyright (c) 2012 alxn1. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WiimoteDevice.h"

@class WiimoteDeviceReport;

@interface WiimoteDeviceReadQueue : NSObject

- (id)initWithDevice:(WiimoteDevice*)device;

- (BOOL)readMemory:(NSRange)memoryRange
              then:(WiimoteDeviceReadCallback)callback;

- (void)handleReport:(WiimoteDeviceReport*)report;

- (void)handleDisconnect;

@end
