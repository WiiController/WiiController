//
//  ProfileConsumer.h
//  WiiController
//
//  Created by Ian Gregory on 28 May ’21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ButtonConfiguration;
@class Wiimote;

@protocol ProfileProvider <NSObject>

- (ButtonConfiguration *)profileForDevice:(Wiimote *)device;

@end

NS_ASSUME_NONNULL_END
