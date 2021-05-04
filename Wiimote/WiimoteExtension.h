//
//  WiimoteExtension.h
//  Wiimote
//
//  Created by alxn1 on 28.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Wiimote;
@class WiimoteEventDispatcher;

@interface WiimoteExtension : NSObject
{
    Wiimote *_owner;
    WiimoteEventDispatcher *_eventDispatcher;
}

@property(nonatomic, readonly) Wiimote *owner;

@property(nonatomic, readonly) NSString *name;

@end
