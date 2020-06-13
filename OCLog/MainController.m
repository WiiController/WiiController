//
//  MainController.m
//  OCLog
//
//  Created by alxn1 on 20.02.14.
//  Copyright 2014 Dr. Web. All rights reserved.
//

#import "MainController.h"

@implementation MainController
{
    IBOutlet NSTextView     *_log;
    IBOutlet NSPopUpButton  *_userLogLevel;
    IBOutlet NSTextField    *_userInput;
}

- (void)awakeFromNib
{
    [[OCLog sharedLog] setLevel:OCLogLevelDebug];
    [[OCLog sharedLog] setHandler:self];
}

- (IBAction)clearLog:(id)sender
{
    [_log setString:@""];
}

- (IBAction)log:(id)sender
{
    OCL_MESSAGE([_userLogLevel selectedTag], @"%@", [_userInput stringValue]);
}

- (void)  log:(OCLog*)log
        level:(OCLogLevel)level
   sourceFile:(const char*)sourceFile
         line:(NSUInteger)line
 functionName:(const char*)functionName
      message:(NSString*)message
{
    NSString *msg = [NSString stringWithFormat:
                                        @"%@: %s (%llu), %s: %@\n",
                                        [OCLog levelAsString:level],
                                        sourceFile,
                                        (unsigned long long)line,
                                        functionName,
                                        message];

    [[_log textStorage] appendAttributedString:
        [[[NSAttributedString alloc] initWithString:msg] autorelease]];
}

@end
