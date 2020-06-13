//
//  WiimoteDeviceReadMemQueue.h
//  Wiimote
//
//  Created by alxn1 on 02.08.12.
//  Copyright (c) 2012 alxn1. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WiimoteDevice;
@class WiimoteDeviceReport;
@class WiimoteDeviceReadMemHandler;

@interface WiimoteDeviceReadMemQueue : NSObject
{
	@private
		WiimoteDevice					*_device;
		NSMutableArray					*_readMemHandlersQueue;
        WiimoteDeviceReadMemHandler		*_currentMemHandler;
}

- (id)initWithDevice:(WiimoteDevice*)device;

- (BOOL)readMemory:(NSRange)memoryRange
			target:(id)target
			action:(SEL)action;

- (void)handleReport:(WiimoteDeviceReport*)report;

- (void)handleDisconnect;

@end
