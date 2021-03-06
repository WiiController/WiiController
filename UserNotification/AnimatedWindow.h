//
//  AnimatedWindow.h
//  UserNotification
//
//  Created by alxn1 on 26.10.11.
//  Copyright 2011 alxn1. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AnimatedWindow : NSWindow
{
    @private
        NSViewAnimation *_currentAnimation;
        BOOL             _isAnimationEnabled;
}

- (BOOL)isAnimationEnabled;
- (void)setAnimationEnabled:(BOOL)enabled;

@end
