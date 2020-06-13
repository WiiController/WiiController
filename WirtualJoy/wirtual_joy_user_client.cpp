/*
 *  wirtual_joy_user_client.cpp
 *  wjoy
 *
 *  Created by alxn1 on 13.07.12.
 *  Copyright 2012 alxn1. All rights reserved.
 *
 */

#include "wirtual_joy.h"
#include "wirtual_joy_user_client.h"
#include "wirtual_joy_device.h"
#include "wirtual_joy_debug.h"

#define super IOUserClient

OSDefineMetaClassAndStructors(WirtualJoyUserClient, super)

const IOExternalMethodDispatch WirtualJoyUserClient::externalMethodDispatchTable[externalMethodCount] =
{
    {
        (IOExternalMethodAction) WirtualJoyUserClient::_enableDevice,
        0, kIOUCVariableStructureSize, 0, 0
    },

    {
        (IOExternalMethodAction) WirtualJoyUserClient::_disableDevice,
        0, 0, 0, 0
    },

    {
        (IOExternalMethodAction) WirtualJoyUserClient::_updateDeviceState,
        0, kIOUCVariableStructureSize, 0, 0
    },

    {
        (IOExternalMethodAction) WirtualJoyUserClient::_setDeviceProductString,
        0, kIOUCVariableStructureSize, 0, 0
    },

    {
        (IOExternalMethodAction) WirtualJoyUserClient::_setDeviceSerialNumberString,
        0, kIOUCVariableStructureSize, 0, 0
    },

    {
        (IOExternalMethodAction) WirtualJoyUserClient::_setDeviceVendorAndProductID,
        0, kIOUCVariableStructureSize, 0, 0
    }
};

static bool checkString(const char *str, size_t maxLength)
{
    while(maxLength > 0)
    {
        if(*str == 0)
            return true;

        maxLength--;
        str++;
    }

    return false;
}

IOReturn WirtualJoyUserClient::_enableDevice(WirtualJoyUserClient *target, void *reference, IOExternalMethodArguments *args)
{
    return target->enableDevice(args->structureInput, args->structureInputSize);
}

IOReturn WirtualJoyUserClient::_disableDevice(WirtualJoyUserClient *target, void *reference, IOExternalMethodArguments *args)
{
    return target->disableDevice();
}

IOReturn WirtualJoyUserClient::_updateDeviceState(WirtualJoyUserClient *target, void *reference, IOExternalMethodArguments *args)
{
    return target->updateDeviceState(args->structureInput, args->structureInputSize);
}

IOReturn WirtualJoyUserClient::_setDeviceProductString(WirtualJoyUserClient *target, void *reference, IOExternalMethodArguments *args)
{
    return target->setDeviceProductString(args->structureInput, args->structureInputSize);
}

IOReturn WirtualJoyUserClient::_setDeviceSerialNumberString(WirtualJoyUserClient *target, void *reference, IOExternalMethodArguments *args)
{
    return target->setDeviceSerialNumberString(args->structureInput, args->structureInputSize);
}

IOReturn WirtualJoyUserClient::_setDeviceVendorAndProductID(WirtualJoyUserClient *target, void *reference, IOExternalMethodArguments *args)
{
    const char *data        = static_cast< const char* >(args->structureInput);
    size_t      dataSize    = args->structureInputSize;

    if(data == 0 || dataSize < (sizeof(uint32_t) * 2))
        return kIOReturnBadArgument;

    uint32_t vendorID   = 0;
    uint32_t productID  = 0;

    memcpy(&vendorID, data, sizeof(int32_t));
    memcpy(&productID, data + sizeof(uint32_t), sizeof(uint32_t));

    return target->setDeviceVendorAndProductID(vendorID, productID);
}

bool WirtualJoyUserClient::openOwner(WirtualJoy *owner)
{
    if(owner == 0 || isInactive())
        return false;

    if(!owner->open(this))
        return false;

    _owner = owner;
    return true;
}

bool WirtualJoyUserClient::closeOwner()
{
    if(_owner != 0)
    {
        if(_owner->isOpen(this))
            _owner->close(this);

        _owner = 0;
    }

    disableDevice();
    return true;
}

bool WirtualJoyUserClient::initWithTask(
                                task_t           owningTask,
                                void            *securityToken,
                                UInt32           type,
                                OSDictionary    *properties)
{
    if(!super::initWithTask(owningTask, securityToken, type, properties))
        return false;

    _owner                     = 0;
    _device                    = 0;
    _deviceProductString       = OSString::withCString("WJoy Virtual HID Device");
    _deviceSerialNumberString  = OSString::withCString("000000000000");
    _deviceVendorID            = 0;
    _deviceProductID           = 0;

    dmsg("initWithTask");
    return true;
}

void WirtualJoyUserClient::free()
{
    if(_deviceProductString != 0)
        _deviceProductString->release();

    if(_deviceSerialNumberString != 0)
        _deviceSerialNumberString->release();

    dmsg("free");
    super::free();
}

bool WirtualJoyUserClient::start(IOService *provider)
{
    WirtualJoy *owner = OSDynamicCast(WirtualJoy, provider);
    if(owner == 0)
        return false;

    if(!super::start(provider))
        return false;

    if(!openOwner(owner))
    {
        super::stop(provider);
        return false;
    }

    dmsgf("start, provider: %p", provider);
    return true;
}

void WirtualJoyUserClient::stop(IOService *provider)
{
    dmsgf("stop, provider: %p", provider);
    closeOwner();
    super::stop(provider);
}

IOReturn WirtualJoyUserClient::clientClose()
{
    dmsg("clientClose");
    closeOwner();
    terminate();
    return kIOReturnSuccess;
}

bool WirtualJoyUserClient::didTerminate(IOService *provider, IOOptionBits options, bool *defer)
{
    dmsg("didTerminate");
    closeOwner();
	*defer = false;
	return super::didTerminate(provider, options, defer);
}

IOReturn WirtualJoyUserClient::externalMethod(
                                    uint32_t                     selector,
                                    IOExternalMethodArguments   *arguments,
									IOExternalMethodDispatch    *dispatch,
                                    OSObject                    *target,
                                    void                        *reference)
{
    dmsg("externalMehtod");

    if(selector < externalMethodCount)
    {
        dispatch = const_cast< IOExternalMethodDispatch* >(&externalMethodDispatchTable[selector]);
        if(target == 0)
            target = this;
    }
        
	return super::externalMethod(selector, arguments, dispatch, target, reference);
}

IOReturn WirtualJoyUserClient::enableDevice(const void *hidDescriptorData, uint32_t hidDescriptorDataSize)
{
    dmsgf("enableDevice, param size = %d", hidDescriptorDataSize);

    if(_device != 0)
    {
        IOReturn result = disableDevice();
        if(result != kIOReturnSuccess)
            return result;
    }

    _device = WirtualJoyDevice::withHidDescriptor(
                                            hidDescriptorData,
                                            hidDescriptorDataSize,
                                            _deviceProductString,
                                            _deviceSerialNumberString,
                                            _deviceVendorID,
                                            _deviceProductID);

    if(_device == 0)
        return kIOReturnDeviceError;

    if(!_device->attach(this))
    {
        _device->release();
        _device = 0;
        return kIOReturnDeviceError;
    }

    if(!_device->start(this))
    {
        _device->detach(this);
        _device->release();
        _device = 0;
        return kIOReturnDeviceError;
    }

    return kIOReturnSuccess;
}

IOReturn WirtualJoyUserClient::disableDevice()
{
    dmsg("disableDevice");

    if(_device != 0)
    {
        _device->terminate(kIOServiceRequired);
        _device->release();
        _device = 0;
    }

    return kIOReturnSuccess;
}

IOReturn WirtualJoyUserClient::updateDeviceState(const void *hidData, uint32_t hidDataSize)
{
    // dmsgf("updateDeviceState, param size = %d", hidDataSize);

    if(_device == 0)
        return kIOReturnNoDevice;

    if(!_device->updateState(hidData, hidDataSize))
        return kIOReturnDeviceError;

    return kIOReturnSuccess;
}

IOReturn WirtualJoyUserClient::setDeviceProductString(const void *productString, uint32_t productStringSize)
{
    dmsgf("setDeviceProductString, productString size = %d", productStringSize);

    if(_device != 0)
        return kIOReturnBusy;

    if(!checkString(static_cast< const char* >(productString), productStringSize))
        return kIOReturnInvalid;

    OSString *newStr = OSString::withCString(static_cast< const char* >(productString));
    if(newStr == 0)
        return kIOReturnNoMemory;

    if(_deviceProductString != 0)
        _deviceProductString->release();

    _deviceProductString = newStr;

    dmsgf("newProductString = %s", newStr->getCStringNoCopy());
    return kIOReturnSuccess;
}

IOReturn WirtualJoyUserClient::setDeviceSerialNumberString(const void *serialNumberString, uint32_t serialNumberStringSize)
{
    dmsgf("setDeviceSerialNumberString, serialNumberString size = %d", serialNumberStringSize);

    if(_device != 0)
        return kIOReturnBusy;

    if(!checkString(static_cast< const char* >(serialNumberString), serialNumberStringSize))
        return kIOReturnInvalid;

    OSString *newStr = OSString::withCString(static_cast< const char* >(serialNumberString));
    if(newStr == 0)
        return kIOReturnNoMemory;

    if(_deviceSerialNumberString != 0)
        _deviceSerialNumberString->release();

    _deviceSerialNumberString = newStr;

    dmsgf("newSerialNumberString = %s", newStr->getCStringNoCopy());
    return kIOReturnSuccess;
}

IOReturn WirtualJoyUserClient::setDeviceVendorAndProductID(uint32_t vendorID, uint32_t productID)
{
    dmsgf("setDeviceVendorAndProductID, vendorID = %d, productID = %d", vendorID, productID);

    if(_device != 0)
        return kIOReturnBusy;

    _deviceVendorID    = vendorID;
    _deviceProductID   = productID;

    return kIOReturnSuccess;
}
