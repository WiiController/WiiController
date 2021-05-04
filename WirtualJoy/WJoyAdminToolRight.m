//
//  WJoyAdminToolRight.m
//  driver
//
//  Created by alxn1 on 18.05.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WJoyAdminToolRight.h"

@implementation WJoyAdminToolRight

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;

    _authRef = NULL;

    return self;
}

- (void)dealloc
{
    [self discard];
}

- (BOOL)isObtained
{
    return (_authRef != NULL);
}

- (BOOL)obtain
{
    if ([self isObtained])
        return YES;

    AuthorizationItem right = { "com.alxn1.wjoy.adminRights", 0, NULL, 0 };
    AuthorizationRights rightSet = { 1, &right };

    if (AuthorizationCreate(
            NULL,
            kAuthorizationEmptyEnvironment,
            kAuthorizationFlagDefaults,
            &_authRef)
        != noErr)
    {
        _authRef = NULL;
        return NO;
    }

    AuthorizationFlags flags = kAuthorizationFlagDefaults | kAuthorizationFlagExtendRights | kAuthorizationFlagInteractionAllowed | kAuthorizationFlagPreAuthorize;

    if (AuthorizationCopyRights(
            _authRef,
            &rightSet,
            kAuthorizationEmptyEnvironment,
            flags,
            NULL)
        != noErr)
    {
        [self discard];
        return NO;
    }

    return YES;
}

- (void)discard
{
    if (![self isObtained])
        return;

    AuthorizationFree(_authRef, kAuthorizationFlagDestroyRights);
    _authRef = NULL;
}

- (AuthorizationRef)authRef
{
    return _authRef;
}

@end
