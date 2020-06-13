//
//  WiimoteEvent.m
//  Wiimote
//
//  Created by alxn1 on 18.01.14.
//

#import "WiimoteEvent.h"

@implementation WiimoteEvent

+ (WiimoteEvent*)eventWithWiimote:(Wiimote*)wiimote
                             path:(NSString*)path
                            value:(CGFloat)value
{
    return [[WiimoteEvent alloc]
                        initWithWiimote:wiimote
                                   path:path
                                  value:value];
}

- (id)initWithWiimote:(Wiimote*)wiimote
                 path:(NSString*)path
                value:(CGFloat)value
{
    self = [super init];
    if(self == nil)
        return nil;

    _wiimote           = wiimote;
    _path              = [path copy];
    _pathComponents    = [_path componentsSeparatedByString:@"."];
    _value             = value;

    return self;
}


- (Wiimote*)wiimote
{
    return _wiimote;
}

- (NSString*)path
{
    return _path;
}

- (NSString*)firstPathComponent
{
    return [_pathComponents objectAtIndex:0];
}

- (NSString*)lastPathComponent
{
    return [_pathComponents lastObject];
}

- (NSArray*)pathComponents
{
    return _pathComponents;
}

- (CGFloat)value
{
    return _value;
}

@end
