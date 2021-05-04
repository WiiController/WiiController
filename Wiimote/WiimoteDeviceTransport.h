//
//  WiimoteDeviceTransport.h
//  Wiimote
//
//  Created by alxn1 on 10.07.13.
//  Copyright 2013 alxn1. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WiimoteDeviceTransport;
@class W_HIDDevice;
@class IOBluetoothDevice;

@protocol WiimoteDeviceTransportDelegate <NSObject>

- (void)wiimoteDeviceTransport:(id<WiimoteDeviceTransport>)transport
            reportDataReceived:(const uint8_t *)bytes
                        length:(NSUInteger)length;

- (void)wiimoteDeviceTransportDisconnected:(id<WiimoteDeviceTransport>)transport;

@end

@protocol WiimoteDeviceTransport <NSObject>

@property(nonatomic, copy, readonly) NSString *name;
@property(nonatomic, copy, readonly) NSData *address;
@property(nonatomic, copy, readonly) NSString *addressString;

@property(nonatomic, readonly) id lowLevelDevice;

@property(nonatomic, readonly) BOOL isOpen;

- (BOOL)open;
- (void)close;

- (BOOL)postBytes:(const uint8_t *)bytes length:(NSUInteger)length;

@property(nonatomic, weak) id<WiimoteDeviceTransportDelegate> delegate;

@end

id<WiimoteDeviceTransport> wiimoteDeviceTransportWithHIDDevice(W_HIDDevice *device);
id<WiimoteDeviceTransport> wiimoteDeviceTransportWithBluetoothDevice(IOBluetoothDevice *device);
