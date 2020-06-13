//
//  WiimoteDeviceReport.m
//  Wiimote
//
//  Created by alxn1 on 29.07.12.
//  Copyright (c) 2012 alxn1. All rights reserved.
//

#import "WiimoteDeviceReport.h"
#import "WiimoteProtocol.h"
#import "Wiimote.h"

@implementation WiimoteDeviceReport
{
    WiimoteDevice    *_device;
}

+ (WiimoteDeviceReport*)deviceReportWithType:(NSUInteger)type
                                        data:(const uint8_t*)data
                                      length:(NSUInteger)length
                                      device:(WiimoteDevice*)device
{
    WiimoteDeviceReport *result = [[WiimoteDeviceReport alloc] initWithDevice:device];

    if(result == nil)
        return nil;

    result->_type          = type;
    result->_data          = data;
    result->_length    = length;

    return result;
}

- (id)initWithDevice:(WiimoteDevice*)device
{
    self = [super init];
    if(self == nil)
        return nil;

    _device        = device;
    _data          = NULL;
    _length    = 0;
    _type          = 0;

    return self;
}

- (BOOL)updateFromReportData:(const uint8_t*)data length:(NSUInteger)length
{
    if(data == NULL || length < 1)
        return NO;

    _type          = data[0];
    _data          = data   + 1;
    _length    = length - 1;

    return YES;
}

@end

