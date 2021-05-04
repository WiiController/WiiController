//
//  WJoyTool.m
//  driver
//
//  Created by alxn1 on 17.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

// TODO: We should eventually switch over to launchd and ServiceManagement.framework, which would allow us to stop using AuthorizationExecuteWithPrivileges.

#import "WJoyTool.h"
#import "WJoyToolInterface.h"
#import "WJoyAdminToolRight.h"
#import "STPrivilegedTask.h"

#define WJoyDeviceDriverName @"wjoy.kext"

static NSBundle *wirtualJoyBundle(void)
{
    return [NSBundle bundleForClass:[WJoyTool class]];
}

static NSString *toolPath(void)
{
    return [[wirtualJoyBundle() resourcePath] stringByAppendingPathComponent:WJoyToolName];
}

static NSString *driverPath(void)
{
    return [[wirtualJoyBundle() resourcePath] stringByAppendingPathComponent:WJoyDeviceDriverName];
}

/// Attempts to run WJoyTool as root, given @c arguments.
/// Prompts the user for admin permission first.
static BOOL runToolWithArguments(NSArray<NSString *> *arguments)
{
    STPrivilegedTask *task = [[STPrivilegedTask alloc] init];

    [task setLaunchPath:toolPath()];
    [task setArguments:arguments];
    OSStatus err = [task launch];
    if (err != errAuthorizationSuccess)
    {
        return NO;
    }

    [task waitUntilExit];

    BOOL result = ([task terminationStatus] == EXIT_SUCCESS);

    return result;
}

static BOOL actuallyRunLoadOrUnloadToolCommand(NSString *command)
{
    return runToolWithArguments(@[ command, driverPath() ]);
}

/// Attempts to run the tool's self-repair action (`WJoyToolRepairRightsCommand`).
static BOOL runSelfRepairToolCommand(void)
{
    return runToolWithArguments(@[ WJoyToolRepairRightsCommand ]);
}

/// Attempts to run load or unload @c command.
static BOOL runLoadOrUnloadToolCommand(NSString *command)
{
    if (actuallyRunLoadOrUnloadToolCommand(command))
        return YES;

    if (!runSelfRepairToolCommand())
        return NO;

    return actuallyRunLoadOrUnloadToolCommand(command);
}

@implementation WJoyTool

+ (BOOL)loadDriver
{
    return runLoadOrUnloadToolCommand(WJoyToolLoadDriverCommand);
}

+ (BOOL)unloadDriver
{
    // This was patched out a long time ago, for macOS 10.8.
    // I don't know exactly why.
    return YES;
}

@end
