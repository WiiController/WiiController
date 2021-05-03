//
//  WiimoteDeviceReadBuffer.h
//  Wiimote
//
//  Created by alxn1 on 29.07.12.
//  Copyright (c) 2012 alxn1. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WiimoteDevice.h"

@interface WiimoteDeviceReadBuffer : NSObject

- (id)initWithMemoryRange:(NSRange)memoryRange fullCallback:(WiimoteDeviceReadCallback)fullCallback;

@property(nonatomic,readonly) NSRange memoryRange;

- (void)append:(const uint8_t*)data length:(NSUInteger)length;

@property(nonatomic,readonly) BOOL isFull;

- (void)errorOccured;
- (void)disconnected;

@end
