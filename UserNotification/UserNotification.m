//
//  UserNotification.m
//  UserNotification
//
//  Created by alxn1 on 18.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "UserNotification.h"

@interface UserNotification (PrivatePart)

- (void)checkFields;

@end

@implementation UserNotification

+ (UserNotification*)userNotificationWithTitle:(NSString*)title text:(NSString*)text
{
    return [[UserNotification alloc] initWithTitle:title text:text userInfo:nil];
}

+ (UserNotification*)userNotificationWithTitle:(NSString*)title text:(NSString*)text userInfo:(NSDictionary*)userInfo
{
    return [[UserNotification alloc] initWithTitle:title text:text userInfo:userInfo];
}

- (id)initWithTitle:(NSString*)title text:(NSString*)text userInfo:(NSDictionary*)userInfo
{
    self = [super init];
    if(self == nil)
        return nil;

    m_Title     = [title copy];
    m_Text      = [text copy];
    m_UserInfo  = [userInfo copy];

    [self checkFields];

    return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if(self == nil)
        return nil;

    m_Title     = [dictionary objectForKey:@"title"];
    m_Text      = [dictionary objectForKey:@"text"];
    m_UserInfo  = [dictionary objectForKey:@"userInfo"];

    [self checkFields];

    return self;
}

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
    if(self == nil)
        return nil;

    if([decoder allowsKeyedCoding])
    {
        m_Title     = [decoder decodeObjectForKey:@"title"];
        m_Text      = [decoder decodeObjectForKey:@"text"];
        m_UserInfo  = [decoder decodeObjectForKey:@"userInfo"];
    }
    else
    {
        m_Title     = [decoder decodeObject];
        m_Text      = [decoder decodeObject];
        m_UserInfo  = [decoder decodeObject];
    }

    [self checkFields];

    return self;
}


- (NSString*)title
{
    return m_Title;
}

- (NSString*)text
{
    return m_Text;
}

- (NSDictionary*)userInfo
{
    return m_UserInfo;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    if([coder allowsKeyedCoding])
    {
        [coder encodeObject:m_Title forKey:@"title"];
        [coder encodeObject:m_Text forKey:@"text"];
        [coder encodeObject:m_UserInfo forKey:@"userInfo"];
    }
    else
    {
        [coder encodeObject:m_Title];
        [coder encodeObject:m_Text];
        [coder encodeObject:m_UserInfo];
    }
}

- (NSDictionary*)asDictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
                                                m_Title,    @"title",
                                                m_Text,     @"text",
                                                m_UserInfo, @"userInfo",
                                                nil];
}

- (NSString*)description
{
    return [[self asDictionary] description];
}

@end

@implementation UserNotification (PrivatePart)

- (void)checkFields
{
    if(m_Title == nil)
        m_Title = @"";

    if(m_Text == nil)
        m_Text = @"";

    if(m_UserInfo == nil)
        m_UserInfo = [[NSDictionary alloc] init];
}

@end
