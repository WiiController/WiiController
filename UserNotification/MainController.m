//
//  MainController.m
//  UserNotification
//
//  Created by alxn1 on 18.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "MainController.h"
#import <UserNotification/UserNotificationCenter.h>
#import <UserNotification/UserNotificationCenterScreenCornerView.h>

typedef enum
{
    NotificationSystemTypeApple     = 1,
    NotificationSystemTypeInternal  = 3,
    NotificationSystemTypeBest      = 4
} NotificationSystemType;

@interface MainController (Private)

- (void)updateSystemsState:(id)sender;
- (void)postNotification:(id)sender;

@end

@implementation MainController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter]
                                addObserver:self
                                   selector:@selector(notificationClicked:)
                                       name:UserNotificationClickedNotification
                                     object:nil];

    [self updateSystemsState:self];

    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [window makeKeyAndOrderFront:self];
}

- (IBAction)showNotification:(id)sender
{
    if([afterDelayCheckBox state] == NSOnState)
    {
        [titleTextField setEnabled:NO];
        [textTextField setEnabled:NO];
        [notificationSystemMatrix setEnabled:NO];
        [afterDelayCheckBox setEnabled:NO];
        [postNotificationButton setEnabled:NO];
        [soundEnabledCheck setEnabled:NO];
        [cornerView setEnabled:NO];
        [durationSlider setEnabled:NO];

        [NSTimer scheduledTimerWithTimeInterval:5.0
                                         target:self
                                       selector:@selector(postNotification:)
                                       userInfo:nil
                                        repeats:NO];
    }
    else
        [self postNotification:self];
}

- (void)notificationClicked:(NSNotification*)notification
{
    NSBeginAlertSheet(@"Clicked!", @"Ok", nil, nil, window, nil, nil, nil, nil, @"%@", [notification object]);
}

@end

@implementation MainController (Private)

- (void)updateSystemsState:(id)sender
{
    if(![notificationSystemMatrix isEnabled])
        return;

    if([UserNotificationCenter withName:@"apple"] == nil)
        [[notificationSystemMatrix cellWithTag:NotificationSystemTypeApple] setEnabled:NO];
}

- (void)postNotification:(id)sender
{
    UserNotificationCenter  *center         = [UserNotificationCenter best];
    UserNotification        *notification   = [UserNotification
                                                    userNotificationWithTitle:[titleTextField stringValue]
                                                                         text:[textTextField stringValue]];

    NotificationSystemType   systemType     = [notificationSystemMatrix selectedTag];

    switch(systemType)
    {
        case NotificationSystemTypeApple:
            center = [UserNotificationCenter withName:@"apple"];
            break;

        case NotificationSystemTypeInternal:
            center = [UserNotificationCenter withName:@"own"];
            break;
    }

    [UserNotificationCenter setSoundEnabled:[soundEnabledCheck state] == NSOnState];
    [center setCustomSettings:
        @{
            UserNotificationCenterTimeoutKey: @(durationSlider.doubleValue),
            UserNotificationCenterScreenCornerKey: @([cornerView screenCorner])
        }];

    [center deliver:notification];

    [titleTextField setEnabled:YES];
    [textTextField setEnabled:YES];
    [notificationSystemMatrix setEnabled:YES];
    [afterDelayCheckBox setEnabled:YES];
    [postNotificationButton setEnabled:YES];
    [soundEnabledCheck setEnabled:YES];
    [cornerView setEnabled:YES];
    [durationSlider setEnabled:YES];

    [self updateSystemsState:self];
}

@end
