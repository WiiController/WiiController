//
//  Wiimote+PlugIn.m
//  Wiimote
//
//  Created by alxn1 on 03.08.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "Wiimote+PlugIn.h"
#import "WiimoteInquiry.h"
#import "WiimotePartSet.h"
#import "WiimoteDevice.h"

@implementation Wiimote (PlugIn)

+ (void)registerSupportedModelName:(NSString*)name
{
    [WiimoteInquiry registerSupportedModelName:name];
}

- (void)deviceConfigurationChanged
{
    [_device requestReportType:[_partSet bestReportType]];
}

- (WiimotePart*)partWithClass:(Class)cls
{
    return [_partSet partWithClass:cls];
}

@end
