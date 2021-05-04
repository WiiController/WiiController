//
//  MainController.m
//  VHID
//
//  Created by alxn1 on 24.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "MainController.h"

@implementation MainController

- (id)init
{
    self = [super init];
    if(self == nil)
        return nil;
    
    _mouseState    = [[VHIDDevice alloc] initWithType:VHIDDeviceTypeMouse
                                          pointerCount:6
                                           buttonCount:2
                                            isRelative:YES];

    NSLog(@"%@", _mouseState);
    _virtualMouse  = [[WJoyDevice alloc] initWithHIDDescriptor:[_mouseState descriptor]
                                                  productString:@"Virtual Alxn1 Mouse"];

    [_mouseState setDelegate:self];
    if(_virtualMouse == nil || _mouseState == nil)
        NSLog(@"error");

    return self;
}

- (void)dealloc
{
    [_mouseState release];
    [_virtualMouse release];
    [super dealloc];
}

- (void)VHIDDevice:(VHIDDevice*)device stateChanged:(NSData*)state
{
    [_virtualMouse updateHIDState:state];
}

- (void)testView:(TestView*)view keyPressed:(TestViewKey)key
{
    NSPoint newPosition = NSZeroPoint;

    switch(key)
    {
        case TestViewKeyUp:
            newPosition.y += 0.025f;
            break;

        case TestViewKeyDown:
            newPosition.y -= 0.025f;
            break;

        case TestViewKeyLeft:
            newPosition.x -= 0.025f;
            break;

        case TestViewKeyRight:
            newPosition.x += 0.025f;
            break;
    }

    [_mouseState setPointer:0 position:newPosition];
}

@end
