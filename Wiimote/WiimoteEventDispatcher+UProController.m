//
//  WiimoteEventDispatcher+UProController.m
//  Wiimote
//
//  Created by alxn1 on 16.06.13.
//

#import "WiimoteEventDispatcher+UProController.h"

@implementation WiimoteEventDispatcher (UProController)

- (void)postUProController:(WiimoteUProControllerExtension *)uPro
             buttonPressed:(WiimoteUProControllerButtonType)button
{
    [self.delegate wiimote:self.owner
            uProController:uPro
             buttonPressed:button];

    if ([self isStateNotificationsEnabled])
    {
        [self postNotification:WiimoteUProControllerButtonPressedNotification
                         param:@(button)
                           key:WiimoteUProControllerButtonKey
                        sender:uPro];
    }
}

- (void)postUProController:(WiimoteUProControllerExtension *)uPro
            buttonReleased:(WiimoteUProControllerButtonType)button
{
    [self.delegate wiimote:self.owner
            uProController:uPro
            buttonReleased:button];

    if ([self isStateNotificationsEnabled])
    {
        [self postNotification:WiimoteUProControllerButtonReleasedNotification
                         param:@(button)
                           key:WiimoteUProControllerButtonKey
                        sender:uPro];
    }
}

- (void)postUProController:(WiimoteUProControllerExtension *)uPro
                     stick:(WiimoteUProControllerStickType)stick
           positionChanged:(NSPoint)position
{
    [self.delegate wiimote:self.owner
            uProController:uPro
                     stick:stick
           positionChanged:position];

    if ([self isStateNotificationsEnabled])
    {
        NSDictionary *userInfo = @{
            WiimoteUProControllerStickPositionKey : @(position),
            WiimoteUProControllerStickKey : @(stick)
        };

        [self postNotification:WiimoteUProControllerStickPositionChangedNotification
                        params:userInfo
                        sender:uPro];
    }
}

@end
