//
//  WiimotePart.m
//  Wiimote
//
//  Created by alxn1 on 30.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimotePartSet.h"

@implementation WiimotePart

+ (void)registerPartClass:(Class)cls
{
    [WiimotePartSet registerPartClass:cls];
}

- (id)initWithOwner:(Wiimote*)owner
    eventDispatcher:(WiimoteEventDispatcher*)dispatcher
          ioManager:(WiimoteIOManager*)ioManager
{
    self = [super init];
    if(self == nil)
        return nil;

    _owner             = owner;
    _eventDispatcher   = dispatcher;
    _ioManager         = ioManager;

    return self;
}

- (NSSet*)allowedReportTypeSet
{
    return nil;
}

- (void)connected
{
}

- (void)handleReport:(WiimoteDeviceReport*)report
{
}

- (void)disconnected
{
}

@end
