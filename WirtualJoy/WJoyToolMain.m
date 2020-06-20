//
//  WJoyToolMain.m
//  driver
//
//  Created by alxn1 on 17.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WJoyToolInterface.h"

#import <sys/stat.h>
#import <IOKit/kext/KextManager.h>

typedef enum {
    WorkModeRepairRights,
    WorkModeLoadDriver,
    WorkModeUnloadDriver,
    WorkModeError
} WorkMode;

#define KEXTLoadCommand     "/sbin/kextload"
#define KEXTUnloadCommand   "/sbin/kextunload"

static int repairRights(const char *path) {
    if (seteuid(0) != 0)
        return EXIT_FAILURE;

    if (chmod(path, 04755) != 0)
        return EXIT_FAILURE;

    if (chown(path, 0, 0) != 0)
        return EXIT_FAILURE;

    return EXIT_SUCCESS;
}

static int doCommandWithPath(const char *cmd, const char *path) {
    NSString *command = [NSString stringWithFormat:@"%@ \"%@\"",
                                                   [NSString stringWithUTF8String:cmd],
                                                   [NSString stringWithUTF8String:path]];

    return system([command UTF8String]);
}

static BOOL repairDriverRights(const char *path) {
    return doCommandWithPath("chown -R root:wheel", path) == EXIT_SUCCESS;
}

static int loadDriver(const char *path) {
    if (seteuid(0) != 0 || setuid(0) != 0)
        return EXIT_FAILURE;

    if (!repairDriverRights(path))
        return EXIT_FAILURE;

    OSReturn result = KextManagerLoadKextWithURL(
        (__bridge CFURLRef)[NSURL fileURLWithPath:[NSString stringWithUTF8String:path]],
        NULL
    );

    if (result == kOSReturnSuccess) {
        return EXIT_SUCCESS;
    }

    return EXIT_FAILURE;
}

static int unloadDriver(const char *path) {
    if (seteuid(0) != 0 || setuid(0) != 0)
        return EXIT_FAILURE;

    if (!repairDriverRights(path))
        return EXIT_FAILURE;

    return doCommandWithPath(KEXTUnloadCommand, path);
}

static WorkMode parseCommandLine(int argC, char *argV[]) {
    if (argC != 2 && argC != 3)
        return WorkModeError;

    if (strcmp([WJoyToolRepairRightsCommand UTF8String], argV[1]) == 0) {
        if (argC == 3)
            return WorkModeError;

        return WorkModeRepairRights;
    }

    if (strcmp([WJoyToolLoadDriverCommand UTF8String], argV[1]) == 0) {
        if (argC == 2)
            return WorkModeError;

        return WorkModeLoadDriver;
    }

    if (strcmp([WJoyToolUnloadDriverCommand UTF8String], argV[1]) == 0) {
        if (argC == 2)
            return WorkModeError;

        return WorkModeUnloadDriver;
    }

    return WorkModeError;
}

int main(int argC, char *argV[]) {
    @autoreleasepool {
        WorkMode mode = parseCommandLine(argC, argV);
        int result = EXIT_FAILURE;

        switch (mode) {
            case WorkModeRepairRights:
                result = repairRights(argV[0]);
                break;

            case WorkModeLoadDriver:
                result = loadDriver(argV[2]);
                break;

            case WorkModeUnloadDriver:
                result = unloadDriver(argV[2]);
                break;

            default:
                break;
        }

        return result;
    }
}
