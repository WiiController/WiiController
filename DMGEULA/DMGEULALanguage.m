//
//  DMGEULALanguage.m
//  DMGEULA
//
//  Created by alxn1 on 24.04.13.
//  Copyright 2013 alxn1. All rights reserved.
//

#import "DMGEULALanguage.h"

NSString *DMGEULAStringTypeLanguage     = @"Language";
NSString *DMGEULAStringTypeAgree        = @"Agree";
NSString *DMGEULAStringTypeDisagree     = @"Disagree";
NSString *DMGEULAStringTypePrint        = @"Print";
NSString *DMGEULAStringTypeSave         = @"Save";
NSString *DMGEULAStringTypeMessage      = @"Message";
NSString *DMGEULAStringTypeMessageTitle = @"MessageTitle";
NSString *DMGEULAStringTypeSaveError    = @"SaveError";
NSString *DMGEULAStringTypePrintError   = @"PrintError";

@implementation DMGEULALanguage

+ (BOOL)checkLocalizedStrings:(NSDictionary*)strings
{
    NSArray *keys = [NSArray arrayWithObjects:
                        DMGEULAStringTypeLanguage,
                        DMGEULAStringTypeAgree,
                        DMGEULAStringTypeDisagree,
                        DMGEULAStringTypePrint,
                        DMGEULAStringTypeSave,
                        DMGEULAStringTypeMessage,
                        DMGEULAStringTypeMessageTitle,
                        DMGEULAStringTypeSaveError,
                        DMGEULAStringTypePrintError,
                        nil];

    for(NSString *key in keys)
    {
        if([strings objectForKey:key] == nil)
            return NO;
    }

    return YES;
}

- (id)init
{
    [self release];
    return nil;
}

- (id)initWithName:(NSString*)name
              code:(NSUInteger)code
  localizedStrings:(NSDictionary*)localizedStrings
          encoding:(CFStringEncoding)encoding
{
    self = [super init];

    if(self == nil)
        return nil;

    if(name             == nil ||
       localizedStrings == nil ||
      ![DMGEULALanguage checkLocalizedStrings:localizedStrings])
    {
        [self release];
        return nil;
    }

    _name              = [name copy];
    _code              = code;
    _localizedStrings  = [localizedStrings copy];
    _encoding          = encoding;

    return self;
}

+ (DMGEULALanguage*)withName:(NSString*)name
                        code:(NSUInteger)code
            localizedStrings:(NSDictionary*)localizedStrings
                    encoding:(CFStringEncoding)encoding
{
    return [[[self alloc]
                    initWithName:name
                            code:code
                localizedStrings:localizedStrings
                        encoding:encoding] autorelease];
}

- (void)dealloc
{
    [_userData release];
    [_localizedStrings release];
    [_name release];

    [super dealloc];
}

- (NSString*)name
{
    return [[_name retain] autorelease];
}

- (NSUInteger)code
{
    return _code;
}

- (NSDictionary*)localizedStrings
{
    return [[_localizedStrings retain] autorelease];
}

- (CFStringEncoding)encoding
{
    return _encoding;
}

- (NSString*)localizedStringWithType:(NSString*)stringType
{
    return [_localizedStrings objectForKey:stringType];
}

@end

@implementation DMGEULALanguage (UserData)

- (NSDictionary*)userData
{
    return [[_userData retain] autorelease];
}

- (void)setUserData:(NSDictionary*)userData
{
    [_userData autorelease];
    _userData = [userData retain];
}

@end
