//
//  WiimotePartSet.m
//  Wiimote
//
//  Created by alxn1 on 30.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimotePartSet.h"

#import "WiimoteDeviceReport+Private.h"

@implementation WiimotePartSet
{
    WiimoteIOManager        *_ioManager;

    NSMutableDictionary     *_partDictionary;
    NSMutableArray          *_partArray;
}

+ (NSMutableArray*)registredPartClasses
{
    static NSMutableArray *result = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        result = [[NSMutableArray alloc] init];
    });
    return result;
}

+ (void)registerPartClass:(Class)cls
{
    if(![[WiimotePartSet registredPartClasses] containsObject:cls])
        [[WiimotePartSet registredPartClasses] addObject:cls];
}

- (id)initWithOwner:(Wiimote*)owner device:(WiimoteDevice*)device
{
    self = [super init];
    if(self == nil)
        return nil;

    NSArray     *partClasses        = [WiimotePartSet registredPartClasses];
    NSUInteger   countPartClasses   = [partClasses count];

    _owner             = owner;
    _device            = device;
    _ioManager         = [[WiimoteIOManager alloc] initWithOwner:owner device:device];
    _eventDispatcher   = [[WiimoteEventDispatcher alloc] initWithOwner:owner];
    _partDictionary    = [[NSMutableDictionary alloc] initWithCapacity:countPartClasses];
    _partArray         = [[NSMutableArray alloc] initWithCapacity:countPartClasses];

    for(NSUInteger i = 0; i < countPartClasses; i++)
    {
        Class        partClass  = [partClasses objectAtIndex:i];
        WiimotePart *part       = [[partClass alloc] initWithOwner:owner
                                                   eventDispatcher:_eventDispatcher
                                                         ioManager:_ioManager];

        [_partDictionary setObject:part forKey:(id)partClass];
        [_partArray addObject:part];
    }

    return self;
}

- (WiimotePart*)partWithClass:(Class)cls
{
    return [_partDictionary objectForKey:cls];
}

- (WiimoteDeviceReportType)bestReportType
{
    NSUInteger    countParts  = [_partArray count];
    NSMutableSet *reportTypes = [NSMutableSet setWithObjects:
                                    [NSNumber numberWithInteger:WiimoteDeviceReportTypeButtonState],
                                    [NSNumber numberWithInteger:WiimoteDeviceReportTypeButtonAndAccelerometerState],
                                    [NSNumber numberWithInteger:WiimoteDeviceReportTypeButtonAndExtension8BytesState],
                                    [NSNumber numberWithInteger:WiimoteDeviceReportTypeButtonAndAccelerometerAndIR12BytesState],
                                    [NSNumber numberWithInteger:WiimoteDeviceReportTypeButtonAndExtension19BytesState],
                                    [NSNumber numberWithInteger:WiimoteDeviceReportTypeButtonAndAccelerometerAndExtension16BytesState],
                                    [NSNumber numberWithInteger:WiimoteDeviceReportTypeButtonAndIR10BytesAndExtension9BytesState],
                                    [NSNumber numberWithInteger:WiimoteDeviceReportTypeButtonAndAccelerometerAndIR10BytesAndExtension6Bytes],
                                    nil];

    for(NSUInteger i = 0; i < countParts; i++)
    {
        NSSet *partReports = [[_partArray objectAtIndex:i] allowedReportTypeSet];

        if(partReports == nil)
            continue;

        [reportTypes intersectSet:partReports];
    }

    if([reportTypes count] == 0 ||
       [reportTypes containsObject:[NSNumber numberWithInteger:WiimoteDeviceReportTypeButtonState]])
    {
        return WiimoteDeviceReportTypeButtonState;
    }

    return ((WiimoteDeviceReportType)
                    [[reportTypes anyObject] integerValue]);
}

- (void)connected
{
	NSUInteger countParts = [_partArray count];

    for(NSUInteger i = 0; i < countParts; i++)
        [[_partArray objectAtIndex:i] connected];
}

- (void)handleReport:(WiimoteDeviceReport*)report
{
    NSUInteger countParts = [_partArray count];

	[report setWiimote:[self owner]];
    for(NSUInteger i = 0; i < countParts; i++)
        [[_partArray objectAtIndex:i] handleReport:report];
}

- (void)disconnected
{
    NSUInteger countParts = [_partArray count];

    for(NSUInteger i = 0; i < countParts; i++)
        [[_partArray objectAtIndex:i] disconnected];
}

@end
