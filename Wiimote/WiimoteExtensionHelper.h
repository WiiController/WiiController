//
//  WiimoteExtensionHelper.h
//  Wiimote
//
//  Created by alxn1 on 31.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteExtension+PlugIn.h"

@interface WiimoteExtensionHelper : NSObject
{
    @private
        Wiimote                 *_wiimote;
        WiimoteEventDispatcher  *_eventDispatcher;
        WiimoteIOManager        *_iOManager;

        NSMutableArray          *_extensionClasses;
        Class                    _currentClass;
        WiimoteExtension        *_extension;
        WiimoteExtension        *_subExtension;

        BOOL                     _isInitialized;
        BOOL                     _isStarted;
        BOOL                     _isCanceled;

        id                       _target;
        SEL                      _action;
}

- (id)initWithWiimote:(Wiimote*)wiimote
      eventDispatcher:(WiimoteEventDispatcher*)dispatcher
            ioManager:(WiimoteIOManager*)ioManager
     extensionClasses:(NSArray*)extensionClasses
         subExtension:(WiimoteExtension*)extension
               target:(id)target
               action:(SEL)action;

- (WiimoteExtension*)subExtension;

- (void)start;
- (void)cancel;

@end
