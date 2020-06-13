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

    _title     = [title copy];
    _text      = [text copy];
    _userInfo  = [userInfo copy];

    [self checkFields];

    return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if(self == nil)
        return nil;

    _title     = [dictionary objectForKey:@"title"];
    _text      = [dictionary objectForKey:@"text"];
    _userInfo  = [dictionary objectForKey:@"userInfo"];

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
        _title     = [decoder decodeObjectForKey:@"title"];
        _text      = [decoder decodeObjectForKey:@"text"];
        _userInfo  = [decoder decodeObjectForKey:@"userInfo"];
    }
    else
    {
        _title     = [decoder decodeObject];
        _text      = [decoder decodeObject];
        _userInfo  = [decoder decodeObject];
    }

    [self checkFields];

    return self;
}


- (NSString*)title
{
    return _title;
}

- (NSString*)text
{
    return _text;
}

- (NSDictionary*)userInfo
{
    return _userInfo;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    if([coder allowsKeyedCoding])
    {
        [coder encodeObject:_title forKey:@"title"];
        [coder encodeObject:_text forKey:@"text"];
        [coder encodeObject:_userInfo forKey:@"userInfo"];
    }
    else
    {
        [coder encodeObject:_title];
        [coder encodeObject:_text];
        [coder encodeObject:_userInfo];
    }
}

- (NSDictionary*)asDictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
                                                _title,    @"title",
                                                _text,     @"text",
                                                _userInfo, @"userInfo",
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
    if(_title == nil)
        _title = @"";

    if(_text == nil)
        _text = @"";

    if(_userInfo == nil)
        _userInfo = [[NSDictionary alloc] init];
}

@end
