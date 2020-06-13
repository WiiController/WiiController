//
//  TestController.h
//  Wiimote
//
//  Created by alxn1 on 09.10.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <OCLog/OCLog.h>

@interface TestController : NSObject< OCLogHandler >
{
    @private
        IBOutlet NSTextView     *_log;
        IBOutlet NSButton       *_discoveryButton;
        IBOutlet NSTextField    *_connectedTextField;
        IBOutlet NSButton       *_debugCheckBox;

        NSUInteger               _connectedWiimotes;
        BOOL                     _isDiscovering;
}

- (IBAction)toggleUseOneButtonClickConnection:(id)sender;
- (IBAction)toggleDebugOutput:(id)sender;
- (IBAction)discovery:(id)sender;
- (IBAction)clearLog:(id)sender;
- (IBAction)detectMotionPlus:(id)sender;
- (IBAction)toggleVibration:(id)sender;

@end
