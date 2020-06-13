//
//  NSComboBox+Items.m
//  XibLocalization
//
//  Created by alxn1 on 05.12.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "NSComboBox+Items.h"

@implementation NSComboBoxItem

- (id)initWithIndex:(NSUInteger)index owner:(NSComboBox*)owner
{
    self = [super init];

    if(self == nil)
        return nil;

    _owner = owner;
    _index = index;

    return self;
}

- (NSString*)title
{
    return [_owner itemObjectValueAtIndex:_index];
}

- (void)setTitle:(NSString*)title
{
    [_owner removeItemAtIndex:_index];
    [_owner insertItemWithObjectValue:title atIndex:_index];
}

@end

@implementation NSComboBox (Items)

- (NSArray*)items
{
    NSUInteger      countItems  = [self numberOfItems];
    NSMutableArray *result      = [NSMutableArray arrayWithCapacity:countItems];
    NSComboBoxItem *item        = nil;

    for(NSUInteger i = 0; i < countItems; i++)
    {
        item = [[NSComboBoxItem alloc] initWithIndex:i owner:self];
        [result addObject:item];
        [item release];
    }

    return result;
}

@end
