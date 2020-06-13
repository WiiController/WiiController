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
{
	@private
		NSUInteger		 _type;
		WiimoteDevice	*_device;
		Wiimote			*_wiimote;
        const uint8_t   *_data;
        NSUInteger       _dataLength;
}

- (NSUInteger)type; // WiimoteDeviceReportType

- (const uint8_t*)data;
- (NSUInteger)length;

- (Wiimote*)wiimote;

@end
