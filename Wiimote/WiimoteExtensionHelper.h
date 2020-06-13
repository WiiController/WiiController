//
//  WiimoteExtensionHelper.h
//  Wiimote
//
//  Created by alxn1 on 31.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteExtension+PlugIn.h"

@interface WiimoteExtensionHelper : NSObject

- (id)initWithWiimote:(Wiimote*)wiimote
      eventDispatcher:(WiimoteEventDispatcher*)dispatcher
            ioManager:(WiimoteIOManager*)ioManager
     extensionClasses:(NSArray*)extensionClasses
         subExtension:(WiimoteExtension*)extension
               target:(id)target
               action:(SEL)action;

@property(nonatomic,readonly) WiimoteExtension *subExtension;

- (void)start;
- (void)cancel;

@end
