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
    HIDManager      *m_Owner;

    BOOL             m_IsValid;
    BOOL             m_IsDisconnected;
    IOHIDDeviceRef   m_Handle;
    IOOptionBits     m_Options;
    NSDictionary    *m_Properties;

    NSMutableData   *m_ReportBuffer;

    id               m_Delegate;
}

- (void)dealloc
{
    if(m_Handle != NULL)
        CFRelease(m_Handle);

}

- (HIDManager*)owner
{
    return m_Owner;
}

- (BOOL)isValid
{
    return m_IsValid;
}

- (void)invalidate
{
    if([self isValid])
    {
        m_IsValid   = NO;
        m_Options   = kIOHIDOptionsTypeNone;

        [self closeDevice];

        [m_Delegate HIDDeviceDisconnected:self];
		[[HIDManager manager] HIDDeviceDisconnected:self];
    }
}

- (IOOptionBits)options
{
    return m_Options;
}

- (BOOL)setOptions:(IOOptionBits)options
{
    if(![self isValid])
        return NO;

    if(m_Options == options)
        return YES;

	[self closeDevice];

	IOOptionBits oldOptions = m_Options;

	m_Options = options;

    if(![self openDevice])
    {
		m_Options = oldOptions;

        if(![self openDevice])
            [self invalidate];

        return NO;
    }

    m_Options = options;
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
                                        m_Handle,
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

- (NSDictionary*)properties
{
    return m_Properties;
}

- (id)delegate
{
    return m_Delegate;
}

- (void)setDelegate:(id)delegate
{
    m_Delegate = delegate;
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
	return ((NSUInteger)m_Handle);
}

- (BOOL)isEqual:(id)object
{
    if([object isKindOfClass:[self class]])
        return (m_Handle == ((W_HIDDevice*)object)->m_Handle);

    if(CFGetTypeID((__bridge CFTypeRef)(object)) == IOHIDDeviceGetTypeID())
        return (m_Handle == (__bridge IOHIDDeviceRef)object);

    return NO;
}

// MARK: Properties

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

    m_Owner             = manager;
    m_IsValid           = YES;
    m_IsDisconnected    = NO;
    m_Handle            = handle;
    m_Options           = options;
    m_Properties        = [self makePropertiesDictionary];
    m_ReportBuffer      = [[NSMutableData alloc] initWithLength:[self maxInputReportSize]];
    m_Delegate          = nil;

    CFRetain(m_Handle);

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
    return ((id)IOHIDDeviceGetProperty(m_Handle, (CFStringRef)key));
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
                                m_Handle,
                                [[NSRunLoop currentRunLoop] getCFRunLoop],
                                (CFStringRef)NSRunLoopCommonModes);

    IOHIDDeviceRegisterInputReportCallback(
                                m_Handle,
                                [m_ReportBuffer mutableBytes],
                                [m_ReportBuffer length],
                                HIDDeviceReportCallback,
                                (__bridge void * _Nullable)(self));

    IOHIDDeviceRegisterRemovalCallback(
                                m_Handle,
                                HIDDeviceDisconnectCallback,
                                (__bridge void * _Nullable)(self));

    return (IOHIDDeviceOpen(m_Handle, m_Options) == kIOReturnSuccess);
}

- (void)closeDevice
{
    if(!m_IsDisconnected)
    {
        IOHIDDeviceClose(m_Handle, 0);

        IOHIDDeviceUnscheduleFromRunLoop(
                                    m_Handle,
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
    m_IsDisconnected = YES;
    [self invalidate];
}

@end
