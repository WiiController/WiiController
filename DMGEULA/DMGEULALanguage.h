//
//  DMGEULALanguage.h
//  DMGEULA
//
//  Created by alxn1 on 24.04.13.
//  Copyright 2013 alxn1. All rights reserved.
//

#import <Cocoa/Cocoa.h>

FOUNDATION_EXTERN NSString *DMGEULAStringTypeLanguage;      // Language
FOUNDATION_EXTERN NSString *DMGEULAStringTypeAgree;         // Agree
FOUNDATION_EXTERN NSString *DMGEULAStringTypeDisagree;      // Disagree
FOUNDATION_EXTERN NSString *DMGEULAStringTypePrint;         // Print
FOUNDATION_EXTERN NSString *DMGEULAStringTypeSave;          // Save
FOUNDATION_EXTERN NSString *DMGEULAStringTypeMessage;       // Message
FOUNDATION_EXTERN NSString *DMGEULAStringTypeMessageTitle;  // MessageTitle
FOUNDATION_EXTERN NSString *DMGEULAStringTypeSaveError;     // SaveError
FOUNDATION_EXTERN NSString *DMGEULAStringTypePrintError;    // PrintError

@interface DMGEULALanguage : NSObject
{
    @private
        NSUInteger           _code;
        NSString            *_name;
        NSDictionary        *_localizedStrings;
        CFStringEncoding     _encoding;

        NSDictionary        *_userData;
}

+ (DMGEULALanguage*)withName:(NSString*)name
                        code:(NSUInteger)code
            localizedStrings:(NSDictionary*)localizedStrings
                    encoding:(CFStringEncoding)encoding;

- (NSString*)name;
- (NSUInteger)code; // verUS* constant value
- (NSDictionary*)localizedStrings;
- (CFStringEncoding)encoding;

- (NSString*)localizedStringWithType:(NSString*)stringType;

@end

@interface DMGEULALanguage (UserData)

- (NSDictionary*)userData;
- (void)setUserData:(NSDictionary*)userData;

@end
