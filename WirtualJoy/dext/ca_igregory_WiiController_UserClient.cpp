//
//  UserClient.cpp
//  wiicontroller
//
//  Created by Ian Gregory on 30 Apr ’21.
//

#include <os/log.h>

#include <DriverKit/IOUserServer.h>
#include <DriverKit/IOLib.h>
#include <DriverKit/OSString.h>
#include <DriverKit/OSData.h>

#include "ca_igregory_WiiController_UserClient.h"
#include "ca_igregory_WiiController.h"
#include "ca_igregory_WiiController_Device.h"

struct ca_igregory_WiiController_UserClient_IVars {
    ca_igregory_WiiController_Device *_device;
    OSString *_deviceProductString;
    OSString *_deviceSerialNumberString;
    uint32_t _deviceVendorID;
    uint32_t _deviceProductID;
};

static constexpr size_t externalMethodCount = 6;
// See DriverKit/IOUserClient.h for more about these fields.
// We index into this array in ExternalMethod() to set up the appropriate
// external method dispatch.
static const IOUserClientMethodDispatch externalMethodDispatchTable[externalMethodCount] =
{
    {
        (IOUserClientMethodFunction)ca_igregory_WiiController_UserClient::_enableDevice,
        0, // Whether a callback is allowed/required (0 = not allowed, 1 = required, -1 = don't care)
        0, // Number of scalar inputs
        kIOUserClientVariableStructureSize, // Size of structure input
        0, // Number of scalar outputs
        0 // Size of structure output
    },
    
    {
        (IOUserClientMethodFunction)ca_igregory_WiiController_UserClient::_disableDevice,
        0, 0, 0, 0, 0
    },
    
    {
        (IOUserClientMethodFunction)ca_igregory_WiiController_UserClient::_updateDeviceState,
        0, 0, kIOUserClientVariableStructureSize, 0, 0
    },
    
    {
        (IOUserClientMethodFunction)ca_igregory_WiiController_UserClient::_setDeviceProductString,
        0, 0, kIOUserClientVariableStructureSize, 0, 0
    },
    
    {
        (IOUserClientMethodFunction)ca_igregory_WiiController_UserClient::_setDeviceSerialNumberString,
        0, 0, kIOUserClientVariableStructureSize, 0, 0
    },
    
    {
        (IOUserClientMethodFunction)ca_igregory_WiiController_UserClient::_setDeviceVendorAndProductID,
        0, 0, kIOUserClientVariableStructureSize, 0, 0
    }
};

static bool checkString(const char *str, size_t maxLength)
{
    while(maxLength > 0)
    {
        if (*str == 0) return true;

        maxLength--;
        str++;
    }
    
    return false;
}

kern_return_t ca_igregory_WiiController_UserClient::_enableDevice(ca_igregory_WiiController_UserClient *target, void *reference, IOUserClientMethodArguments *args)
{
    return target->enableDevice(args->structureInput);
}

kern_return_t ca_igregory_WiiController_UserClient::_disableDevice(ca_igregory_WiiController_UserClient *target, void *reference, IOUserClientMethodArguments *args)
{
    return target->disableDevice();
}

kern_return_t ca_igregory_WiiController_UserClient::_updateDeviceState(ca_igregory_WiiController_UserClient *target, void *reference, IOUserClientMethodArguments *args)
{
    return target->updateDeviceState(args->structureInput);
}

kern_return_t ca_igregory_WiiController_UserClient::_setDeviceProductString(ca_igregory_WiiController_UserClient *target, void *reference, IOUserClientMethodArguments *args)
{
    return target->setDeviceProductString(args->structureInput);
}

kern_return_t ca_igregory_WiiController_UserClient::_setDeviceSerialNumberString(ca_igregory_WiiController_UserClient *target, void *reference, IOUserClientMethodArguments *args)
{
    return target->setDeviceSerialNumberString(args->structureInput);
}

kern_return_t ca_igregory_WiiController_UserClient::_setDeviceVendorAndProductID(ca_igregory_WiiController_UserClient *target, void *reference, IOUserClientMethodArguments *args)
{
    auto data = args->structureInput;
    if (!data || !data->getBytesNoCopy() || data->getLength() < 2 * sizeof(uint32_t)) return kIOReturnBadArgument;
    auto u32s = static_cast<uint32_t const*>(data->getBytesNoCopy());
    
    uint32_t vendorID = u32s[0];
    uint32_t productID = u32s[1];
    return target->setDeviceVendorAndProductID(vendorID, productID);
}

bool
ca_igregory_WiiController_UserClient::init()
{
    os_log(OS_LOG_DEFAULT, "Hello world!");
    if (!super::init()) return false;
    ivars = IONewZero(ca_igregory_WiiController_UserClient_IVars, 1);
    if (!ivars) return false;
    
    ivars->_device = nullptr;
    ivars->_deviceProductString = OSString::withCString("WiiController Virtual HID Device");
    ivars->_deviceSerialNumberString = OSString::withCString("000000000000");
    ivars->_deviceVendorID = 0;
    ivars->_deviceProductID = 0;

    return true;
}

void
ca_igregory_WiiController_UserClient::free()
{
    if (ivars->_deviceProductString) ivars->_deviceProductString->release();
    if (ivars->_deviceSerialNumberString) ivars->_deviceSerialNumberString->release();
    
    IODelete(ivars, ca_igregory_WiiController_UserClient_IVars, 1);
    super::free();
}

kern_return_t
IMPL(ca_igregory_WiiController_UserClient, Start)
{
    auto ret = Start(provider, SUPERDISPATCH);
    if (ret != kIOReturnSuccess) return ret;
    
    os_log(OS_LOG_DEFAULT, "User client Start");
    return kIOReturnSuccess;
}

kern_return_t
IMPL(ca_igregory_WiiController_UserClient, Stop)
{
    os_log(OS_LOG_DEFAULT, "User client Stop");
    return Stop(provider, SUPERDISPATCH);
}

// LOCALONLY
kern_return_t
ca_igregory_WiiController_UserClient::ExternalMethod(
    uint64_t selector,
    IOUserClientMethodArguments *arguments,
    IOUserClientMethodDispatch const *dispatch,
    OSObject *target,
    void *reference
) {
    if (selector < externalMethodCount)
    {
        dispatch = const_cast<IOUserClientMethodDispatch*>(&externalMethodDispatchTable[selector]);
        if (!target) target = this;
    }
    
    return super::ExternalMethod(selector, arguments, dispatch, target, reference);
}

// MARK: External methods

kern_return_t
ca_igregory_WiiController_UserClient::enableDevice(OSData *hidDescriptorData)
{
    if (ivars->_device)
    {
        auto ret = disableDevice();
        if (ret != kIOReturnSuccess) return ret;
    }
    
    if (!hidDescriptorData || !hidDescriptorData->getBytesNoCopy()) return kIOReturnBadArgument;
    
    ivars->_device = ca_igregory_WiiController_Device::withHidDescriptor(
        this,
        hidDescriptorData->getBytesNoCopy(),
        hidDescriptorData->getLength(),
        ivars->_deviceProductString,
        ivars->_deviceSerialNumberString,
        ivars->_deviceVendorID,
        ivars->_deviceProductID
    );
    if (!ivars->_device) return kIOReturnDeviceError;
    
    auto ret = ivars->_device->Start(this);
    if (ret != kIOReturnSuccess)
    {
        ivars->_device->release();
        ivars->_device = nullptr;
        return ret;
    }

    return kIOReturnSuccess;
}

kern_return_t ca_igregory_WiiController_UserClient::disableDevice()
{
    if (ivars->_device)
    {
        ivars->_device->Terminate(0);
        ivars->_device->release();
        ivars->_device = nullptr;
    }
    return kIOReturnSuccess;
}

kern_return_t
ca_igregory_WiiController_UserClient::updateDeviceState(OSData *hidReportData)
{
    if (!ivars->_device) return kIOReturnNoDevice;
    if (!hidReportData || !hidReportData->getBytesNoCopy()) return kIOReturnBadArgument;
    if (!ivars->_device->updateState(hidReportData->getBytesNoCopy(), hidReportData->getLength())) return kIOReturnDeviceError;
    return kIOReturnSuccess;
}

kern_return_t ca_igregory_WiiController_UserClient::setDeviceProductString(OSData *productStringData)
{
    if (ivars->_device) return kIOReturnBusy;
    if (!productStringData || !productStringData->getBytesNoCopy()) return kIOReturnBadArgument;
    
    if (!checkString(static_cast<char const*>(productStringData->getBytesNoCopy()), productStringData->getLength())) return kIOReturnBadArgument;
    
    OSString *newStr = OSString::withCString(static_cast<char const*>(productStringData->getBytesNoCopy()));
    if (!newStr) return kIOReturnNoMemory;
    
    if (ivars->_deviceProductString) ivars->_deviceProductString->release();
    ivars->_deviceProductString = newStr;
    
    return kIOReturnSuccess;
}

kern_return_t ca_igregory_WiiController_UserClient::setDeviceSerialNumberString(OSData *serialNumberStringData)
{
    if (ivars->_device) return kIOReturnBusy;
    if (!serialNumberStringData || !serialNumberStringData->getBytesNoCopy()) return kIOReturnBadArgument;
    
    if (!checkString(static_cast<char const*>(serialNumberStringData->getBytesNoCopy()), serialNumberStringData->getLength())) return kIOReturnBadArgument;
    
    OSString *newStr = OSString::withCString(static_cast<char const*>(serialNumberStringData->getBytesNoCopy()));
    if (!newStr) return kIOReturnNoMemory;
    
    if (ivars->_deviceSerialNumberString) ivars->_deviceSerialNumberString->release();
    ivars->_deviceSerialNumberString = newStr;
    
    return kIOReturnSuccess;
}

kern_return_t ca_igregory_WiiController_UserClient::setDeviceVendorAndProductID(uint32_t vendorID, uint32_t productID)
{
    if (ivars->_device) return kIOReturnBusy;
    
    ivars->_deviceVendorID = vendorID;
    ivars->_deviceProductID = productID;
    
    return kIOReturnSuccess;
}

