//
//  NotificationWindow.m
//  UserNotification
//
//  Created by alxn1 on 19.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "NotificationWindow.h"

#import <objc/message.h>

@interface NSWindow (Additions)

- (void)setMovable:(BOOL)flag;

@end

@interface NotificationWindow (PrivatePart)

- (void)startAutocloseTimer:(NSTimeInterval)timeout;

@end

@implementation NotificationWindow

+ (NSRect)bestRectForNotification:(UserNotification*)notification
{
    return [NotificationWindowView
                        bestViewRectForTitle:[notification title]
                                        text:[notification text]];
}

+ (NotificationWindow*)newWindowWithNotification:(UserNotification*)notification frame:(NSRect)frame
{
    return [[NotificationWindow alloc]
                        initWithNotification:notification
                                       frame:frame];
}

- (id)initWithNotification:(UserNotification*)notification frame:(NSRect)frame
{
    self = [super initWithContentRect:frame
                            styleMask:NSWindowStyleMaskBorderless
                              backing:NSBackingStoreBuffered
                                defer:NO];

    if(self == nil) return nil;

    if([self respondsToSelector:@selector(setMovable:)])
        [self setMovable:NO];

    [self setOpaque:NO];
    [self setOneShot:NO];
    [self setHasShadow:YES];
    [self setLevel:kCGMaximumWindowLevel];
    [self setAcceptsMouseMovedEvents:YES];
    [self setMovableByWindowBackground:NO];
    [self setBackgroundColor:[NSColor clearColor]];
    [self setReleasedWhenClosed:NO];
    [self setExcludedFromWindowsMenu:YES];
    [self setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];

    [self setAnimationEnabled:YES];

    NSRect contentViewFrame = frame;
    contentViewFrame.origin = NSZeroPoint;

    NotificationWindowView *contentView = [[NotificationWindowView alloc] initWithFrame:contentViewFrame];

    [contentView setIcon:[[NSApplication sharedApplication] applicationIconImage]];
    [contentView setText:[notification text]];
    [contentView setTitle:[notification title]];
    [contentView setDelegate:self];
    [contentView setTarget:self];
    [contentView setAction:@selector(contentViewClicked:)];

    [self setContentView:contentView];

    _notification          = notification;
    _isMouseEntered        = NO;
    _isCloseOnMouseExited  = NO;

    return self;
}

- (void)dealloc
{
    [_autocloseTimer invalidate];
}

- (id)target
{
    return _target;
}

- (void)setTarget:(id)obj
{
    _target = obj;
}

- (SEL)action
{
    return _action;
}

- (void)setAction:(SEL)sel
{
    _action = sel;
}

- (void)showWithTimeout:(NSTimeInterval)timeout
{
    [self orderFront:self];
    [self startAutocloseTimer:timeout];
}

- (void)close
{
    [_autocloseTimer invalidate];
    _autocloseTimer = nil;
    [super close];
}

- (UserNotification*)notification
{
    return _notification;
}

- (BOOL)canBecomeKeyWindow
{
    return NO;
}

- (BOOL)canBecomeMainWindow
{
    return NO;
}

- (void)autoclose:(id)sender
{
    _autocloseTimer = nil;
    if(!_isMouseEntered)
        [self close];
    else
        _isCloseOnMouseExited = YES;
}

- (void)contentViewClicked:(id)sender
{
    if(_target != nil && _action != nil)
    {
        ((void(*)(id self, SEL _cmd, NotificationWindow *sender))objc_msgSend)
            (_target, _action, self);
        
    }
}

- (void)notificationWindowViewMouseEntered:(NotificationWindowView*)view
{
    _isMouseEntered = YES;
}

- (void)notificationWindowViewMouseExited:(NotificationWindowView*)view
{
    _isMouseEntered = NO;
    if(_isCloseOnMouseExited)
        [self close];
}

@end

@implementation NotificationWindow (PrivatePart)

- (void)startAutocloseTimer:(NSTimeInterval)timeout
{
    if(_autocloseTimer == nil)
    {
        _autocloseTimer = [NSTimer scheduledTimerWithTimeInterval:timeout
                                                            target:self
                                                          selector:@selector(autoclose:)
                                                          userInfo:nil
                                                           repeats:NO];

        [[NSRunLoop currentRunLoop] addTimer:_autocloseTimer forMode:NSEventTrackingRunLoopMode];
        [[NSRunLoop currentRunLoop] addTimer:_autocloseTimer forMode:NSModalPanelRunLoopMode];
    }
}

@end
