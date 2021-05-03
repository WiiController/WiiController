//
//  WiimoteDeviceReadMemQueue.m
//  Wiimote
//
//  Created by alxn1 on 02.08.12.
//  Copyright (c) 2012 alxn1. All rights reserved.
//

#import "WiimoteDeviceReadQueue.h"
#import "WiimoteDeviceReadBuffer.h"
#import "WiimoteProtocol.h"
#import "WiimoteDevice.h"

#import "WiimoteLog.h"

@implementation WiimoteDeviceReadQueue
{
    WiimoteDevice *_device;
    NSMutableArray<WiimoteDeviceReadBuffer *> *_readMemHandlersQueue;
    WiimoteDeviceReadBuffer *_currentBuffer;
}

- (id)initWithDevice:(WiimoteDevice *)device
{
    self = [super init];
    if (self == nil)
        return nil;

    _device = device;
    _readMemHandlersQueue = [NSMutableArray array];
    _currentBuffer = nil;

    return self;
}

- (BOOL)readMemory:(NSRange)memoryRange
              then:(WiimoteDeviceReadCallback)callback
{
    if (!_device.transport.isOpen) return NO;

    if (memoryRange.length == 0) return YES;

    WiimoteDeviceReadBuffer *handler =
        [[WiimoteDeviceReadBuffer alloc]
            initWithMemoryRange:memoryRange
                   fullCallback:callback];

    if (!_currentBuffer) return [self runHandler:handler];

    [self addHandlerToQueue:handler];
    return YES;
}

- (void)handleReport:(WiimoteDeviceReport *)report
{
    if (_currentBuffer == nil)
        return;

    if ([report type] != WiimoteDeviceReportTypeReadMemory ||
        [report length] < sizeof(WiimoteDeviceReadMemoryReport))
    {
        return;
    }

    const WiimoteDeviceReadMemoryReport *memoryReport = (const WiimoteDeviceReadMemoryReport *)[report data];

    if (((memoryReport->errorAndDataSize & WiimoteDeviceReadMemoryReportErrorMask) >> WiimoteDeviceReadMemoryReportErrorOffset) != WiimoteDeviceReadMemoryReportErrorOk)
    {
        [_currentBuffer errorOccured];
        [self runNextHandler];
        return;
    }

    NSUInteger dataSize = ((memoryReport->errorAndDataSize & WiimoteDeviceReadMemoryReportDataSizeMask) >> WiimoteDeviceReadMemoryReportDataSizeOffset) + 1;

    [_currentBuffer append:memoryReport->data length:dataSize];

    if ([_currentBuffer isFull])
        [self runNextHandler];
}

- (void)handleDisconnect
{
    if (_currentBuffer)
    {
        [_currentBuffer disconnected];
        _currentBuffer = nil;
    }

    [_readMemHandlersQueue makeObjectsPerformSelector:@selector(disconnected)];
    [_readMemHandlersQueue removeAllObjects];
}

// MARK: Private

- (BOOL)isQueueEmpty
{
    return ([_readMemHandlersQueue count] == 0);
}

- (WiimoteDeviceReadBuffer *)nextHandlerFromQueue
{
    if ([self isQueueEmpty]) return nil;

    WiimoteDeviceReadBuffer *result =
        [_readMemHandlersQueue objectAtIndex:0];

    [_readMemHandlersQueue removeObjectAtIndex:0];
    return result;
}

- (void)addHandlerToQueue:(WiimoteDeviceReadBuffer *)handler
{
    [_readMemHandlersQueue addObject:handler];
}

- (BOOL)runHandler:(WiimoteDeviceReadBuffer *)handler
{
    if (!handler) return NO;

    WiimoteDeviceReadMemoryParams params;
    NSRange memoryRange = [handler memoryRange];

    params.address = OSSwapHostToBigConstInt32((uint32_t)memoryRange.location);
    params.length = OSSwapHostToBigConstInt16((uint16_t)memoryRange.length);

    if ([_device postCommand:WiimoteDeviceCommandTypeReadMemory
                        data:(const uint8_t *)&params
                      length:sizeof(params)])
    {
        _currentBuffer = handler;
        return YES;
    }

    W_ERROR(@"[WiimoteDevice postCommand: data: length:] failed");
    [handler errorOccured];
    return NO;
}

- (void)runNextHandler
{
    _currentBuffer = nil;

    while (![self isQueueEmpty] && ![self runHandler:[self nextHandlerFromQueue]])
    {
    }
}

@end
