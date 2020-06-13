//
//  NotificationSystem.m
//  UserNotification
//
//  Created by alxn1 on 19.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "NotificationSystem.h"
#import "NotificationWindow.h"
#import "NotificationLayoutManager.h"

@interface NotificationSystem (PrivatePart)

- (BOOL)hasSpaceForNotification:(UserNotification*)notification rect:(NSRect*)resultRect index:(NSUInteger*)index;
- (void)showNotification:(UserNotification*)notification rect:(NSRect)rect index:(NSUInteger)index;

@end

@implementation NotificationSystem

+ (NotificationSystem*)sharedInstance
{
    static NotificationSystem *result = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        result = [[NotificationSystem alloc] init];
    });
    return result;
}

- (id)init
{
    self = [super init];
    if(self == nil)
        return nil;

    _layoutManager     = [NotificationLayoutManager managerWithScreenCorner:
                                        UserNotificationCenterScreenCornerRightTop];

    _notificationQueue     = [[NSMutableArray alloc] init];
    _activeNotifications   = [[NSMutableArray alloc] init];
    _notificationTimeout   = 5.0;

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(applicationDidChangeScreenParametersNotification:)
               name:NSApplicationDidChangeScreenParametersNotification
             object:nil];

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (NSTimeInterval)notificationTimeout
{
    return _notificationTimeout;
}

- (void)setNotificationTimeout:(NSTimeInterval)timeout
{
    _notificationTimeout = timeout;
}

- (UserNotificationCenterScreenCorner)screenCorner
{
    return [_layoutManager screenCorner];
}

- (void)setScreenCorner:(UserNotificationCenterScreenCorner)corner
{
    if([self screenCorner] == corner)
        return;

    _layoutManager = [NotificationLayoutManager managerWithScreenCorner:corner];

    NSUInteger countOpenedWindows = [_activeNotifications count];
    for(NSUInteger i = 0; i < countOpenedWindows; i++)
    {
        NotificationWindow *w = [_activeNotifications objectAtIndex:i];
        [w setReleasedWhenClosed:YES];
        [w setDelegate:nil];
        [w close];
    }

    [_activeNotifications removeAllObjects];
}

- (void)deliver:(UserNotification*)notification
{
    NSRect      rect;
    NSUInteger  index;

    if([self hasSpaceForNotification:notification rect:&rect index:&index])
        [self showNotification:notification rect:rect index:index];
    else
        [_notificationQueue addObject:notification];
}

- (id<NotificationSystemDelegate>)delegate
{
    return _delegate;
}

- (void)setDelegate:(id<NotificationSystemDelegate>)obj
{
    _delegate = obj;
}

- (void)notificationClicked:(id)sender
{
    [_delegate notificationSystem:self
               notificationClicked:[(NotificationWindow*)sender notification]];
}

- (void)showNextNotificationFromQueue
{
    if([_notificationQueue count] != 0)
    {
        NSRect               rect;
        NSUInteger           index;
        UserNotification    *n = [_notificationQueue objectAtIndex:0];

        if([self hasSpaceForNotification:n rect:&rect index:&index])
        {
            [self showNotification:n rect:rect index:index];
            [_notificationQueue removeObjectAtIndex:0];
        }
    }
}

- (void)windowWillClose:(NSNotification*)notification
{
    [_activeNotifications removeObject:[notification object]];
    [self showNextNotificationFromQueue];
}

- (void)applicationDidChangeScreenParametersNotification:(NSNotification*)notification
{
    NSUInteger countOpenedWindows = [_activeNotifications count];
    for(NSUInteger i = 0; i < countOpenedWindows; i++)
    {
        NotificationWindow *w = [_activeNotifications objectAtIndex:i];
        [w setAnimationEnabled:NO];
        [w setDelegate:nil];
        [w close];
    }

    [_activeNotifications removeAllObjects];
    [self showNextNotificationFromQueue];
}

@end

@implementation NotificationSystem (PrivatePart)

- (BOOL)hasSpaceForNotification:(UserNotification*)notification rect:(NSRect*)resultRect index:(NSUInteger*)index
{
    return [_layoutManager hasSpaceForNotification:notification
                                activeNotifications:_activeNotifications
                                               rect:resultRect
                                              index:index];
}

- (void)showNotification:(UserNotification*)notification rect:(NSRect)rect index:(NSUInteger)index
{
    NotificationWindow *window = [NotificationWindow newWindowWithNotification:notification frame:rect];

    [window setTarget:self];
    [window setAction:@selector(notificationClicked:)];
    [window setDelegate:(id)self];
    [window showWithTimeout:_notificationTimeout];

    [_activeNotifications insertObject:window atIndex:index];
}

@end
