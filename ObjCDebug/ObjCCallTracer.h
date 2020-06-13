//
//  ObjCCallTracer.h
//  ObjCDebug
//
//  Created by alxn1 on 26.11.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjCCallTracer : NSObject
{
    @private
        uint64_t    _logEnableFn;
        uint64_t    _setLogFnFn;
        BOOL        _isEnabled;
}

+ (ObjCCallTracer*)sharedInstance;

@property (nonatomic, readwrite, assign) BOOL enabled;

@end
