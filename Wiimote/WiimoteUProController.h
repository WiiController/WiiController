//
//  WiimoteUProController.h
//  Wiimote
//
//  Created by alxn1 on 16.06.13.
//

#import "WiimoteGenericExtension.h"
#import "WiimoteEventDispatcher+UProController.h"

@interface WiimoteUProController : WiimoteGenericExtension<
											WiimoteUProControllerProtocol>
{
	@private
		BOOL		_buttonState[WiimoteUProControllerButtonCount];
        NSPoint		_stickPositions[WiimoteUProControllerStickCount];
}

@end
