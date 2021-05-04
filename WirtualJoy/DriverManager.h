//
//  DriverManager.h
//  WirtualJoy
//
//  Created by Ian Gregory on 30 Apr ’21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DriverManager <NSObject>

+ (BOOL)loadDriver;

@end

NS_ASSUME_NONNULL_END
