//
//  OCLog.m
//  OCLog
//
//  Created by alxn1 on 20.02.14.
//  Copyright 2014 alxn1. All rights reserved.
//

#import "OCLog.h"

@implementation OCDefaultLogHandler

+ (OCDefaultLogHandler*)defaultLogHandler
{
    static OCDefaultLogHandler *result = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        result = [[OCDefaultLogHandler alloc] init];
    });
    return result;
}

- (void)  log:(OCLog*)log
        level:(OCLogLevel)level
   sourceFile:(const char*)sourceFile
         line:(NSUInteger)line
 functionName:(const char*)functionName
      message:(NSString*)message
{
    NSLog(@"%@: %s (%llu) [%s]: %@",
        [OCLog levelAsString:level], sourceFile, (unsigned long long)line, functionName, message);
}

@end

@implementation OCLog
{
    OCLogLevel                   m_Level;
    NSObject< OCLogHandler >    *m_Handler;
}

+ (NSString*)levelAsString:(OCLogLevel)level
{
    NSString *result = @"UNKNOWN";

    switch(level)
    {
        case OCLogLevelError:
            result = @"ERROR";
            break;

        case OCLogLevelWarning:
            result = @"WARNING";
            break;

        case OCLogLevelDebug:
            result = @"DEBUG";
            break;
    }

    return result;
}

+ (OCLog*)sharedLog
{
    static OCLog *result = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        result = [[OCLog alloc] init];
    });
    return result;
}

- (id)init
{
    self = [super init];

    if(self == nil)
        return nil;

    m_Handler   = [OCDefaultLogHandler defaultLogHandler];
    m_Level     = OCLogLevelError;

    return self;
}


- (OCLogLevel)level
{
    return m_Level;
}

- (void)setLevel:(OCLogLevel)level
{
    m_Level = level;
}

- (NSObject< OCLogHandler >*)handler
{
    return m_Handler;
}

- (void)setHandler:(NSObject< OCLogHandler >*)handler
{
    m_Handler = handler;
}

- (void)level:(OCLogLevel)level
   sourceFile:(const char*)sourceFile
         line:(NSUInteger)line
 functionName:(const char*)functionName
      message:(NSString*)message
{
    [m_Handler log:self
             level:level
        sourceFile:sourceFile
              line:line
      functionName:functionName
           message:message];
}

- (void)  log:(OCLog*)log
        level:(OCLogLevel)level
   sourceFile:(const char*)sourceFile
         line:(NSUInteger)line
 functionName:(const char*)functionName
      message:(NSString*)message
{
    [m_Handler log:self
             level:level
        sourceFile:sourceFile
              line:line
      functionName:functionName
           message:message];
}

@end
