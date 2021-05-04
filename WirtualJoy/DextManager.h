//
//  DextManager.h
//  WirtualJoy
//
//  Created by Ian Gregory on 30 Apr ’21.
//

#import <Foundation/Foundation.h>

#import "DriverManager.h"

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(macos(10.15))
@interface DextManager : NSObject <DriverManager>

@end

NS_ASSUME_NONNULL_END
