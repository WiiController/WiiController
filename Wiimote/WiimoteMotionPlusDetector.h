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
{
    @private
        WiimoteIOManager *_iOManager;

        id                _target;
        SEL               _action;

        BOOL              _isRun;
        NSUInteger        _cancelCount;
        NSUInteger        _readTryCount;

        NSTimer          *_lastTryTimer;
}

+ (void)activateMotionPlus:(WiimoteIOManager*)ioManager
              subExtension:(WiimoteExtension*)subExtension;

- (id)initWithIOManager:(WiimoteIOManager*)ioManager
                 target:(id)target
                 action:(SEL)action;

- (void)dealloc;

- (BOOL)isRun;

- (void)run;
- (void)cancel;

@end
