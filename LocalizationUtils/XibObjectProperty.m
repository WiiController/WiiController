//
//  XibObjectProperty.m
//  XibLocalization
//
//  Created by alxn1 on 03.12.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "XibObjectProperty.h"

@implementation XibObjectProperty

+ (BOOL)addTo:(NSMutableArray*)propertyArray
        owner:(id)owner
    getMethod:(SEL)getMethod
    setMethod:(SEL)setMethod
{
    if([owner respondsToSelector:getMethod] &&
       [owner respondsToSelector:setMethod])
    {
        XibObjectProperty *property = [[XibObjectProperty alloc]
                                                        initWithOwner:owner
                                                            getMethod:getMethod
                                                            setMethod:setMethod];

        [propertyArray addObject:property];
        [property release];

        return YES;
    }

    return NO;
}

+ (XibObjectProperty*)propertyWithOwner:(id)owner
                              getMethod:(SEL)getMethod
                              setMethod:(SEL)setMethod
{
    return [[[XibObjectProperty alloc]
                                initWithOwner:owner
                                    getMethod:getMethod
                                    setMethod:setMethod] autorelease];
}

- (id)initWithOwner:(id)owner
          getMethod:(SEL)getMethod
          setMethod:(SEL)setMethod
{
    self = [super init];

    if(self == nil)
        return nil;

    _owner     = owner;
    _getMethod = getMethod;
    _setMethod = setMethod;

    return self;
}

- (NSString*)value
{
    return [_owner performSelector:_getMethod];
}

- (void)setValue:(NSString*)value
{
    [_owner performSelector:_setMethod withObject:value];
}

- (id)owner
{
    return _owner;
}

@end
