//
//  StatusBarItemController.m
//  WJoy
//
//  Created by alxn1 on 27.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import <Wiimote/Wiimote.h>

#import "StatusBarItemController.h"
#import "ButtonConfiguration.h"
#import "ProfileProvider.h"

#import <Sparkle/Sparkle.h>

@interface StatusBarItemController () <NSMenuDelegate>

@end

@implementation StatusBarItemController
{
    NSMenu *_menu;
    NSStatusItem *_item;
    ButtonConfiguration *_defaultDeviceProfile;
    NSArray<ButtonConfiguration *> *_deviceProfiles;
    NSArray<ButtonConfiguration *> *_appDeviceProfiles;
    NSArray<ButtonConfiguration *> *_userDeviceProfiles;
    NSMutableDictionary<NSString *, ButtonConfiguration *> *_deviceAddressToProfile;
}

+ (instancetype)start
{
    static StatusBarItemController *singleton;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[StatusBarItemController alloc] initInternal];
    });
    return singleton;
}

- (id)initInternal
{
    self = [super init];
    if (self == nil)
        return nil;

    _deviceProfiles = _appDeviceProfiles = _userDeviceProfiles = @[];
    _deviceAddressToProfile = [NSMutableDictionary dictionary];
    [self fetchProfiles:nil];

    _menu = [[NSMenu alloc] initWithTitle:@"WiiController"];
    _item = [[NSStatusBar systemStatusBar]
        statusItemWithLength:NSSquareStatusItemLength];

    [_menu setDelegate:self];

    NSImage *icon = [NSImage imageNamed:@"wiimote"];

    [icon setSize:NSMakeSize(20.0f, 20.0f)];

    [_item setImage:icon];
    [_item setMenu:_menu];
    [_item setHighlightMode:YES];

    [Wiimote setUseOneButtonClickConnection:
                 [[NSUserDefaults standardUserDefaults] boolForKey:@"OneButtonClickConnection"]];

    return self;
}

- (void)dealloc
{
    [[NSStatusBar systemStatusBar] removeStatusItem:_item];
}

- (void)toggleOneButtonClickConnection
{
    [Wiimote setUseOneButtonClickConnection:
                 ![Wiimote isUseOneButtonClickConnection]];

    [[NSUserDefaults standardUserDefaults]
        setBool:[Wiimote isUseOneButtonClickConnection]
         forKey:@"OneButtonClickConnection"];
}

- (void)menuNeedsUpdate:(NSMenu *)menu
{
    for (Wiimote *wiimote in [Wiimote connectedDevices])
    {
        [wiimote requestUpdateState];
    }

    [_menu removeAllItems];

    __auto_type discoveryItem = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];

    if (wiimoteIsBluetoothEnabled())
    {
        if ([Wiimote isDiscovering])
        {
            [discoveryItem setTitle:@"Discovering: Press red pairing button on Nintendo device"];
        }
        else
        {
            NSImage *icon = [NSImage imageNamed:NSImageNameBluetoothTemplate];
            [discoveryItem setImage:icon];
            [discoveryItem setTitle:@"Pair Device"];
            [discoveryItem setTarget:[Wiimote class]];
            [discoveryItem setAction:@selector(beginDiscovery)];
        }
    }
    else
    {
        NSImage *icon = [NSImage imageNamed:@"warning"];
        [icon setSize:NSMakeSize(16.0f, 16.0f)];
        [discoveryItem setImage:icon];
        [discoveryItem setTitle:@"Bluetooth is disabled!"];
    }

    [_menu addItem:discoveryItem];

    [_menu addItem:[NSMenuItem separatorItem]];

    NSArray *connectedDevices = [Wiimote connectedDevices];
    NSUInteger countConnected = [connectedDevices count];

    [_menu addItem:[[NSMenuItem alloc] initWithTitle:(countConnected ? @"Connected:" : @"No Devices Connected") action:nil keyEquivalent:@""]];
    for (NSUInteger i = 0; i < countConnected; i++)
    {
        Wiimote *device = [connectedDevices objectAtIndex:i];
        NSString *batteryLevel = @"-";

        if ([device batteryLevel] >= 0.0)
            batteryLevel = [NSString stringWithFormat:@"%.0lf%%", [device batteryLevel]];

        NSMenuItem *item = [[NSMenuItem alloc]
            initWithTitle:[NSString stringWithFormat:@"#%li %@ (%@ Battery) / %@",
                                                     i + 1,
                                                     [device marketingName],
                                                     [device batteryLevelDescription],
                                                     [device addressString]]
                   action:nil
            keyEquivalent:@""];
        [_menu addItem:item];
        [item setIndentationLevel:1];

        if ([device isBatteryLevelLow])
        {
            NSImage *icon = [NSImage imageNamed:@"warning"];
            [icon setSize:NSMakeSize(16.0f, 16.0f)];
            [item setImage:icon];
        }

        NSMenu *deviceSubmenu = [[NSMenu alloc] initWithTitle:@"Device Options"];
        item.submenu = deviceSubmenu;

        NSMenuItem *profilesMenuItem = [[NSMenuItem alloc] initWithTitle:@"Profile" action:nil keyEquivalent:@""];
        [deviceSubmenu addItem:profilesMenuItem];

        NSMenu *profilesMenu = [[NSMenu alloc] initWithTitle:@"Profile"];
        profilesMenuItem.submenu = profilesMenu;

        __auto_type currentProfile = _deviceAddressToProfile[device.addressString] ?: _defaultDeviceProfile;

        NSMenuItem *profileItem = [[NSMenuItem alloc] initWithTitle:_defaultDeviceProfile.name action:@selector(setDeviceProfile:) keyEquivalent:@""];
        profileItem.target = self;
        profileItem.representedObject = @{ @"Device" : device, @"Profile" : _defaultDeviceProfile };
        if ([_defaultDeviceProfile.path isEqualToString:currentProfile.path]) profileItem.state = NSControlStateValueOn;
        [profilesMenu addItem:profileItem];

        if (_appDeviceProfiles.count > 0) [profilesMenu addItem:[NSMenuItem separatorItem]];

        __auto_type sortedAppProfiles = [_appDeviceProfiles sortedArrayUsingSelector:@selector(name)];
        for (ButtonConfiguration *profile in sortedAppProfiles)
        {
            NSMenuItem *profileItem = [[NSMenuItem alloc] initWithTitle:profile.name action:@selector(setDeviceProfile:) keyEquivalent:@""];
            profileItem.target = self;
            profileItem.representedObject = @{ @"Device" : device, @"Profile" : profile };
            if ([profile.path isEqualToString:currentProfile.path]) profileItem.state = NSControlStateValueOn;
            [profilesMenu addItem:profileItem];
        }

        if (_userDeviceProfiles.count > 0) [profilesMenu addItem:[NSMenuItem separatorItem]];

        __auto_type sortedUserProfiles = [_userDeviceProfiles sortedArrayUsingSelector:@selector(name)];
        for (ButtonConfiguration *profile in sortedUserProfiles)
        {
            NSMenuItem *profileItem = [[NSMenuItem alloc] initWithTitle:profile.name action:@selector(setDeviceProfile:) keyEquivalent:@""];
            profileItem.target = self;
            profileItem.representedObject = @{ @"Device" : device, @"Profile" : profile };
            if ([profile.path isEqualToString:currentProfile.path]) profileItem.state = NSControlStateValueOn;
            [profilesMenu addItem:profileItem];
        }
    }

    [_menu addItem:[NSMenuItem separatorItem]];

    NSMenuItem *openProfilesFolderItem = [[NSMenuItem alloc] initWithTitle:@"Open Profiles Folder" action:@selector(openProfilesFolder:) keyEquivalent:@""];
    openProfilesFolderItem.target = self;
    openProfilesFolderItem.representedObject = @"User";
    [_menu addItem:openProfilesFolderItem];

    NSMenu *openProfilesFolderSubmenu = [[NSMenu alloc] initWithTitle:@"Open Profiles Folder"];
    openProfilesFolderItem.submenu = openProfilesFolderSubmenu;

    NSMenuItem *defaultProfilesFolderItem = [[NSMenuItem alloc] initWithTitle:@"Default Profiles" action:@selector(openProfilesFolder:) keyEquivalent:@""];
    defaultProfilesFolderItem.target = self;
    defaultProfilesFolderItem.representedObject = @"Default";
    [openProfilesFolderSubmenu addItem:defaultProfilesFolderItem];

    NSMenuItem *userProfilesFolderItem = [[NSMenuItem alloc] initWithTitle:@"User Profiles" action:@selector(openProfilesFolder:) keyEquivalent:@""];
    userProfilesFolderItem.target = self;
    userProfilesFolderItem.representedObject = @"User";
    [openProfilesFolderSubmenu addItem:userProfilesFolderItem];

    NSMenuItem *reloadProfilesItem = [[NSMenuItem alloc] initWithTitle:@"Reload Profiles" action:@selector(fetchProfiles:) keyEquivalent:@""];
    reloadProfilesItem.target = self;
    [_menu addItem:reloadProfilesItem];

    [_menu addItem:[NSMenuItem separatorItem]];

//    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Auto-connect to Paired Devices (Experimental)" action:@selector(toggleOneButtonClickConnection) keyEquivalent:@""];
//    item.target = self;
//    [item setState:([Wiimote isUseOneButtonClickConnection]) ? (NSControlStateValueOn) : (NSControlStateValueOff)];
//    [_menu addItem:item];
//
//    [_menu addItem:[NSMenuItem separatorItem]];

    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"About WiiController" action:@selector(showAboutPanel:) keyEquivalent:@""];
    item.target = self;
    [_menu addItem:item];
    
    item = [[NSMenuItem alloc] initWithTitle:@"Check for Updates…" action:@selector(checkForUpdates:) keyEquivalent:@""];
    item.target = [SUUpdater sharedUpdater];
    [_menu addItem:item];

    [_menu addItem:[NSMenuItem separatorItem]];

    item = [[NSMenuItem alloc] initWithTitle:@"Quit WiiController" action:@selector(terminate:) keyEquivalent:@"q"];
    item.target = [NSApplication sharedApplication];
    [_menu addItem:item];
}

static NSURL *appProfilesFolderURL()
{
    return [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"Device Profiles"];
}
static NSURL *userProfilesFolderURL()
{
    NSError *error;
    NSURL *appSupportURL = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    if (error)
    {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __auto_type userProfilesURL = [[appSupportURL URLByAppendingPathComponent:@"WiiController"] URLByAppendingPathComponent:@"Device Profiles"];
    [[NSFileManager defaultManager] createDirectoryAtURL:userProfilesURL withIntermediateDirectories:YES attributes:nil error:&error];
    if (error)
    {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    return userProfilesURL;
}

static NSEnumerator *profileDirectoryEnumerator(NSURL *directoryURL)
{
    return [[NSFileManager defaultManager] enumeratorAtURL:directoryURL includingPropertiesForKeys:@[ NSURLIsDirectoryKey ] options:NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsHiddenFiles errorHandler:^BOOL(NSURL *url, NSError *error) {
        [[NSApplication sharedApplication] presentError:error];
        return YES;
    }];
}
static ButtonConfiguration *loadProfile(NSURL *url)
{
    __auto_type stream = [NSInputStream inputStreamWithURL:url];
    [stream open];
    NSError *error;
    NSDictionary *dictionary = [NSPropertyListSerialization propertyListWithStream:stream options:NSPropertyListMutableContainers format:nil error:&error];
    [stream close];
    if (error)
    {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    if (![dictionary isKindOfClass:[NSDictionary class]])
    {
        return nil;
    }
    // Convert button number keys from NSStrings to NSNumbers.
    NSMutableDictionary *newDictionary = [NSMutableDictionary dictionary];
    for (NSString *extension in dictionary)
    {
        NSMutableDictionary *extensionToInputTypeMappings = dictionary[extension];
        NSMutableDictionary *newExtensionToInputTypeMappings = [NSMutableDictionary dictionary];
        if (![extensionToInputTypeMappings isKindOfClass:[NSMutableDictionary class]]) continue;
        for (NSString *inputType in extensionToInputTypeMappings)
        {
            NSDictionary *inputTypeToInputMappings = extensionToInputTypeMappings[inputType];
            if (![inputTypeToInputMappings isKindOfClass:[NSDictionary class]]) continue;
            NSMutableDictionary<NSNumber *, NSNumber *> *numericInputMappings = [NSMutableDictionary dictionary];
            for (NSString *input in inputTypeToInputMappings)
            {
                NSScanner *scanner = [NSScanner scannerWithString:input];
                int value;
                if ([scanner scanInt:&value]) numericInputMappings[@(value)] = inputTypeToInputMappings[input];
            }
            newExtensionToInputTypeMappings[inputType] = numericInputMappings;
        }
        newDictionary[extension] = newExtensionToInputTypeMappings;
    }
    return [ButtonConfiguration configurationWithName:[[url URLByDeletingPathExtension] lastPathComponent] path:[[url absoluteURL] path] dictionary:newDictionary];
}
static ButtonConfiguration *loadProfileIntoList(NSMutableArray<ButtonConfiguration *> *profiles, NSURL *url)
{
    __auto_type profile = loadProfile(url);
    if (profile) [profiles addObject:profile];
    return profile;
}
static NSString *const defaultProfileFileName = @"Default.plist";
- (void)fetchProfiles:(id)sender
{
    _defaultDeviceProfile = loadProfile([appProfilesFolderURL() URLByAppendingPathComponent:defaultProfileFileName]);

    NSMutableArray *appProfiles = [NSMutableArray array];
    for (NSURL *fileURL in profileDirectoryEnumerator(appProfilesFolderURL()))
    {
        if ([[fileURL lastPathComponent] isEqualToString:defaultProfileFileName]) continue;
        loadProfileIntoList(appProfiles, fileURL);
    }
    _appDeviceProfiles = appProfiles;

    NSMutableArray *userProfiles = [NSMutableArray array];
    for (NSURL *fileURL in profileDirectoryEnumerator(userProfilesFolderURL()))
    {
        loadProfileIntoList(userProfiles, fileURL);
    }
    _userDeviceProfiles = userProfiles;

    _deviceProfiles = [appProfiles arrayByAddingObjectsFromArray:userProfiles];

    // Update all profiles in use, using default for any that no longer exist.
    __auto_type newDeviceAddressToProfile = [NSMutableDictionary dictionary];
    for (NSString *deviceAddress in _deviceAddressToProfile)
    {
        __auto_type oldProfile = _deviceAddressToProfile[deviceAddress];
        for (ButtonConfiguration *newProfile in _deviceProfiles)
        {
            if ([newProfile.path isEqualToString:oldProfile.path])
            {
                newDeviceAddressToProfile[deviceAddress] = newProfile;
                break;
            }
        }
        if (!newDeviceAddressToProfile[deviceAddress])
        {
            newDeviceAddressToProfile[deviceAddress] = _defaultDeviceProfile;
        }
    }
    _deviceAddressToProfile = newDeviceAddressToProfile;
}

- (void)setDeviceProfile:(NSMenuItem *)sender
{
    Wiimote *device = sender.representedObject[@"Device"];
    ButtonConfiguration *profile = sender.representedObject[@"Profile"];
    _deviceAddressToProfile[device.addressString] = profile;
}

- (void)openProfilesFolder:(NSMenuItem *)sender
{
    NSURL *profilesFolderURL = ([sender.representedObject isEqual:@"Default"]) ? appProfilesFolderURL() : userProfilesFolderURL();
    if (!profilesFolderURL) return;

    [[NSWorkspace sharedWorkspace] openURL:profilesFolderURL];
}

- (void)showAboutPanel:(id)sender
{
    __auto_type app = [NSApplication sharedApplication];
    [app orderFrontStandardAboutPanel:nil];
    [app unhide:nil];
}

- (ButtonConfiguration *)profileForDevice:(Wiimote *)device
{
    return _deviceAddressToProfile[device.addressString] ?: _defaultDeviceProfile;
}

@end
