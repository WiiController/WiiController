//
//  DextManager.m
//  WirtualJoy
//
//  Created by Ian Gregory on 30 Apr ’21.
//

#import "DextManager.h"

#import <SystemExtensions/SystemExtensions.h>

static NSString *const driverExtensionIdentifier = @"ca.igregory.WiiController.dext";

API_AVAILABLE(macos(10.15))
@interface DextManagerExtensionRequestDelegate : NSObject <OSSystemExtensionRequestDelegate>

@property BOOL requestSucceeded;
@property dispatch_semaphore_t sema;

@end

@implementation DextManagerExtensionRequestDelegate

- (instancetype)init {
    _sema = dispatch_semaphore_create(0);
    return self;
}

- (OSSystemExtensionReplacementAction)request:(OSSystemExtensionRequest *)request actionForReplacingExtension:(OSSystemExtensionProperties *)existing withExtension:(OSSystemExtensionProperties *)ext {
    NSLog(@"WiiController DEXT request: Replacing existing extension");
    return OSSystemExtensionReplacementActionReplace;
}

- (void)requestNeedsUserApproval:(OSSystemExtensionRequest *)request {
    NSLog(@"WiiController DEXT request: Needs user approval");
}

- (void)request:(OSSystemExtensionRequest *)request didFinishWithResult:(OSSystemExtensionRequestResult)result {
    NSLog(@"WiiController DEXT request: Succeeded with result: %ld", (long)result);
    _requestSucceeded = YES;
    dispatch_semaphore_signal(_sema);
}
- (void)request:(OSSystemExtensionRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"WiiController DEXT request: Failed with error: %@", error);
    _requestSucceeded = NO;
    dispatch_semaphore_signal(_sema);
}

@end

static dispatch_queue_t requestQueue(void) {
    static dispatch_queue_t queue;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        queue = dispatch_queue_create("DextManager system extension request queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, QOS_MIN_RELATIVE_PRIORITY));
    });
    
    return queue;
}
static API_AVAILABLE(macos(10.15))
DextManagerExtensionRequestDelegate *requestDelegate(void) {
    static DextManagerExtensionRequestDelegate *requestDelegate;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        requestDelegate = [DextManagerExtensionRequestDelegate new];
    });
    
    return requestDelegate;
}

@implementation DextManager
    
+ (BOOL)loadDriver {
    __auto_type request = [OSSystemExtensionRequest activationRequestForExtension:driverExtensionIdentifier queue:requestQueue()];
    request.delegate = requestDelegate();
    [[OSSystemExtensionManager sharedManager] submitRequest:request];
    
    dispatch_semaphore_wait(requestDelegate().sema, DISPATCH_TIME_FOREVER);
    return requestDelegate().requestSucceeded;
}

+ (BOOL)unloadDriver {
    __auto_type request = [OSSystemExtensionRequest deactivationRequestForExtension:driverExtensionIdentifier queue:requestQueue()];
    request.delegate = requestDelegate();
    [[OSSystemExtensionManager sharedManager] submitRequest:request];
    
    dispatch_semaphore_wait(requestDelegate().sema, DISPATCH_TIME_FOREVER);
    return requestDelegate().requestSucceeded;
}

@end
