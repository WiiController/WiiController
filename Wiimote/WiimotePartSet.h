//
//  WiimotePartSet.h
//  Wiimote
//
//  Created by alxn1 on 30.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimotePart.h"
#import "WiimoteDevice.h"
#import "WiimoteIOManager+Private.h"
#import "WiimoteEventDispatcher+Private.h"

@interface WiimotePartSet : NSObject

+ (void)registerPartClass:(Class)cls;

- (id)initWithOwner:(Wiimote *)owner device:(WiimoteDevice *)device;

@property(nonatomic, readonly) Wiimote *owner;
@property(nonatomic, readonly) WiimoteDevice *device;
@property(nonatomic, readonly) WiimoteEventDispatcher *eventDispatcher;

- (WiimotePart *)partWithClass:(Class)cls;

- (WiimoteDeviceReportType)bestReportType;

- (void)connected;
- (void)handleReport:(WiimoteDeviceReport *)report;
- (void)disconnected;

@end
