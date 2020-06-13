//
//  WiimoteInquiry.h
//  Wiimote
//
//  Created by alxn1 on 25.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IOBluetoothDeviceInquiry;

FOUNDATION_EXPORT NSString *WiimoteDeviceName;
FOUNDATION_EXPORT NSString *WiimoteDeviceNameTR;
FOUNDATION_EXPORT NSString *WiimoteDeviceNameUPro;
FOUNDATION_EXPORT NSString *WiimoteDeviceNameBalanceBoard;

@interface WiimoteInquiry : NSObject
{
    @private
        BOOL                      _isUseOneButtonClickConnection;

        IOBluetoothDeviceInquiry *_inquiry;
        id                        _target;
        SEL                       _action;
}

+ (BOOL)isBluetoothEnabled;

+ (WiimoteInquiry*)sharedInquiry;

+ (NSArray*)supportedModelNames;
+ (void)registerSupportedModelName:(NSString*)name;

- (BOOL)isStarted;
- (BOOL)startWithTarget:(id)target didEndAction:(SEL)action;
- (BOOL)stop;

- (BOOL)isUseOneButtonClickConnection;
- (void)setUseOneButtonClickConnection:(BOOL)useOneButtonClickConnection;

@end
