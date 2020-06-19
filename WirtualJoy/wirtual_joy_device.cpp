/*
 *  wirtual_joy_device.cpp
 *  wjoy
 *
 *  Created by alxn1 on 13.07.12.
 *  Copyright 2012 alxn1. All rights reserved.
 *
 */

#include "wirtual_joy_device.h"
#include "wirtual_joy_debug.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#include <IOKit/usb/IOUSBHostHIDDevice.h>
#pragma clang diagnostic pop

#define super IOHIDDevice
#define kMaxHIDReportSize 256

OSDefineMetaClassAndStructors(WirtualJoyDevice, super)

bool WirtualJoyDevice::parseHidDescriptor(
                                const void *hidDescriptorData,
                                size_t      hidDescriptorDataSize)
{
    HIDPreparsedDataRef preparsedDataRef = 0;

    if(HIDOpenReportDescriptor(
                         const_cast< void* >(hidDescriptorData),
                         hidDescriptorDataSize,
                        &preparsedDataRef, 0) != kIOReturnSuccess)
    {
        return false;
    }

    bool result = (HIDGetCapabilities(preparsedDataRef, &_capabilities) == kIOReturnSuccess);
    HIDCloseReportDescriptor(preparsedDataRef);
    return result;
}

WirtualJoyDevice *WirtualJoyDevice::withHidDescriptor(
                                const void *hidDescriptorData,
                                size_t      hidDescriptorDataSize,
                                OSString   *productString,
                                OSString   *serialNumberString,
                                uint32_t    vendorID,
                                uint32_t    productID)
{
    WirtualJoyDevice *result = new WirtualJoyDevice();

    if(result != 0)
    {
        if(!result->init(hidDescriptorData, hidDescriptorDataSize, productString, serialNumberString, vendorID, productID))
        {
            result->release();
            result = 0;
        }
    }

    return result;
}

bool WirtualJoyDevice::init(
                const void      *hidDescriptorData,
                size_t           hidDescriptorDataSize,
                OSString        *productString,
                OSString        *serialNumberString,
                uint32_t         vendorID,
                uint32_t         productID,
                OSDictionary    *dictionary)
{
    _productString         = 0;
    _serialNumberString    = 0;
    _vendorID              = vendorID;
    _productID             = productID;
    _hIDReportDescriptor   = 0;
    _stateBuffer           = 0;

    if(productString     == 0 ||
       hidDescriptorData == 0)
    {
        return false;
    }

    if(!super::init(dictionary))
        return false;

    if(!parseHidDescriptor(hidDescriptorData, hidDescriptorDataSize))
        return false;

// NOTE: Apple Removed #def kMaxHIDReportSize in OS X 10.10.3 so we aren't going to check size.
// Comment from Ian: According to this archived CVS commit from 2002,
// this is apparently "only an initial value, not a limit!"
// https://www.mail-archive.com/cvs-log-iousbfamily@opensource.apple.com/msg00000.html
// Hardly definitive, but considering it's been removed we're probably fine.
//    if(_capabilities.inputReportByteLength > kMaxHIDReportSize)
//        return false;

    if(_capabilities.usagePage == kHIDPage_GenericDesktop)
    {
       if(_capabilities.usage == kHIDUsage_GD_Mouse ||
          _capabilities.usage == kHIDUsage_GD_Keyboard)
        {
            // hack for Apple HID subsystem
            // Comment from Ian: I have little idea what this does,
            // practically speaking; but tons of Apple's and other open-source
            // driver code sets it. That said, sometimes it's a string,
            // sometimes it's empty string, and sometimes it's boolean true...
            // but eh, it's not causing any harm (that I'm aware of).
            OSString *str = OSString::withCString(
                                        (_capabilities.usage == kHIDUsage_GD_Mouse)?
                                            ("Mouse"):
                                            ("Keyboard"));

            if(str == NULL)
                return false;

            if(!setProperty("HIDDefaultBehavior", str))
            {
                str->release();
                return false;
            }

            str->release();
        }
    }

    _hIDReportDescriptor = IOBufferMemoryDescriptor::withBytes(
                                                        hidDescriptorData,
                                                        hidDescriptorDataSize,
                                                        kIODirectionInOut);

    if(_hIDReportDescriptor == 0)
        return false;

    _stateBuffer = IOBufferMemoryDescriptor::withCapacity(
                                                _capabilities.inputReportByteLength,
                                                kIODirectionInOut);

    if(_stateBuffer == 0)
        return false;

    memset(_stateBuffer->getBytesNoCopy(), 0, _stateBuffer->getLength());

    {
        static uint32_t lastId = locationIdBase;

        lastId++;
        _locationID = lastId;
    }

    _productString         = productString;
    _serialNumberString    = serialNumberString;

    _serialNumberString->retain();
    _productString->retain();

    dmsg("init");
    return true;
}

IOReturn WirtualJoyDevice::newReportDescriptor(IOMemoryDescriptor **descriptor) const
{
    IOBufferMemoryDescriptor *result = IOBufferMemoryDescriptor::withBytes(
                                                                    _hIDReportDescriptor->getBytesNoCopy(),
                                                                    _hIDReportDescriptor->getLength(),
                                                                    kIODirectionInOut);

    if(result == 0)
        return kIOReturnError;

    *descriptor = result;
	return kIOReturnSuccess;
}

OSString *WirtualJoyDevice::newTransportString() const
{
	return OSString::withCString("Virtual");
}

OSString *WirtualJoyDevice::newManufacturerString() const
{
    return OSString::withCString("alxn1");
}

OSString *WirtualJoyDevice::newProductString() const
{
    return OSString::withString(_productString);
}

OSString *WirtualJoyDevice::newSerialNumberString() const
{
	return OSString::withString(_serialNumberString);
}

OSNumber *WirtualJoyDevice::newVersionNumber() const
{
	return OSNumber::withNumber(1, 32);
}

OSNumber *WirtualJoyDevice::newSerialNumber() const
{
	uint32_t number = 0;
	return OSNumber::withNumber(number, 32);
}

OSNumber *WirtualJoyDevice::newVendorIDNumber() const
{
	return OSNumber::withNumber(_vendorID, 32);
}

OSNumber *WirtualJoyDevice::newProductIDNumber() const
{
	return OSNumber::withNumber(_productID, 32);
}

OSNumber *WirtualJoyDevice::newPrimaryUsageNumber() const
{
    return OSNumber::withNumber(_capabilities.usage, 32);
}

OSNumber *WirtualJoyDevice::newPrimaryUsagePageNumber() const
{
    return OSNumber::withNumber(_capabilities.usagePage, 32);
}

OSNumber *WirtualJoyDevice::newLocationIDNumber() const
{
    return OSNumber::withNumber(_locationID, 32);
}

OSNumber *WirtualJoyDevice::newVendorIDSourceNumber() const
{
	uint32_t number = 0;
	return OSNumber::withNumber(number, 32);
}

OSNumber *WirtualJoyDevice::newCountryCodeNumber() const
{
	uint32_t number = 0;
	return OSNumber::withNumber(number, 32);
}

bool WirtualJoyDevice::updateState(const void *hidData, size_t hidDataSize)
{
    if(_stateBuffer->getLength() != hidDataSize)
        return false;

    memcpy(_stateBuffer->getBytesNoCopy(), hidData, hidDataSize);
    return (handleReport(_stateBuffer) == kIOReturnSuccess);
}

void WirtualJoyDevice::free()
{
    if(_productString != 0)
        _productString->release();

    if(_serialNumberString != 0)
        _serialNumberString->release();

    if(_hIDReportDescriptor != 0)
        _hIDReportDescriptor->release();

    if(_stateBuffer != 0)
        _stateBuffer->release();

    dmsg("free");
    super::free();
}
