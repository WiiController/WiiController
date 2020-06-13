//
//  W_HIDDevice.m
//  HID
//
//  Created by alxn1 on 24.06.13.
//  Copyright 2013 alxn1. All rights reserved.
//

#import "W_HIDDevice.h"
#import "HIDManager.h"

@interface NSObject (W_HIDDeviceDelegate) <W_HIDDeviceDelegate>
@end

@implementation NSObject (W_HIDDeviceDelegate)

- (void)HIDDevice:(W_HIDDevice*)device reportDataReceived:(const uint8_t*)bytes length:(NSUInteger)length
{
}

- (void)HIDDeviceDisconnected:(W_HIDDevice*)device
{
}

@end

@implementation W_HIDDevice
{
    BOOL _isDisconnected;
    IOHIDDeviceRef   _handle;

    NSMutableData   *_reportBuffer;
}

- (void)dealloc
{
    if(_handle != NULL)
        CFRelease(_handle);

}

- (void)invalidate
{
    if([self isValid])
    {
        _isValid   = NO;
        _options   = kIOHIDOptionsTypeNone;

        [self closeDevice];

        [_delegate HIDDeviceDisconnected:self];
		[[HIDManager manager] HIDDeviceDisconnected:self];
    }
}

- (BOOL)setOptions:(IOOptionBits)options
{
    if(![self isValid])
        return NO;

    if(_options == options)
        return YES;

	[self closeDevice];

	IOOptionBits oldOptions = _options;

	_options = options;

    if(![self openDevice])
    {
		_options = oldOptions;

        if(![self openDevice])
            [self invalidate];

        return NO;
    }

    _options = options;
    return YES;
}

- (BOOL)postBytes:(const uint8_t*)bytes length:(NSUInteger)length
{
    BOOL result = NO;

    if([self isValid])
    {
        if(length > 0)
        {
            result = (IOHIDDeviceSetReport(
                                        _handle,
                                        kIOHIDReportTypeOutput,
                                        0,
                                        bytes,
                                        length) == kIOReturnSuccess);
        }
        else
            result = YES;
    }

    return result;
}

- (NSString*)description
{
    return [NSString stringWithFormat:
                                @"HIDDevice (%p): %@",
                                self,
                                [[self properties] description]];
}

- (NSUInteger)hash
{
	return ((NSUInteger)_handle);
}

- (BOOL)isEqual:(id)object
{
    if([object isKindOfClass:[self class]])
        return (_handle == ((W_HIDDevice*)object)->_handle);

    if(CFGetTypeID((__bridge CFTypeRef)(object)) == IOHIDDeviceGetTypeID())
        return (_handle == (__bridge IOHIDDeviceRef)object);

    return NO;
}

- (NSString*)name
{
    return [[self properties] objectForKey:(NSString*)CFSTR(kIOHIDProductKey)];
}

- (NSString*)address
{
    return [[self properties] objectForKey:(NSString*)CFSTR(kIOHIDSerialNumberKey)];
}

// MARK: Creation

- (id)initWithOwner:(HIDManager*)manager
          deviceRef:(IOHIDDeviceRef)handle
            options:(IOOptionBits)options
{
    self = [super init];

    if(self == nil)
        return nil;

    if(handle == NULL)
    {
        return nil;
    }

    _owner             = manager;
    _isValid           = YES;
    _isDisconnected    = NO;
    _handle            = handle;
    _options           = options;
    _properties        = [self makePropertiesDictionary];
    _reportBuffer      = [[NSMutableData alloc] initWithLength:[self maxInputReportSize]];
    _delegate          = nil;

    CFRetain(_handle);

    [self openDevice];

    return self;
}

- (NSDictionary*)makePropertiesDictionary
{
    static CFStringRef keys[] =
    {
        CFSTR(kIOHIDTransportKey),
        CFSTR(kIOHIDVendorIDKey),
        CFSTR(kIOHIDVendorIDSourceKey),
        CFSTR(kIOHIDProductIDKey),
        CFSTR(kIOHIDVersionNumberKey),
        CFSTR(kIOHIDManufacturerKey),
        CFSTR(kIOHIDProductKey),
        CFSTR(kIOHIDSerialNumberKey),
        CFSTR(kIOHIDCountryCodeKey),
        CFSTR(kIOHIDLocationIDKey),
        CFSTR(kIOHIDDeviceUsageKey),
        CFSTR(kIOHIDDeviceUsagePageKey),
        CFSTR(kIOHIDDeviceUsagePairsKey),
        CFSTR(kIOHIDPrimaryUsageKey),
        CFSTR(kIOHIDPrimaryUsagePageKey),
        CFSTR(kIOHIDMaxInputReportSizeKey),
        CFSTR(kIOHIDMaxOutputReportSizeKey),
        CFSTR(kIOHIDMaxFeatureReportSizeKey),
        CFSTR(kIOHIDReportIntervalKey),
        NULL
    };

    CFStringRef         *current    = keys;
    NSMutableDictionary *result     = [NSMutableDictionary dictionary];

    while(*current != NULL)
    {
        NSString    *key   = (__bridge NSString*)*current;
        id           value = [self propertyForKey:key];

        if(value != nil)
            [result setObject:value forKey:key];

        current++;
    }

    return result;
}

- (id)propertyForKey:(NSString*)key
{
    return ((id)IOHIDDeviceGetProperty(_handle, (CFStringRef)key));
}

- (NSUInteger)maxInputReportSize
{
    NSUInteger result = [[[self properties]
                                    objectForKey:(id)CFSTR(kIOHIDMaxInputReportSizeKey)]
                                unsignedIntegerValue];

    if(result == 0)
        result = 128;

    return result;
}

// MARK: Lifecycle

static void HIDDeviceReportCallback(
                                void            *context,
                                IOReturn         result,
                                void            *sender,
                                IOHIDReportType  type,
                                uint32_t         reportID,
                                uint8_t         *report,
                                CFIndex          reportLength)
{
    if(reportLength > 0)
    {
        [(__bridge W_HIDDevice*)context
                    handleReport:report
                          length:reportLength];
    }
}

static void HIDDeviceDisconnectCallback(
                                void            *context,
                                IOReturn         result,
                                void            *sender)
{
    [(__bridge W_HIDDevice*)context disconnected];
}

- (BOOL)openDevice
{
    IOHIDDeviceScheduleWithRunLoop(
                                _handle,
                                [[NSRunLoop currentRunLoop] getCFRunLoop],
                                (CFStringRef)NSRunLoopCommonModes);

    IOHIDDeviceRegisterInputReportCallback(
                                _handle,
                                [_reportBuffer mutableBytes],
                                [_reportBuffer length],
                                HIDDeviceReportCallback,
                                (__bridge void * _Nullable)(self));

    IOHIDDeviceRegisterRemovalCallback(
                                _handle,
                                HIDDeviceDisconnectCallback,
                                (__bridge void * _Nullable)(self));

    return (IOHIDDeviceOpen(_handle, _options) == kIOReturnSuccess);
}

- (void)closeDevice
{
    if(!_isDisconnected)
    {
        IOHIDDeviceClose(_handle, 0);

        IOHIDDeviceUnscheduleFromRunLoop(
                                    _handle,
                                    [[NSRunLoop currentRunLoop] getCFRunLoop],
                                    (CFStringRef)NSRunLoopCommonModes);
    }
}

- (void)handleReport:(uint8_t*)report length:(CFIndex)length
{
    [[self delegate]
                HIDDevice:self
       reportDataReceived:report
                   length:length];
}

- (void)disconnected
{
    _isDisconnected = YES;
    [self invalidate];
}

@end
