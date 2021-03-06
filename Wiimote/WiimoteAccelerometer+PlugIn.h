//
//  WiimoteAccelerometer+PlugIn.h
//  Wiimote
//
//  Created by alxn1 on 06.08.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <Wiimote/WiimoteAccelerometer.h>
#import <Wiimote/WiimoteProtocol.h>

@class WiimoteAccelerometer;

@protocol WiimoteAccelerometerDelegate <NSObject>

- (void)wiimoteAccelerometer:(WiimoteAccelerometer*)accelerometer
         enabledStateChanged:(BOOL)enabled;

- (void)wiimoteAccelerometer:(WiimoteAccelerometer*)accelerometer
             gravityChangedX:(CGFloat)x
                           y:(CGFloat)y
                           z:(CGFloat)z;

- (void)wiimoteAccelerometer:(WiimoteAccelerometer*)accelerometer
                pitchChanged:(CGFloat)pitch
                        roll:(CGFloat)roll;

@end

@interface WiimoteAccelerometer (PlugIn)

- (void)setHardwareValueX:(uint16_t)x y:(uint16_t)y z:(uint16_t)z;

- (void)setHardwareZeroX:(uint16_t)x y:(uint16_t)y z:(uint16_t)z;
- (void)setHardware1gX:(uint16_t)x y:(uint16_t)y z:(uint16_t)z;

- (void)setCalibrationData:(const WiimoteDeviceAccelerometerCalibrationData*)calibrationData;

- (BOOL)isHardwareZeroValuesInvalid;
- (BOOL)isHardware1gValuesInvalid;

- (void)reset;

@property(nonatomic, weak) id<WiimoteAccelerometerDelegate> delegate;

@end
