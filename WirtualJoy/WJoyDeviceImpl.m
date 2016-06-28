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
	// TODO: Remove any dependencies on this method, as we no longer need it
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

	NSString *_deviceProductString = @"WJoy Controller";
	NSString *_deviceSerialNumberString = @"SN WJoy";
	uint32 _deviceVendorID = 0;
	uint32 _deviceProductID = 0;


- (BOOL)setDeviceProductString:(NSString*)string
{
	// TODO: Justin: Remove this since it isn't supported by foo-hid. Instead, we need to destroy the old device and create a new one with the updated info.
	_deviceProductString = string;
	return YES;
}

- (BOOL)setDeviceSerialNumberString:(NSString*)string
{
	// TODO: Justin: Remove this since it isn't supported by foo-hid. Instead, we need to destroy the old device and create a new one with the updated info.
	_deviceSerialNumberString = string;
	return YES;
}

- (BOOL)setDeviceVendorID:(uint32_t)vendorID productID:(uint32_t)productID
{
    char data[sizeof(uint32_t) * 2] = { 0 };

    memcpy(data, &vendorID, sizeof(uint32_t));
    memcpy(data + sizeof(uint32_t), &productID, sizeof(uint32_t));
	
	_deviceVendorID = vendorID;
	_deviceProductID = productID;
	
	// TODO: Handle this instance with foohid since we no longer user WJoy's driver
    return [self call:WJoyDeviceMethodSelectorSetDeviceVendorAndProductID
                 data:[NSData dataWithBytes:data length:sizeof(data)]];
}

- (BOOL)enable:(NSData*)HIDDescriptor
{
	// If the device already exists, we can use it right away (and foohid will error if we try to create it again)
	if([self deviceExists: _deviceProductString])
	{
		return YES;
	}
	
	// foohid requires the descriptor to be embedded with other info when sending to the IOUserClient create method
	uint32_t input_count = 8;
	uint64_t input[input_count];
	input[0] = [_deviceProductString UTF8String];
	input[1] = strlen((char *)input[0]);							// name length
	input[2] = (uint64_t) [HIDDescriptor bytes];					// report descriptor
	input[3] = [HIDDescriptor length];								// report descriptor len
	input[4] = (uint64_t) [_deviceSerialNumberString UTF8String];	// serial number
	input[5] = strlen((char *)input[4]);							// serial number len
	input[6] = (uint64_t) _deviceVendorID;							// vendor ID
	input[7] = (uint64_t) _deviceProductID;							// device ID
	
	kern_return_t ret = IOConnectCallScalarMethod(m_Connection, FOOHID_CREATE, input, input_count, NULL, 0);
	if(ret != KERN_SUCCESS)
	{
		NSLog(@"Unable to create HID device. This may be okay if the device has already been created.");
	}
	return ret == KERN_SUCCESS;
}

- (BOOL)disable
{
	// Remove the device from foohid
	uint32_t input_count = 2;
	uint64_t input[input_count];
	input[0] = (uint64_t) [_deviceProductString UTF8String];	// name pointer
	input[1] = strlen((char *)input[0]);						// name length
	
	kern_return_t ret = IOConnectCallScalarMethod(m_Connection, FOOHID_DESTROY, input, input_count, NULL, 0);
	if (ret != KERN_SUCCESS) {
		NSLog(@"Unable to remove HID device.\n");
	}
	
    return ret == KERN_SUCCESS;
}

- (BOOL)updateState:(NSData*)HIDState
{
	uint32_t send_count = 4;
	uint64_t send[send_count];
	send[0] = [_deviceProductString UTF8String];	// device name
	send[1] = strlen((char *)send[0]);				// name length
	send[2] = (uint64_t) [HIDState bytes];			// report struct
	send[3] = [HIDState length];					// report struct len
	
	kern_return_t ret = IOConnectCallScalarMethod(m_Connection, FOOHID_SEND, send, send_count, NULL, 0);
	if (ret != KERN_SUCCESS) {
		NSLog(@"Unable to send message to HID device.\n");
	}
	
	return ret == KERN_SUCCESS;
}

- (BOOL)deviceExists:(NSString*)deviceName
{
	const int inital_buffer_size = 512;
	NSMutableData *buffer = [NSMutableData dataWithCapacity:inital_buffer_size];
	[buffer setLength:inital_buffer_size];
	
	uint32_t input_count = 2;
	uint64_t input[input_count];
	input[0] = (uint64_t) [buffer mutableBytes]; // buffer pointer
	input[1] = [buffer length]; // buffer length
	
	uint32_t output_count = 2;
	uint64_t output[output_count];
	output[0] = 0;
	output[1] = 0;
	
	kern_return_t ret = IOConnectCallScalarMethod(m_Connection, FOOHID_LIST, input, input_count, output, &output_count);
	if(ret == kIOReturnNoMemory)
	{
		NSLog(@"No memory error while listing existing devices.");
		return NO;
	}
	
	if(output[0] > 0)
	{
		// We need more bytes in our buffer
		[buffer setLength:output[0]];
		input[0] = (uint64_t) [buffer mutableBytes]; // buffer pointer
		input[1] = [buffer length]; // buffer length
		ret = IOConnectCallScalarMethod(m_Connection, FOOHID_LIST, input, input_count, output, &output_count);
		if(ret == kIOReturnNoMemory)
		{
			NSLog(@"No memory error while listing existing devices.");
			return NO;
		}
	}
	
	// Loop through each name and check if this device is already listed
	const char *returnedDeviceNamePointer = [buffer bytes];
	int numberOfItemsReturned = output[1];
	for(int i = 0; i < numberOfItemsReturned; i++)
	{
		if(strcmp([deviceName UTF8String], returnedDeviceNamePointer) == 0)
		{
			// deviceName is the same as the current listed device name, so it exists
			return YES;
		}
		// Advance the pointer until we hit the next name
		while(*returnedDeviceNamePointer != '\0') returnedDeviceNamePointer++;
		returnedDeviceNamePointer++;
	}
	
	// No listed names matched, so this device does not already exist
	return NO;
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
