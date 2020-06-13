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
{
    @private
        Wiimote     *_owner;
        NSPoint      _position;
        BOOL         _isOutOfView;
        NSUInteger   _index;
}

- (NSUInteger)index;
- (BOOL)isOutOfView;
- (NSPoint)position;
- (Wiimote*)owner;

@end
