//
//  WiimoteIOManager.h
//  Wiimote
//
//  Created by alxn1 on 31.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <Wiimote/WiimoteProtocol.h>

@class Wiimote;
@class WiimoteDevice;

@interface WiimoteIOManager : NSObject

- (BOOL)postCommand:(WiimoteDeviceCommandType)command
			   data:(const uint8_t*)data
             length:(NSUInteger)length;

- (BOOL)writeMemory:(NSUInteger)address
			   data:(const uint8_t*)data
             length:(NSUInteger)length;

typedef void(^WiimoteIOManagerReadMemoryCallback)(NSData *);

- (BOOL)readMemory:(NSRange)memoryRange
              then:(WiimoteIOManagerReadMemoryCallback)callback;

@property(nonatomic,readonly) Wiimote *owner;

@end
