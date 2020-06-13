//
//  WiimotePart.h
//  Wiimote
//
//  Created by alxn1 on 30.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <Wiimote/WiimoteDeviceReport.h>
#import <Wiimote/WiimoteEventDispatcher.h>
#import <Wiimote/WiimoteIOManager.h>

@interface WiimotePart : NSObject

+ (void)registerPartClass:(Class)cls;

- (id)initWithOwner:(Wiimote*)owner
    eventDispatcher:(WiimoteEventDispatcher*)dispatcher
          ioManager:(WiimoteIOManager*)ioManager;

@property(nonatomic,readonly) Wiimote *owner;
@property(nonatomic,readonly) WiimoteIOManager *ioManager;
@property(nonatomic,readonly) WiimoteEventDispatcher *eventDispatcher;

@property(nonatomic,readonly) NSSet *allowedReportTypeSet;

- (void)connected;
- (void)handleReport:(WiimoteDeviceReport*)report;
- (void)disconnected;

@end
