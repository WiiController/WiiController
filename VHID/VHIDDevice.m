//
//  VHIDDevice.m
//  VHID
//
//  Created by alxn1 on 23.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "VHIDDevice.h"
#import "VHIDButtonCollection.h"
#import "VHIDPointerCollection.h"

#define HIDDescriptorMouseAdditionalBytes 12
#define HIDDescriptorJoystickAdditionalBytes 10

@interface VHIDDevice (PrivatePart)

- (NSData *)createDescriptor;

@end

@implementation VHIDDevice

+ (NSUInteger)maxButtonCount
{
    return [VHIDButtonCollection maxButtonCount];
}

+ (NSUInteger)maxPointerCount
{
    return [VHIDPointerCollection maxPointerCount];
}

- (id)initWithType:(VHIDDeviceType)type
      pointerCount:(NSUInteger)pointerCount
       buttonCount:(NSUInteger)buttonCount
        isRelative:(BOOL)isRelative
{
    self = [super init];

    _type = type;
    _buttons = [[VHIDButtonCollection alloc] initWithButtonCount:buttonCount];
    _pointers = [[VHIDPointerCollection alloc] initWithPointerCount:pointerCount
                                                         isRelative:isRelative];

    _state = [[NSMutableData alloc]
        initWithLength:
            [[_buttons state] length] +
        [[_pointers state] length]];

    if (_buttons == nil || _pointers == nil)
    {
        return nil;
    }

    _descriptor = [self createDescriptor];

    return self;
}

- (VHIDDeviceType)type
{
    return _type;
}

- (BOOL)isRelative
{
    if (_pointers == nil)
        return NO;

    return [_pointers isRelative];
}

- (NSUInteger)buttonCount
{
    return [_buttons buttonCount];
}

- (NSUInteger)pointerCount
{
    return [_pointers pointerCount];
}

- (BOOL)isButtonPressed:(NSUInteger)buttonIndex
{
    return [_buttons isButtonPressed:buttonIndex];
}

- (void)setButton:(NSUInteger)buttonIndex pressed:(BOOL)pressed
{
    if (buttonIndex >= [self buttonCount] ||
        [self isButtonPressed:buttonIndex] == pressed)
    {
        return;
    }

    [_buttons setButton:buttonIndex pressed:pressed];

    if (_delegate != nil)
        [_delegate VHIDDevice:self stateChanged:[self state]];
}

- (NSPoint)pointerPosition:(NSUInteger)pointerIndex
{
    if (_pointers == nil)
        return NSZeroPoint;

    return [_pointers pointerPosition:pointerIndex];
}

- (void)setPointer:(NSUInteger)pointerIndex position:(NSPoint)position
{
    if (pointerIndex >= [self pointerCount] || NSEqualPoints([self pointerPosition:pointerIndex], position))
    {
        return;
    }

    [_pointers setPointer:pointerIndex position:position];

    if (_delegate != nil)
        [_delegate VHIDDevice:self stateChanged:[self state]];
}

- (void)reset
{
    [_buttons reset];
    [_pointers reset];

    if (_delegate != nil)
        [_delegate VHIDDevice:self stateChanged:[self state]];
}

- (NSData *)descriptor
{
    return _descriptor;
}

- (NSData *)state
{
    unsigned char *data = [_state mutableBytes];
    NSData *buttonState = [_buttons state];
    NSData *pointerState = [_pointers state];

    if (buttonState != nil)
    {
        memcpy(
            data,
            [buttonState bytes],
            [buttonState length]);
    }

    if (pointerState != nil)
    {
        memcpy(
            data + [buttonState length],
            [pointerState bytes],
            [pointerState length]);
    }

    return _state;
}

- (id<VHIDDeviceDelegate>)delegate
{
    return _delegate;
}

- (void)setDelegate:(id<VHIDDeviceDelegate>)obj
{
    _delegate = obj;
}

@end

@implementation VHIDDevice (PrivatePart)

- (NSData *)createDescriptor
{
    BOOL isMouse = (_type == VHIDDeviceTypeMouse);
    NSData *buttonsHID = [_buttons descriptor];
    NSData *pointersHID = [_pointers descriptor];
    NSMutableData *result = [NSMutableData dataWithLength:
                                               [buttonsHID length] +
                                           [pointersHID length] + ((isMouse) ? (HIDDescriptorMouseAdditionalBytes) : (HIDDescriptorJoystickAdditionalBytes))];

    unsigned char *data = [result mutableBytes];
    unsigned char usage = ((isMouse) ? (0x02) : (0x05));

    *data = 0x05;
    data++;
    *data = 0x01;
    data++; // USAGE_PAGE (Generic Desktop)
    *data = 0x09;
    data++;
    *data = usage;
    data++; // USAGE (Mouse/Game Pad)
    *data = 0xA1;
    data++;
    *data = 0x01;
    data++; // COLLECTION (Application)

    if (isMouse)
    {
        *data = 0x09;
        data++;
        *data = 0x01;
        data++; // USAGE (Pointer)
    }

    *data = 0xA1;
    data++;
    *data = 0x00;
    data++; // COLLECTION (Physical)

    if (buttonsHID != nil)
    {
        memcpy(data, [buttonsHID bytes], [buttonsHID length]);
        data += [buttonsHID length];
    }

    if (pointersHID != nil)
    {
        memcpy(data, [pointersHID bytes], [pointersHID length]);
        data += [pointersHID length];
    }

    *data = 0xC0;
    data++; // END_COLLECTION
    *data = 0xC0;
    data++; // END_COLLECTION

    return result;
}

@end
