//
//  WJoyDeviceImpl.m
//  driver
//
//  Created by alxn1 on 17.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WJoyDeviceImpl.h"
#import "WJoyTool.h"

#define WJoyDeviceDriverID @"it_unbit_foohid"

@interface WJoyDeviceImpl (PrivatePart)

+ (void)registerAtExitCallback;

+ (io_service_t)findService;
+ (io_connect_t)createNewConnection;

+ (BOOL)isDriverLoaded;
+ (BOOL)loadDriver;
+ (BOOL)unloadDriver;

@end

@implementation WJoyDeviceImpl

+ (BOOL)prepare
{
    if(![WJoyDeviceImpl loadDriver])
        return NO;

    [WJoyDeviceImpl registerAtExitCallback];
    return YES;
}

- (id)init
{
    self = [super init];
    if(self == nil)
        return nil;

    if(![WJoyDeviceImpl prepare])
    {
        [self release];
        return nil;
    }

    m_Connection = [WJoyDeviceImpl createNewConnection];
    if(m_Connection == IO_OBJECT_NULL)
    {
        [self release];
        return nil;
    }

    return self;
}

- (void)dealloc
{
    if(m_Connection != IO_OBJECT_NULL)
        IOServiceClose(m_Connection);

    [super dealloc];
}

- (BOOL)call:(WJoyDeviceMethodSelector)selector
{
    return [self call:selector data:nil];
}

- (BOOL)call:(WJoyDeviceMethodSelector)selector data:(NSData*)data
{
    return (IOConnectCallMethod(
                            m_Connection,
                            selector,
                            NULL,			// inputValues
                            0,				// inputCount
                            [data bytes],	// inputStruct
                            [data length],	// inputStructSize
                            NULL,	// outputValues
                            NULL,	// outputCount
                            NULL,	// outputStruct
                            NULL	// outputStructSize
								) == KERN_SUCCESS);
}

- (BOOL)call:(WJoyDeviceMethodSelector)selector string:(NSString*)string
{
    const char *data = [string UTF8String];
    size_t      size = strlen(data) + 1; // zero-terminator

    return [self call:selector data:[NSData dataWithBytes:data length:size]];
}

@end

@implementation WJoyDeviceImpl (Methods)

- (BOOL)setDeviceProductString:(NSString*)string
{
	// TODO: Justin: Remove this since it isn't supported by foo-hid. Instead, we need to destroy the old device and create a new one with the updated info.
    //return [self call:WJoyDeviceMethodSelectorSetDeviceProductString string:string];
	return YES;
}

- (BOOL)setDeviceSerialNumberString:(NSString*)string
{
	// TODO: Justin: Remove this since it isn't supported by foo-hid. Instead, we need to destroy the old device and create a new one with the updated info.
    //return [self call:WJoyDeviceMethodSelectorSetDeviceSerialNumberString string:string];
	return YES;
}

- (BOOL)setDeviceVendorID:(uint32_t)vendorID productID:(uint32_t)productID
{
    char data[sizeof(uint32_t) * 2] = { 0 };

    memcpy(data, &vendorID, sizeof(uint32_t));
    memcpy(data + sizeof(uint32_t), &productID, sizeof(uint32_t));

    return [self call:WJoyDeviceMethodSelectorSetDeviceVendorAndProductID
                 data:[NSData dataWithBytes:data length:sizeof(data)]];
}

- (BOOL)enable:(NSData*)HIDDescriptor
{
	// foohid requires the descriptor to be embedded with other info when sending to the IOUserClient create method
	
	// Copied from the foohid virtual mouse example
	uint32_t input_count = 8;
	uint64_t input[input_count];
	input[0] = (uint64_t) strdup("Justins Device 007");  // device name
	input[1] = strlen((char *)input[0]);  // name length
	input[2] = (uint64_t) [HIDDescriptor bytes];  // report descriptor
	input[3] = [HIDDescriptor length];  // report descriptor len
	input[4] = (uint64_t) strdup("SN 123456");  // serial number
	input[5] = strlen((char *)input[4]);  // serial number len
	input[6] = (uint64_t) 2;  // vendor ID
	input[7] = (uint64_t) 3;  // device ID
	
	// Transform this into an NSData object
	// TODO: Make call accept raw data as well, or reformat the data creation above to use NSData
	
	//NSData* data = [NSData dataWithBytes:(void *)input length:input_count*sizeof(uint64_t)];
	
    //return [self call:WJoyDeviceMethodSelectorEnable data:data];
	kern_return_t ret = IOConnectCallScalarMethod(m_Connection, WJoyDeviceMethodSelectorEnable, input, input_count, NULL, 0);
	if(ret != KERN_SUCCESS) // Note: KERN_SUCCESS == kIOReturnSuccess
	{
		NSLog(@"Unable to create HID device. May be fine if created previously.");
	}
	return ret == KERN_SUCCESS;
}

- (BOOL)disable
{
    return [self call:WJoyDeviceMethodSelectorDisable];
}

- (BOOL)updateState:(NSData*)HIDState
{
    //return [self call:WJoyDeviceMethodSelectorUpdateState data:HIDState];
	uint32_t send_count = 4;
	uint64_t send[send_count];
	send[0] = (uint64_t) strdup("Justins Device 007");  // device name
	send[1] = strlen((char *)send[0]);  // name length
	send[2] = (uint64_t) [HIDState bytes];  // mouse struct
	send[3] = [HIDState length];  // mouse struct len
	
	kern_return_t ret = IOConnectCallScalarMethod(m_Connection, WJoyDeviceMethodSelectorUpdateState, send, send_count, NULL, 0);
	if (ret != KERN_SUCCESS) {
		printf("Unable to send message to HID device.\n");
	}
	
	return ret == KERN_SUCCESS;
}

@end

@implementation WJoyDeviceImpl (PrivatePart)

static void onApplicationExit(void)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [WJoyDeviceImpl unloadDriver];
    [pool release];
}

+ (void)registerAtExitCallback
{
    static BOOL isRegistred = NO;

    if(isRegistred)
        return;

    atexit(onApplicationExit);
    isRegistred = YES;
}

+ (io_service_t)findService
{
    io_service_t	result = IO_OBJECT_NULL;
    io_iterator_t 	iterator;

    if(IOServiceGetMatchingServices(
                                 kIOMasterPortDefault,
                                 IOServiceMatching([WJoyDeviceDriverID UTF8String]),
                                &iterator) != KERN_SUCCESS)
    {
        return result;
    }
    
    result = IOIteratorNext(iterator);
    IOObjectRelease(iterator);
    return result;
}

+ (io_connect_t)createNewConnection
{
    io_connect_t result    = IO_OBJECT_NULL;
    io_service_t service   = [WJoyDeviceImpl findService];

    if(service == IO_OBJECT_NULL)
        return result;

    if(IOServiceOpen(service, mach_task_self(), 0, &result) != KERN_SUCCESS)
        result = IO_OBJECT_NULL;

    IOObjectRelease(service);
    return result;
}

+ (BOOL)isDriverLoaded
{
    io_service_t service = [WJoyDeviceImpl findService];
    BOOL         result  = (service != IO_OBJECT_NULL);

    IOObjectRelease(service);
    return result;
}

+ (BOOL)loadDriver
{
    if([self isDriverLoaded])
        return YES;
	
	
	// TODO: Show a popup asking the user to install foohid when the driver isn't found automatically
    return [WJoyTool loadDriver];
}

+ (BOOL)unloadDriver
{
    if(![self isDriverLoaded])
        return YES;

    return [WJoyTool unloadDriver];
}

@end
