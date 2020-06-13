//
//  DMGEULAResource.m
//  DMGEULA
//
//  Created by alxn1 on 24.04.13.
//  Copyright 2013 alxn1. All rights reserved.
//

#import "DMGEULAResource.h"

#import "DMGEULAPathPreprocessor.h"

@implementation DMGEULAResource

- (id)init
{
    self = [super init];

    if(self == nil)
        return nil;

    _languages         = [[NSMutableArray alloc] init];
    _licenseFilePaths  = [[NSMutableArray alloc] init];
    _defaultLanguage   = nil;

    return self;
}

- (void)dealloc
{
    [_languages release];
    [_licenseFilePaths release];
    [_defaultLanguage release];

    [super dealloc];
}

- (NSArray*)languages
{
    return [[_languages retain] autorelease];
}

- (NSString*)licenseFilePathForLanguage:(DMGEULALanguage*)language
{
    if(language == nil)
        return nil;

    NSString    *result = nil;
    NSUInteger   index  = [_languages indexOfObject:language];

    if(index != NSNotFound)
        result = [_licenseFilePaths objectAtIndex:index];

    return result;
}

- (BOOL)containsLanguage:(DMGEULALanguage*)language
{
    if(language == nil)
        return NO;

    return [_languages containsObject:language];
}

- (void)addLanguage:(DMGEULALanguage*)language licenseFilePath:(NSString*)licenseFilePath
{
    if(language         != nil &&
       licenseFilePath  != nil &&
      ![self containsLanguage:language])
    {
        [_languages addObject:language];
        [_licenseFilePaths addObject:licenseFilePath];

        if(_defaultLanguage == nil)
            [self setDefaultLanguage:language];
    }
}

- (void)removeLanguage:(DMGEULALanguage*)language
{
    if(language == nil)
        return;

    NSUInteger index = [_languages indexOfObject:language];

    if(index != NSNotFound)
    {
        BOOL needSetNewDefaultLanguage = NO;

        if(_defaultLanguage == [_languages objectAtIndex:index])
            needSetNewDefaultLanguage = YES;

        [_languages removeObjectAtIndex:index];
        [_licenseFilePaths removeObjectAtIndex:index];

        if(needSetNewDefaultLanguage)
        {
            DMGEULALanguage *lang = nil;

            if([_languages count] > 0)
                lang = [_languages objectAtIndex:0];

            [self setDefaultLanguage:lang];
        }
    }
}

- (void)removeAllLanguages
{
    [_languages removeAllObjects];
    [_licenseFilePaths removeAllObjects];
    [_defaultLanguage release];
    _defaultLanguage = nil;
}

- (NSString*)tableOfContents:(NSError**)error
{
    NSMutableString *result             = [NSMutableString string];
    NSArray         *langs              = [self languages];
    NSUInteger       defaultLangCode    = verUS;
    NSUInteger       index              = 0;

    if(_defaultLanguage == nil)
    {
        if([langs count] > 0)
            defaultLangCode = [[langs objectAtIndex:0] code];
    }
    else
        defaultLangCode = [_defaultLanguage code];

    [result appendString:@"data 'LPic' (5000) {\n"];
    [result appendFormat:@"\t$\"%04X\"\n", (unsigned int)defaultLangCode];
    [result appendFormat:@"\t$\"%04X\"\n", (unsigned int)[langs count]];

    for(DMGEULALanguage *lang in langs)
    {
        [result appendFormat:@"\n\t$\"%04X\"\n", (unsigned int)[lang code]];
        [result appendFormat:@"\t$\"%04X\"\n", (unsigned int)index];
        [result appendString:@"\t$\"0000\"\n"];
        index++;
    }

    [result appendString:@"};"];

    return result;
}

- (void)formatData:(NSData*)data toMutableString:(NSMutableString*)result
{
    const char      *bytes      = [data bytes];
    NSUInteger       size       = [data length];

    [result appendString:@"\t$\""];

    for(NSUInteger i = 0; i < size; i++)
    {
        if(i != 0 && (i % 2) == 0)
        {
            if((i % 16) == 0)
                [result appendString:@"\"\n\t$\""];
            else
                [result appendString:@" "];
        }

        [result appendFormat:@"%02X", (*bytes) & 0xFF];
        bytes++;
    }

    [result appendString:@"\"\n"];
}

- (NSString*)dataRepresentation:(NSData*)data
                       language:(DMGEULALanguage*)language
                          index:(NSUInteger)index
                           type:(NSString*)type
                          error:(NSError**)error
{
    NSMutableString *result = [NSMutableString string];

    [result appendFormat:
                @"data '%@' (%04X, \"%@\") {\n",
                    type,
                    (unsigned int)(0x5000 + index),
                    [language name]];

    [self formatData:data toMutableString:result];
    [result appendString:@"};"];

    return result;
}

- (NSData*)encodeString:(NSString*)string
               language:(DMGEULALanguage*)language
{
    CFStringEncoding encoding = [language encoding];

    return [(NSData*)CFStringCreateExternalRepresentation(
                                                kCFAllocatorDefault,
                                                (CFStringRef)string,
                                                encoding,
                                                '?')
                                            autorelease];
}

- (NSString*)languageRepresentation:(DMGEULALanguage*)language
                              index:(NSUInteger)index
                              error:(NSError**)error
{
    NSMutableData   *data           = [NSMutableData data];
    char             length         = 0;
    NSArray         *localizedKeys  = [NSArray arrayWithObjects:
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

    [data appendBytes:&length length:sizeof(length)];
    length = [localizedKeys count];
    [data appendBytes:&length length:sizeof(length)];

    for(NSString *key in localizedKeys)
    {
        NSData *encodedString = [self encodeString:[language localizedStringWithType:key]
                                          language:language];

        length = [encodedString length];
        [data appendBytes:&length length:sizeof(length)];
        [data appendData:encodedString];
    }

    return [self dataRepresentation:data
                           language:language
                              index:index
                               type:@"STR#"
                              error:error];
}

- (NSString*)licenseRepresentationForLanguage:(DMGEULALanguage*)language
                                        index:(NSUInteger)index
                                        error:(NSError**)error
{
    NSString *path  = [[DMGEULAPathPreprocessor sharedInstance]
                            preprocessString:
                                [self licenseFilePathForLanguage:language]];

    NSData   *data  = [NSData dataWithContentsOfFile:path
                                             options:0
                                               error:error];

    if(data == nil)
        return nil;

    if([[[NSAttributedString alloc]
                            initWithRTF:data
                     documentAttributes:nil] autorelease] == nil)
    {
        if(error != NULL)
            *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:EFTYPE userInfo:nil];

        return nil;
    }

    NSMutableString *result         = [NSMutableString string];
    NSString        *representation = nil;

    representation = [self dataRepresentation:data
                                     language:language
                                        index:index
                                         type:@"RTF "
                                        error:error];

    if(representation == nil)
        return nil;

    [result appendFormat:@"%@", representation];

    return result;
}

- (DMGEULALanguage*)defaultLanguage
{
    return [[_defaultLanguage retain] autorelease];
}

- (void)setDefaultLanguage:(DMGEULALanguage*)language
{
    if([_languages containsObject:language])
    {
        [_defaultLanguage autorelease];
        _defaultLanguage = [language retain];
    }
}

- (NSString*)makeExternalForm:(NSError**)error
{
    NSMutableString *result         = [NSMutableString string];
    NSArray         *langs          = [self languages];
    NSString        *representation = nil;
    NSUInteger       index          = 0;

    representation = [self tableOfContents:error];

    if(representation == nil)
        return nil;

    [result appendFormat:@"%@\n\n", representation];

    for(DMGEULALanguage *lang in langs)
    {
        representation = [self languageRepresentation:lang index:index error:error];

        if(representation == nil)
            return nil;

        [result appendFormat:@"%@\n\n", representation];
        index++;
    }

    index = 0;
    for(DMGEULALanguage *lang in langs)
    {
        NSString *representation = [self licenseRepresentationForLanguage:lang index:index error:error];

        if(representation == nil)
            return nil;

        [result appendFormat:@"%@\n\n", representation];
        index++;
    }

    return result;
}

@end
