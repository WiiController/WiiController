//
//  StatusBarItemController.h
//  WJoy
//
//  Created by alxn1 on 27.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ProfileProvider.h"

@interface StatusBarItemController : NSObject <ProfileProvider>

+ (instancetype)start;

@end
