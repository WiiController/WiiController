//
//  ButtonConfiguration.h
//  WiiController
//
//  Created by Ian Gregory on 28 May ’21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ButtonConfiguration : NSObject

typedef NSDictionary<NSString *, NSDictionary<NSString *, NSDictionary<NSNumber *, NSNumber *> *> *> *ButtonConfigurationDictionary;

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *path;

+ (instancetype)configurationWithName:(NSString *)name path:(NSString *)path dictionary:(ButtonConfigurationDictionary)dictionary;

- (NSInteger)buttonNumberForExtensionName:(NSString *)extension buttonNumber:(NSInteger)button;
- (NSInteger)axisNumberForExtensionName:(NSString *)extension axisNumber:(NSInteger)button;

@end

NS_ASSUME_NONNULL_END
