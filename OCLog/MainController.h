//
//  MainController.h
//  OCLog
//
//  Created by alxn1 on 20.02.14.
//  Copyright 2014 Dr. Web. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <OCLog/OCLog.h>

@interface MainController : NSObject< OCLogHandler >

- (IBAction)clearLog:(id)sender;
- (IBAction)log:(id)sender;

@end
