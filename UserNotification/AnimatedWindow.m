//
//  AnimatedWindow.m
//  UserNotification
//
//  Created by alxn1 on 26.10.11.
//  Copyright 2011 alxn1. All rights reserved.
//

#import "AnimatedWindow.h"

@interface AnimatedWindow (PrivarePart)

- (void)fadeIn;
- (void)fadeOut;

@end

@implementation AnimatedWindow

- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(NSWindowStyleMask)aStyle
                  backing:(NSBackingStoreType)bufferingType
                    defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect
                            styleMask:aStyle
                              backing:bufferingType
                                defer:flag];

    if(self == nil)
        return nil;

    _isAnimationEnabled = NO;

    return self;
}

- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(NSWindowStyleMask)aStyle
                  backing:(NSBackingStoreType)bufferingType
                    defer:(BOOL)flag
                   screen:(NSScreen *)screen
{
    self = [super initWithContentRect:contentRect
                            styleMask:aStyle
                              backing:bufferingType
                                defer:flag
                               screen:screen];

    if(self == nil)
        return nil;

    _isAnimationEnabled = NO;

    return self;
}

- (void)dealloc
{
    [_currentAnimation stopAnimation];
}

- (void)makeKeyAndOrderFromWithoutAnimation:(id)sender
{
    [_currentAnimation stopAnimation];
    _currentAnimation = nil;

    [super makeKeyAndOrderFront:sender];
    [self setAlphaValue:1.0f];
}

- (void)makeKeyAndOrderFront:(id)sender
{
    if(![self isVisible] && _isAnimationEnabled)
    {
        [self setAlphaValue:0.0f];
        [super makeKeyAndOrderFront:sender];
        [self fadeIn];
    }
    else
        [super makeKeyAndOrderFront:sender];
}

- (void)orderFront:(id)sender
{
    if(![self isVisible] && _isAnimationEnabled)
    {
        [self setAlphaValue:0.0f];
        [super orderFront:sender];
        [self fadeIn];
    }
    else
        [super orderFront:sender];
}

- (void)orderOut:(id)sender
{
    if([self isVisible] && _isAnimationEnabled)
    {
        [self setAlphaValue:1.0f];
        [super orderOut:sender];
        [self fadeOut];
    }
    else
        [super orderOut:sender];
}

- (void)close
{
    if([self isVisible] && _isAnimationEnabled)
    {
        if(_currentAnimation == nil ||
         ![_currentAnimation isAnimating] ||
          ((id)[_currentAnimation delegate]) != self)
        {
            [self fadeOut];
        }
    }
    else
        [super close];
}

- (BOOL)isAnimationEnabled
{
    return _isAnimationEnabled;
}

- (void)setAnimationEnabled:(BOOL)enabled
{
    if(_isAnimationEnabled == enabled)
        return;

    _isAnimationEnabled = enabled;
    if(_isAnimationEnabled)
    {
        if(![self isVisible])
            [self setAlphaValue:0.0f];
    }
    else
    {
        [_currentAnimation stopAnimation];
        _currentAnimation = nil;

        [self setAlphaValue:1.0f];
    }
}

- (void)animationDidEnd:(NSAnimation*)animation
{
    _currentAnimation = nil;
    [super close];
}

@end

@implementation AnimatedWindow (PrivarePart)

- (void)fadeIn
{
    [_currentAnimation stopAnimation];

    _currentAnimation = [[NSViewAnimation alloc] initWithViewAnimations:
                            @[
                                @{
                                    NSViewAnimationTargetKey: self,
                                    NSViewAnimationEffectKey: NSViewAnimationFadeInEffect,
                                    }]];

    [_currentAnimation setDuration:0.25];
    [_currentAnimation setCurrentProgress:[self alphaValue]];
    [_currentAnimation setAnimationBlockingMode:NSAnimationNonblocking];
    [_currentAnimation startAnimation];
}

- (void)fadeOut
{
    [_currentAnimation stopAnimation];

    _currentAnimation = [[NSViewAnimation alloc] initWithViewAnimations:
                            @[
                                @{
                                    NSViewAnimationTargetKey: self,
                                    NSViewAnimationEffectKey: NSViewAnimationFadeOutEffect,
                                    }]];

    [_currentAnimation setDuration:0.25];
    [_currentAnimation setDelegate:(id)self];
    [_currentAnimation setCurrentProgress:1.0 - [self alphaValue]];
    [_currentAnimation setAnimationBlockingMode:NSAnimationNonblocking];
    [_currentAnimation startAnimation];
}

@end
