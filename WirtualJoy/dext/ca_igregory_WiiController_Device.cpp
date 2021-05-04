//
//  Service.cpp
//  wiicontroller
//
//  Created by Ian Gregory on 30 Apr ’21.
//

#include <os/log.h>

#include <DriverKit/IOUserServer.h>
#include <DriverKit/IOLib.h>
#include <DriverKit/IOBufferMemoryDescriptor.h>
#include <HIDDriverKit/IOHIDUsageTables.h>
#include <HIDDriverKit/IOHIDDeviceKeys.h>
#include <DriverKit/OSString.h>
#include <DriverKit/OSNumber.h>
#include <DriverKit/OSData.h>
#include <DriverKit/OSDictionary.h>
#include <DriverKit/OSBoolean.h>

#include "ca_igregory_WiiController_Device.h"

namespace {

kern_return_t createBufferMemoryDescriptorWithCapacity(uint64_t capacity, uint64_t options, IOBufferMemoryDescriptor **descriptor) {
    IOBufferMemoryDescriptor *result;
    auto ret = IOBufferMemoryDescriptor::Create(options, capacity, 0, &result);
    if (ret != kIOReturnSuccess) return ret;
    
    ret = result->SetLength(capacity);
    if (ret != kIOReturnSuccess)
    {
        result->release();
        return ret;
    }
    
    *descriptor = result;
    return kIOReturnSuccess;
}
kern_return_t createBufferMemoryDescriptorWithBytes(void const *bytes, uint64_t length, uint64_t options, IOBufferMemoryDescriptor **descriptor) {
    IOBufferMemoryDescriptor *result;
    auto ret = createBufferMemoryDescriptorWithCapacity(length, options, &result);
    if (ret != kIOReturnSuccess) return ret;
    
    IOAddressSegment range;
    ret = result->GetAddressRange(&range);
    if (ret != kIOReturnSuccess)
    {
        result->release();
        return ret;
    }
    
    memcpy((void *)range.address, bytes, range.length);
    
    *descriptor = result;
    return kIOReturnSuccess;
}
kern_return_t createBufferMemoryDescriptorWithZeros(uint64_t length, uint64_t options, IOBufferMemoryDescriptor **descriptor) {
    IOBufferMemoryDescriptor *result;
    auto ret = createBufferMemoryDescriptorWithCapacity(length, options, &result);
    if (ret != kIOReturnSuccess) return ret;
    
    IOAddressSegment range;
    ret = result->GetAddressRange(&range);
    if (ret != kIOReturnSuccess)
    {
        OSSafeReleaseNULL(result);
        return ret;
    }
    
    memset((void *)range.address, 0, range.length);
    
    *descriptor = result;
    return kIOReturnSuccess;
}

// Generated from:
// [[[[VHIDDevice alloc] initWithType:VHIDDeviceTypeJoystick pointerCount:3 buttonCount:26 isRelative:NO] descriptor] writeToFile:@"/some/path/JoyHIDDescriptor" atomically:YES];
// xxd -i /some/path/JoyHIDDescriptor
constexpr unsigned char defaultJoystickReportDescriptorData[] = {
  0x05, 0x01, 0x09, 0x05, 0xa1, 0x01, 0xa1, 0x00, 0x05, 0x09, 0x19, 0x01,
  0x29, 0x1a, 0x15, 0x00, 0x25, 0x01, 0x95, 0x1a, 0x75, 0x01, 0x81, 0x02,
  0x95, 0x01, 0x75, 0x06, 0x81, 0x03, 0x05, 0x01, 0x09, 0x30, 0x09, 0x31,
  0x09, 0x32, 0x09, 0x33, 0x09, 0x34, 0x09, 0x35, 0x15, 0x81, 0x25, 0x7f,
  0x75, 0x08, 0x95, 0x06, 0x81, 0x02, 0xc0, 0xc0
};
OSData *defaultJoystickReportDescriptor(void) {
    return OSData::withBytes(defaultJoystickReportDescriptorData, sizeof(defaultJoystickReportDescriptorData));
}

constexpr uint32_t locationIdBase = 0xFAFAFAFA;

} // namespace

struct ca_igregory_WiiController_Device_IVars {
    // Must never be null.
    OSString *_productString;
    // Must never be null.
    OSString *_serialNumberString;
    
    uint32_t  _vendorID;
    uint32_t  _productID;
    
    uint64_t _reportByteLength;
    IOBufferMemoryDescriptor *_hidReportDescriptor;
    IOBufferMemoryDescriptor *_stateBuffer;
    
    uint32_t  _locationID;
};

bool
ca_igregory_WiiController_Device::init()
{
    if (!super::init()) return false;
    ivars = IONewZero(ca_igregory_WiiController_Device_IVars, 1);
    if (!ivars) return false;
    
    ivars->_productString = OSString::withCString("");
    ivars->_serialNumberString = OSString::withCString("");
    
    return true;
}

void
ca_igregory_WiiController_Device::free()
{
    if (ivars->_productString) ivars->_productString->release();
    if (ivars->_serialNumberString) ivars->_serialNumberString->release();
    if (ivars->_hidReportDescriptor) ivars->_hidReportDescriptor->release();
    if (ivars->_stateBuffer) ivars->_stateBuffer->release();
    super::free();
}

// LOCALONLY
OSDictionary *
ca_igregory_WiiController_Device::newDeviceDescription()
{
    struct KV {
        char const *key;
        OSObject *value;
    } kvs[] = {
        {
            kIOHIDTransportKey,
            OSString::withCString("Virtual")
        },
        {
            kIOHIDManufacturerKey,
            OSString::withCString("WiiController")
        },
        {
            kIOHIDVersionNumberKey,
            OSNumber::withNumber(1, 8 * sizeof(1))
        },
        
        {
            kIOHIDProductKey,
            OSString::withString(ivars->_productString)
        },
        {
            kIOHIDSerialNumberKey,
            OSString::withString(ivars->_serialNumberString)
        },
        
        {
            kIOHIDVendorIDKey,
            OSNumber::withNumber(ivars->_vendorID, 8 * sizeof(ivars->_vendorID))
        },
        {
            kIOHIDProductIDKey,
            OSNumber::withNumber(ivars->_productID, 8 * sizeof(ivars->_productID))
        },
        {
            kIOHIDLocationIDKey,
            OSNumber::withNumber(ivars->_locationID, 8 * sizeof(ivars->_locationID))
        },
        
        {
            "RegisterService",
            kOSBooleanTrue
        }
    };
    auto numKVs = sizeof(kvs) / sizeof(KV);
    
    auto description = OSDictionary::withCapacity(static_cast<uint32_t>(numKVs));
    for (int i = 0; i < numKVs; i++) {
        auto [key, value] = kvs[i];
        description->setObject(key, value);
        value->release();
    }
    
    return description;
}

// LOCALONLY
OSData *
ca_igregory_WiiController_Device::newReportDescriptor()
{
    if (!ivars->_hidReportDescriptor) return defaultJoystickReportDescriptor();
    
    IOAddressSegment range;
    auto ret = ivars->_hidReportDescriptor->GetAddressRange(&range);
    if (ret != kIOReturnSuccess) return defaultJoystickReportDescriptor();
    
    return OSData::withBytes((void *)range.address, range.length);
}

// Called by user client.
static kern_return_t
initDevice(
    ca_igregory_WiiController_Device_IVars *ivars,
    void const *hidDescriptorData,
    size_t      hidDescriptorDataSize,
    OSString   *productString,
    OSString   *serialNumberString,
    uint32_t    vendorID,
    uint32_t    productID
) {
    ivars->_vendorID = vendorID;
    ivars->_productID = productID;
    
    if (!productString || !hidDescriptorData) return kIOReturnBadArgument;
    
    if (ivars->_hidReportDescriptor) ivars->_hidReportDescriptor->release();
    auto ret = createBufferMemoryDescriptorWithBytes(hidDescriptorData, hidDescriptorDataSize, kIOMemoryDirectionOutIn, &ivars->_hidReportDescriptor);
    if (ret != kIOReturnSuccess) return ret;
    
    // 64 bytes is a sensible default.
    // updateState() increases the length later if needed.
    if (ivars->_stateBuffer) ivars->_stateBuffer->release();
    ret = createBufferMemoryDescriptorWithZeros(64, kIOMemoryDirectionOutIn, &ivars->_stateBuffer);
    if (ret != kIOReturnSuccess) return ret;
    
    {
        static uint32_t lastId = locationIdBase;
        
        lastId++;
        ivars->_locationID = lastId;
    }
    
    if (ivars->_productString) ivars->_productString->release();
    ivars->_productString = productString;
    if (ivars->_serialNumberString) ivars->_serialNumberString->release();
    ivars->_serialNumberString = serialNumberString;
    
    productString->retain();
    serialNumberString->retain();
    
    return kIOReturnSuccess;
}

ca_igregory_WiiController_Device*
ca_igregory_WiiController_Device::withHidDescriptor(
    IOService *provider,
    const void *hidDescriptorData,
    size_t hidDescriptorDataSize,
    OSString *productString,
    OSString *serialNumberString,
    uint32_t vendorID,
    uint32_t productID
) {
    IOService *newService;
    auto ret = provider->Create(provider, "DeviceProperties", &newService);
    if (ret != kIOReturnSuccess) return nullptr;
    
    auto device = OSRequiredCast(ca_igregory_WiiController_Device, newService);
    
    ret = ::initDevice(device->ivars, hidDescriptorData, hidDescriptorDataSize, productString, serialNumberString, vendorID, productID);
    if (ret != kIOReturnSuccess)
    {
        device->release();
        return nullptr;
    }
    
    return device;
}

// Called by/via user client.
bool
ca_igregory_WiiController_Device::updateState(const void *hidData, size_t hidDataSize)
{
    if (!ivars->_stateBuffer) return false;
    
    // Copy to _stateBuffer:
    IOAddressSegment range;
    auto ret = ivars->_stateBuffer->GetAddressRange(&range);
    if (ret != kIOReturnSuccess) return false;
    
    if (range.length < hidDataSize) {
        ret = ivars->_stateBuffer->SetLength(hidDataSize);
        if (ret != kIOReturnSuccess) return false;
        ret = ivars->_stateBuffer->GetAddressRange(&range);
        if (ret != kIOReturnSuccess) return false;
    }
    
    memcpy((void *)range.address, hidData, hidDataSize);
    
    // Dispatch event(s):
    ret = handleReport(mach_absolute_time(), ivars->_stateBuffer, static_cast<uint32_t>(hidDataSize), kIOHIDReportTypeInput, 0);
    return (ret == kIOReturnSuccess);
}
