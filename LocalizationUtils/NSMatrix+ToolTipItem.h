//
//  NSMatrix+ToolTipItem.h
//  XibLocalization
//
//  Created by alxn1 on 05.12.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSMatrixToolTipItem : NSObject
{
    @private
        NSCell      *_cell;
        NSMatrix    *_owner;
}

- (NSString*)toolTip;
- (void)setToolTip:(NSString*)toolTip;

@end

@interface NSMatrix (ToolTipItem)

- (NSArray*)toolTipItems;

@end
