//
//  WJoyDeviceImpl.m
//  driver
//
//  Created by alxn1 on 17.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WJoyDeviceImpl.h"
#import "WJoyTool.h"
#import "DextManager.h"
#import <IOKit/kext/KextManager.h>

static char const *WJoyDeviceDriverClass = "com_alxn1_driver_WirtualJoy";
static char const *driverKitDriverUserClass = "ca_igregory_WiiController";

@interface WJoyDeviceImpl (PrivatePart)

+ (io_service_t)findService;
+ (io_connect_t)createNewConnection;

+ (BOOL)isDriverLoaded;
+ (BOOL)loadDriver;

@end

static Class<DriverManager> driverManager()
{
    if (@available(macOS 10.15, *))
    {
        return [DextManager self];
    }
    else
    {
        return [WJoyTool self];
    }
}

@implementation WJoyDeviceImpl

+ (BOOL)prepare
{
    return [WJoyDeviceImpl loadDriver];
}

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;

    if (![WJoyDeviceImpl prepare])
    {
        return nil;
    }

    _connection = [WJoyDeviceImpl createNewConnection];
    if (_connection == IO_OBJECT_NULL)
    {
        return nil;
    }

    return self;
}

- (void)dealloc
{
    if (_connection != IO_OBJECT_NULL)
        IOServiceClose(_connection);
}

- (BOOL)call:(WJoyDeviceMethodSelector)selector
{
    return [self call:selector data:nil];
}

- (BOOL)call:(WJoyDeviceMethodSelector)selector data:(NSData *)data
{
    return (IOConnectCallMethod(_connection, selector, NULL, 0, [data bytes], [data length], NULL, NULL, NULL, NULL) == KERN_SUCCESS);
}

- (BOOL)call:(WJoyDeviceMethodSelector)selector string:(NSString *)string
{
    const char *data = [string UTF8String];
    size_t size = strlen(data) + 1; // zero-terminator

    return [self call:selector data:[NSData dataWithBytes:data length:size]];
}

@end

@implementation WJoyDeviceImpl (Methods)

- (BOOL)setDeviceProductString:(NSString *)string
{
    return [self call:WJoyDeviceMethodSelectorSetDeviceProductString string:string];
}

- (BOOL)setDeviceSerialNumberString:(NSString *)string
{
    return [self call:WJoyDeviceMethodSelectorSetDeviceSerialNumberString string:string];
}

- (BOOL)setDeviceVendorID:(uint32_t)vendorID productID:(uint32_t)productID
{
    char data[sizeof(uint32_t) * 2] = { 0 };

    memcpy(data, &vendorID, sizeof(uint32_t));
    memcpy(data + sizeof(uint32_t), &productID, sizeof(uint32_t));

    return [self call:WJoyDeviceMethodSelectorSetDeviceVendorAndProductID
                 data:[NSData dataWithBytes:data length:sizeof(data)]];
}

- (BOOL)enable:(NSData *)HIDDescriptor
{
    return [self call:WJoyDeviceMethodSelectorEnable data:HIDDescriptor];
}

- (BOOL)disable
{
    return [self call:WJoyDeviceMethodSelectorDisable];
}

- (BOOL)updateState:(NSData *)HIDState
{
    return [self call:WJoyDeviceMethodSelectorUpdateState data:HIDState];
}

@end

@implementation WJoyDeviceImpl (PrivatePart)

+ (io_service_t)findService
{
    io_service_t result = IO_OBJECT_NULL;

    result = IOServiceGetMatchingService(
        kIOMasterPortDefault,
        IOServiceMatching(WJoyDeviceDriverClass));
    if (!result)
    {
        result = IOServiceGetMatchingService(
            kIOMasterPortDefault,
            IOServiceNameMatching(driverKitDriverUserClass));
    }

    return result;
}

+ (io_connect_t)createNewConnection
{
    io_connect_t result = IO_OBJECT_NULL;
    io_service_t service = [WJoyDeviceImpl findService];

    if (service == IO_OBJECT_NULL)
        return result;

    if (IOServiceOpen(service, mach_task_self(), 0, &result) != KERN_SUCCESS)
        result = IO_OBJECT_NULL;

    IOObjectRelease(service);
    return result;
}

+ (BOOL)isDriverLoaded
{
    io_service_t service = [WJoyDeviceImpl findService];
    BOOL result = (service != IO_OBJECT_NULL);

    IOObjectRelease(service);
    return result;
}

+ (BOOL)loadDriver
{
    if ([self isDriverLoaded]) return YES;
    return [driverManager() loadDriver];
}

@end
