//
//  WiimoteMotionPlusDetector.h
//  WMouse
//
//  Created by alxn1 on 12.09.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <Wiimote/WiimoteIOManager.h>
#import <Wiimote/WiimoteExtension+PlugIn.h>

@interface WiimoteMotionPlusDetector : NSObject

+ (void)activateMotionPlus:(WiimoteIOManager*)ioManager
              subExtension:(WiimoteExtension*)subExtension;

- (instancetype)initWithIOManager:(WiimoteIOManager*)ioManager
                           target:(id)target
                           action:(SEL)action;

- (void)dealloc;

@property(nonatomic,readonly) BOOL isRun;

- (void)run;
- (void)cancel;

@end
