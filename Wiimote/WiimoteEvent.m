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

    m_Wiimote           = wiimote;
    m_Path              = [path copy];
    m_PathComponents    = [m_Path componentsSeparatedByString:@"."];
    m_Value             = value;

    return self;
}


- (Wiimote*)wiimote
{
    return m_Wiimote;
}

- (NSString*)path
{
    return m_Path;
}

- (NSString*)firstPathComponent
{
    return [m_PathComponents objectAtIndex:0];
}

- (NSString*)lastPathComponent
{
    return [m_PathComponents lastObject];
}

- (NSArray*)pathComponents
{
    return m_PathComponents;
}

- (CGFloat)value
{
    return m_Value;
}

@end
