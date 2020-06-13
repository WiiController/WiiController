//
//  WiimoteExtensionPart.h
//  Wiimote
//
//  Created by alxn1 on 30.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimotePart.h"

@class WiimoteExtension;
@class WiimoteExtensionHelper;
@class WiimoteMotionPlusDetector;

@interface WiimoteExtensionPart : WiimotePart
{
    @private
        BOOL                         _isExtensionConnected;
        WiimoteExtensionHelper      *_probeHelper;
        WiimoteMotionPlusDetector   *_motionPlusDetector;
        WiimoteExtension            *_extension;
}

+ (void)registerExtensionClass:(Class)cls;

- (WiimoteExtension*)connectedExtension;

- (void)detectMotionPlus;
- (void)reconnectExtension;
- (void)disconnectExtension;

@end
