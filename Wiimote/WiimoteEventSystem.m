//
//  WiimoteEventSystem.m
//  Wiimote
//
//  Created by alxn1 on 18.01.14.
//

#import "WiimoteEventSystem+PlugIn.h"

NSString *WiimoteEventSystemNotification = @"WiimoteEventSystemNotification";

NSString *WiimoteEventKey = @"WiimoteEventKey";

@implementation NSObject (WiimoteEventSystemObserver)

- (void)wiimoteEvent:(WiimoteEvent *)event
{
}

@end

@implementation WiimoteEventSystem

+ (void)subscribeToNotifications:(WiimoteEventSystem *)system
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSDictionary *map = [WiimoteEventSystem notificationDictionary];
    NSEnumerator *en = [map keyEnumerator];
    NSString *name = [en nextObject];

    while (name != nil)
    {
        SEL selector = [[map objectForKey:name] pointerValue];

        [center addObserver:system
                   selector:selector
                       name:name
                     object:nil];

        name = [en nextObject];
    }
}

+ (WiimoteEventSystem *)defaultEventSystem
{
    static WiimoteEventSystem *result = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        result = [[WiimoteEventSystem alloc] init];
    });
    return result;
}

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;

    _observers = [[NSMutableSet alloc] init];

    [WiimoteEventSystem subscribeToNotifications:self];
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addObserver:(id)observer
{
    [_observers addObject:observer];
}

- (void)removeObserver:(id)observer
{
    [_observers removeObject:observer];
}

@end
