//
//  WiimoteDevice.h
//  Wiimote
//
//  Created by alxn1 on 29.07.12.
//  Copyright (c) 2012 alxn1. All rights reserved.
//

#import "WiimoteProtocol.h"
#import "WiimoteDeviceReport.h"
#import "WiimoteDeviceTransport.h"

@class W_HIDDevice;
@class IOBluetoothDevice;

@class WiimoteDevice;
@class WiimoteDeviceReadQueue;

@protocol WiimoteDeviceDelegate <NSObject>

- (void)wiimoteDevice:(WiimoteDevice*)device handleReport:(WiimoteDeviceReport*)report;
- (void)wiimoteDeviceDisconnected:(WiimoteDevice*)device;

@end

@interface WiimoteDevice : NSObject

- (instancetype)initWithHIDDevice:(W_HIDDevice*)device;
- (instancetype)initWithBluetoothDevice:(IOBluetoothDevice*)device;

@property(nonatomic,readonly) id <WiimoteDeviceTransport> transport;

- (BOOL)connect;
- (void)disconnect;

- (BOOL)postCommand:(WiimoteDeviceCommandType)command
               data:(const uint8_t*)data
             length:(NSUInteger)length;

- (BOOL)writeMemory:(NSUInteger)address
               data:(const uint8_t*)data
             length:(NSUInteger)length;

typedef void(^WiimoteDeviceReadCallback)(NSData *);

- (BOOL)readMemory:(NSRange)memoryRange
              then:(WiimoteDeviceReadCallback)callback;

- (BOOL)requestStateReport;
- (BOOL)requestReportType:(WiimoteDeviceReportType)type;

@property(nonatomic,readonly) BOOL isVibrationEnabled;
- (BOOL)setVibrationEnabled:(BOOL)enabled;

// WiimoteDeviceSetLEDStateCommandFlag mask
@property(nonatomic,readonly) uint8_t LEDsState;
- (BOOL)setLEDsState:(uint8_t)state;

@property(nonatomic,weak) id <WiimoteDeviceDelegate> delegate;

@end
