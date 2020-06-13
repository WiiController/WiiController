//
//  UserActivityNotifier.m
//  WJoy
//
//  Created by alxn1 on 26.02.14.
//
//

#import "UserActivityNotifier.h"

#import <IOKit/pwr_mgt/IOPMLib.h>

@implementation UserActivityNotifier {
    IOPMAssertionID _pmAssertionID;
}

+ (UserActivityNotifier*)sharedNotifier
{
    static UserActivityNotifier *result = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        result = [[UserActivityNotifier alloc] init];
    });
    return result;
}

- (id)init
{
    self = [super init];
    if(self == nil)
        return nil;

    m_LastNotifyTime = [[NSDate alloc] init];
    return self;
}


- (void)notify
{
    NSDate *now = [NSDate date];

    if([now timeIntervalSinceDate:m_LastNotifyTime] >= 5.0)
    {
        IOPMAssertionDeclareUserActivity(kIOPMAssertionTypePreventUserIdleDisplaySleep, kIOPMUserActiveLocal, &_pmAssertionID);

        m_LastNotifyTime = now;
    }
}

@end
