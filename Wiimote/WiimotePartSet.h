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
{
    @private
        Wiimote                 *_owner;
        WiimoteDevice           *_device;

        WiimoteIOManager        *_iOManager;
        WiimoteEventDispatcher  *_eventDispatcher;

        NSMutableDictionary     *_partDictionary;
        NSMutableArray          *_partArray;
}

+ (void)registerPartClass:(Class)cls;

- (id)initWithOwner:(Wiimote*)owner device:(WiimoteDevice*)device;

- (Wiimote*)owner;
- (WiimoteDevice*)device;
- (WiimoteEventDispatcher*)eventDispatcher;

- (WiimotePart*)partWithClass:(Class)cls;

- (WiimoteDeviceReportType)bestReportType;

- (void)connected;
- (void)handleReport:(WiimoteDeviceReport*)report;
- (void)disconnected;

@end
