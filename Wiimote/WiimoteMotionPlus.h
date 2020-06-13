//
//  WiimoteMotionPlus.h
//  Wiimote
//
//  Created by alxn1 on 13.09.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteExtension+PlugIn.h"
#import "WiimoteMotionPlusDelegate.h"

@interface WiimoteMotionPlus : WiimoteExtension<WiimoteMotionPlusProtocol>
{
    @private
        WiimoteIOManager		*_iOManager;
        WiimoteExtension		*_subExtension;
		NSUInteger				 _reportCounter;
		NSUInteger				 _extensionReportCounter;

		BOOL					 _isSubExtensionDisconnected;
        WiimoteMotionPlusReport  _report;
}

@end
