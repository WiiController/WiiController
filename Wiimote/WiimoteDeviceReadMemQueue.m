//
//  WiimoteDeviceReadMemQueue.m
//  Wiimote
//
//  Created by alxn1 on 02.08.12.
//  Copyright (c) 2012 alxn1. All rights reserved.
//

#import "WiimoteDeviceReadMemQueue.h"
#import "WiimoteDeviceReadMemHandler.h"
#import "WiimoteProtocol.h"
#import "WiimoteDevice.h"

#import "WiimoteLog.h"

@interface WiimoteDeviceReadMemQueue (PrivatePart)

- (BOOL)isQueueEmpty;
- (WiimoteDeviceReadMemHandler*)nextHandlerFromQueue;
- (void)addHandlerToQueue:(WiimoteDeviceReadMemHandler*)handler;
- (BOOL)runHandler:(WiimoteDeviceReadMemHandler*)handler;
- (void)runNextHandler;

@end

@implementation WiimoteDeviceReadMemQueue

- (id)initWithDevice:(WiimoteDevice*)device
{
	self = [super init];
	if(self == nil)
		return nil;

	_device				= device;
	_readMemHandlersQueue	= [[NSMutableArray alloc] init];
	_currentMemHandler		= nil;

	return self;
}


- (BOOL)readMemory:(NSRange)memoryRange
			target:(id)target
			action:(SEL)action
{
	if(![_device isConnected])
		return NO;

	if(memoryRange.length == 0)
        return YES;

	WiimoteDeviceReadMemHandler *handler =
			[[WiimoteDeviceReadMemHandler alloc]
									initWithMemoryRange:memoryRange
												 target:target
												 action:action];

	if(_currentMemHandler == nil)
		return [self runHandler:handler];

    [self addHandlerToQueue:handler];
	return YES;
}

- (void)handleReport:(WiimoteDeviceReport*)report
{
	if(_currentMemHandler == nil)
		return;

    if([report type]    != WiimoteDeviceReportTypeReadMemory ||
       [report length]  < sizeof(WiimoteDeviceReadMemoryReport))
    {
        return;
    }

    const WiimoteDeviceReadMemoryReport *memoryReport =
                                            (const WiimoteDeviceReadMemoryReport*)[report data];

    if(((memoryReport->errorAndDataSize &
            WiimoteDeviceReadMemoryReportErrorMask) >>
                WiimoteDeviceReadMemoryReportErrorOffset) !=
                                        WiimoteDeviceReadMemoryReportErrorOk)
    {
        [_currentMemHandler errorOccured];
        [self runNextHandler];
        return;
    }

    NSUInteger dataSize = ((memoryReport->errorAndDataSize &
                                WiimoteDeviceReadMemoryReportDataSizeMask) >>
                                    WiimoteDeviceReadMemoryReportDataSizeOffset) + 1;

    [_currentMemHandler handleData:memoryReport->data length:dataSize];

	if([_currentMemHandler isAllDataReaded])
        [self runNextHandler];
}

- (void)handleDisconnect
{
	if(_currentMemHandler != 0)
    {
        [_currentMemHandler disconnected];
        _currentMemHandler = nil;
    }

    while([_readMemHandlersQueue count] != 0)
    {
        [[_readMemHandlersQueue objectAtIndex:0] disconnected];
        [_readMemHandlersQueue removeObjectAtIndex:0];
    }
}

@end

@implementation WiimoteDeviceReadMemQueue (PrivatePart)

- (BOOL)isQueueEmpty
{
	return ([_readMemHandlersQueue count] == 0);
}

- (WiimoteDeviceReadMemHandler*)nextHandlerFromQueue
{
	if([self isQueueEmpty])
		return nil;

	WiimoteDeviceReadMemHandler *result =
			[_readMemHandlersQueue objectAtIndex:0];

	[_readMemHandlersQueue removeObjectAtIndex:0];
	return result;
}

- (void)addHandlerToQueue:(WiimoteDeviceReadMemHandler*)handler
{
	[_readMemHandlersQueue addObject:handler];
}

- (BOOL)runHandler:(WiimoteDeviceReadMemHandler*)handler
{
	if(handler == nil)
        return NO;

    WiimoteDeviceReadMemoryParams params;
    NSRange                       memoryRange = [handler memoryRange];

    params.address = OSSwapHostToBigConstInt32((uint32_t)memoryRange.location);
    params.length  = OSSwapHostToBigConstInt16((uint16_t)memoryRange.length);

	if([_device postCommand:WiimoteDeviceCommandTypeReadMemory
						data:(const uint8_t*)&params
                      length:sizeof(params)])
    {
        _currentMemHandler = handler;
        return YES;
    }

    W_ERROR(@"[WiimoteDevice postCommand: data: length:] failed");
    [handler errorOccured];
    return NO;
}

- (void)runNextHandler
{
	_currentMemHandler = nil;

	while(![self isQueueEmpty])
	{
		if([self runHandler:[self nextHandlerFromQueue]])
			break;
	}
}

@end
