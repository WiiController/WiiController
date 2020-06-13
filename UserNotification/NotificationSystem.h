//
//  NotificationSystem.h
//  UserNotification
//
//  Created by alxn1 on 19.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "UserNotificationCenter.h"

@class NotificationSystem;
@class NotificationLayoutManager;

@protocol NotificationSystemDelegate

- (void)notificationSystem:(NotificationSystem*)system
       notificationClicked:(UserNotification*)notification;

@end

@interface NotificationSystem : NSObject
{
    @private
        NotificationLayoutManager       *_layoutManager;
        NSMutableArray                  *_notificationQueue;
        NSMutableArray                  *_activeNotifications;

        NSTimeInterval                   _notificationTimeout;

        id<NotificationSystemDelegate>   _delegate;
}

+ (NotificationSystem*)sharedInstance;

- (NSTimeInterval)notificationTimeout;
- (void)setNotificationTimeout:(NSTimeInterval)timeout;

- (UserNotificationCenterScreenCorner)screenCorner;
- (void)setScreenCorner:(UserNotificationCenterScreenCorner)corner;

- (void)deliver:(UserNotification*)notification;

- (id<NotificationSystemDelegate>)delegate;
- (void)setDelegate:(id<NotificationSystemDelegate>)obj;

@end
