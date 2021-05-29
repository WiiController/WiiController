//
//  ButtonConfiguration.m
//  WiiController
//
//  Created by Ian Gregory on 28 May ’21.
//

#import "ButtonConfiguration.h"

@implementation ButtonConfiguration
{
    ButtonConfigurationDictionary _dictionary;
}

+ (instancetype)configurationWithName:(NSString *)name path:(NSString *)path dictionary:(ButtonConfigurationDictionary)dictionary
{
    ButtonConfiguration *configuration = [self new];
    configuration.name = name;
    configuration.path = path;
    configuration->_dictionary = dictionary;
    return configuration;
}

- (NSInteger)buttonNumberForExtensionName:(NSString *)extension buttonNumber:(NSInteger)button
{
    __auto_type mappedButton = _dictionary[extension][@"Button"][@(button)];
    return mappedButton ? mappedButton.intValue : button;
}
- (NSInteger)axisNumberForExtensionName:(NSString *)extension axisNumber:(NSInteger)button
{
    __auto_type mappedAxis = _dictionary[extension][@"Axis"][@(button)];
    return mappedAxis ? mappedAxis.intValue : button;
}

@end
