//
//  WiimoteIRPoint.h
//  Wiimote
//
//  Created by alxn1 on 07.08.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Wiimote;

@interface WiimoteIRPoint : NSObject

@property(nonatomic,readonly) NSUInteger index;
@property(nonatomic,readonly,getter=isOutOfView) BOOL outOfView;
@property(nonatomic,readonly) NSPoint position;
@property(nonatomic,readonly) Wiimote *owner;

@end
