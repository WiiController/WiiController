//
//  NSSegmentedControl+Items.m
//  XibLocalization
//
//  Created by alxn1 on 05.12.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "NSSegmentedControl+Items.h"

@implementation NSSegmentedControlItem : NSObject
{
    @private
        NSSegmentedControl  *_owner;
        NSUInteger           _index;
}

- (id)initWithIndex:(NSUInteger)index owner:(NSSegmentedControl*)owner
{
    self = [super init];

    if(self == nil)
        return nil;

    _index = index;
    _owner = owner;

    return self;
}

- (NSString*)title
{
    return [_owner labelForSegment:_index];
}

- (void)setTitle:(NSString*)title
{
    [_owner setLabel:title forSegment:_index];
}

- (NSMenu*)menu
{
    return [_owner menuForSegment:_index];
}

@end

@implementation NSSegmentedControl (Items)

- (NSArray*)items
{
    NSUInteger               countItems  = [self segmentCount];
    NSMutableArray          *result      = [NSMutableArray arrayWithCapacity:countItems];
    NSSegmentedControlItem  *item        = nil;

    for(NSUInteger i = 0; i < countItems; i++)
    {
        item = [[NSSegmentedControlItem alloc] initWithIndex:i owner:self];
        [result addObject:item];
        [item release];
    }

    return result;
}

@end
