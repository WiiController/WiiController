//
//  NSMatrix+ToolTipItem.m
//  XibLocalization
//
//  Created by alxn1 on 05.12.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "NSMatrix+ToolTipItem.h"

@implementation NSMatrixToolTipItem

- (id)initWithCell:(NSCell*)cell owner:(NSMatrix*)owner
{
    self = [super init];

    if(self == nil)
        return nil;

    _cell  = cell;
    _owner = owner;

    return self;
}

- (NSString*)toolTip
{
    return [_owner toolTipForCell:_cell];
}

- (void)setToolTip:(NSString*)toolTip
{
    [_owner setToolTip:toolTip forCell:_cell];
}

@end

@implementation NSMatrix (ToolTipItem)

- (NSArray*)toolTipItems
{
    NSArray             *cells       = [self cells];
    NSUInteger           countCells  = [cells count];
    NSMutableArray      *result      = [NSMutableArray arrayWithCapacity:countCells];
    NSMatrixToolTipItem *item        = nil;

    for(NSUInteger i = 0; i < countCells; i++)
    {
        item = [[NSMatrixToolTipItem alloc] initWithCell:[cells objectAtIndex:i] owner:self];
        [result addObject:item];
        [item release];
    }

    return result;
}

@end
