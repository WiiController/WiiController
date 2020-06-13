//
//  UserNotificationCenterScreenCornerView.h
//  UserNotification
//
//  Created by alxn1 on 20.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <UserNotification/UserNotificationCenter.h>

@interface UserNotificationCenterScreenCornerView : NSView
{
    @private
        NSImage                            *_bGImage;

        UserNotificationCenterScreenCorner  _screenCorner;
        int                                 _underMouseScreenCorner;
        int                                 _draggedMouseScreenCorner;
        int                                 _clickedMouseScreenCorner;
        BOOL                                _isEnabled;

        id                                  _target;
        SEL                                 _action;

        NSTrackingRectTag                   _trackingRectTags[4];
}

+ (NSSize)bestSize;

- (BOOL)isEnabled;
- (void)setEnabled:(BOOL)enabled;

- (UserNotificationCenterScreenCorner)screenCorner;
- (void)setScreenCorner:(UserNotificationCenterScreenCorner)corner;

- (id)target;
- (void)setTarget:(id)obj;

- (SEL)action;
- (void)setAction:(SEL)sel;

@end
