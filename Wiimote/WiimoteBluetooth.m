//
//  WiimoteBluetooth.m
//  Wiimote
//
//  Created by Ian Gregory on 2 May ’21.
//

#import "WiimoteBluetooth.h"

#import <IOBluetooth/IOBluetooth.h>

BOOL wiimoteIsBluetoothEnabled(void)
{
    return ([IOBluetoothHostController defaultController].powerState == kBluetoothHCIPowerStateON);
}
