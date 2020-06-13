//
//  LocalizationHook.m
//  XibLocalization
//
//  Created by alxn1 on 05.12.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "LocalizationHook.h"

#import "NSObject+ObjCRuntime.h"

@interface LocalizationHook (PrivatePart)

+ (NSMutableArray*)registredHooks;
+ (void)registerHook:(LocalizationHook*)hook;
+ (void)unregisterHook:(LocalizationHook*)hook;

+ (NSString*)stringWillLocalize:(NSString*)string table:(NSString*)tableName;
+ (NSString*)stringDidLocalize:(NSString*)string table:(NSString*)tableName;

+ (NSString*)interceptedLocalizedStringForKey:(NSString*)key
                                        value:(NSString*)value
                                        table:(NSString*)tableName;

- (NSString*)stringWillLocalize:(NSString*)string table:(NSString*)tableName;
- (NSString*)stringDidLocalize:(NSString*)string table:(NSString*)tableName;

@end

@implementation LocalizationHook

- (id)init
{
    self = [super init];

    if(self == nil)
        return nil;

    _delegate  = nil;
    _isEnabled = NO;

    return self;
}

- (void)dealloc
{
    [self setEnabled:NO];
    [super dealloc];
}

- (BOOL)isEnabled
{
    return _isEnabled;
}

- (void)setEnabled:(BOOL)enabled
{
    if(_isEnabled == enabled)
        return;

    if(enabled)
        [LocalizationHook registerHook:self];
    else
        [LocalizationHook unregisterHook:self];

    _isEnabled = enabled;
}

- (id<LocalizationHookDelegate>)delegate
{
    return _delegate;
}

- (void)setDelegate:(id<LocalizationHookDelegate>)delegate
{
    _delegate = delegate;
}

@end

@implementation LocalizationHook (PrivatePart)

+ (void)load
{
    Class   nsBundleClass   = [NSBundle class];
    SEL     originalSel     = @selector(localizedStringForKey: value: table:);
    SEL     interceptedSel  = @selector(interceptedLocalizedStringForKey: value: table:);

    [nsBundleClass addMethod:[[self class] getClassMethod:interceptedSel] name:interceptedSel];
    [nsBundleClass swizzleMethod:originalSel withMethod:interceptedSel];
}

+ (NSMutableArray*)registredHooks
{
    static NSMutableArray *result = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        result = [[NSMutableArray alloc] init];
    });
    return result;
}

+ (void)registerHook:(LocalizationHook*)hook
{
    [[LocalizationHook registredHooks] addObject:hook];
}

+ (void)unregisterHook:(LocalizationHook*)hook
{
    [[LocalizationHook registredHooks] removeObject:hook];
}

+ (NSString*)stringWillLocalize:(NSString*)string table:(NSString*)tableName
{
    NSArray             *hooks      = [LocalizationHook registredHooks];
    NSUInteger           countHooks = [hooks count];
    LocalizationHook    *hook       = nil;

    for(NSUInteger i = 0; i < countHooks; i++)
    {
        hook    = [hooks objectAtIndex:i];
        string  = [hook stringWillLocalize:string table:tableName];

        if(string == nil)
            break;
    }

    return string;
}

+ (NSString*)stringDidLocalize:(NSString*)string table:(NSString*)tableName
{
    NSArray             *hooks      = [LocalizationHook registredHooks];
    NSUInteger           countHooks = [hooks count];
    LocalizationHook    *hook       = nil;

    for(NSUInteger i = 0; i < countHooks; i++)
    {
        hook    = [hooks objectAtIndex:i];
        string  = [hook stringDidLocalize:string table:tableName];

        if(string == nil)
            break;
    }

    return string;
}

+ (NSString*)interceptedLocalizedStringForKey:(NSString*)key
                                        value:(NSString*)value
                                        table:(NSString*)tableName
{
    if(key == nil)
        return nil;

    NSString *string = [LocalizationHook stringWillLocalize:key table:tableName];

    if(string == nil)
        return [[key mutableCopy] autorelease];

    return [LocalizationHook
            stringDidLocalize:[self interceptedLocalizedStringForKey:string
                                                               value:value
                                                               table:tableName]
                        table:tableName];
}

- (NSString*)stringWillLocalize:(NSString*)string table:(NSString*)tableName
{
    if(_delegate == nil)
        return string;

    return [_delegate localizationHook:self stringWillLocalize:string table:tableName];
}

- (NSString*)stringDidLocalize:(NSString*)string table:(NSString*)tableName
{
    if(_delegate == nil)
        return string;

    return [_delegate localizationHook:self stringDidLocalize:string table:tableName];
}

@end
