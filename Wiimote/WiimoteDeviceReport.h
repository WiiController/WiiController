//
//  WiimoteDeviceReport.h
//  Wiimote
//
//  Created by alxn1 on 29.07.12.
//  Copyright (c) 2012 alxn1. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WiimoteDevice;
@class Wiimote;

@interface WiimoteDeviceReport : NSObject

@property(nonatomic,readonly) NSUInteger type; // WiimoteDeviceReportType

@property(nonatomic,readonly) uint8_t const* data;
@property(nonatomic,readonly) NSUInteger length;

@property(nonatomic,readonly) Wiimote *wiimote;

@end
