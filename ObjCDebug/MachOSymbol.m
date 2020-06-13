//
//  MachOSymbol.m
//  ObjCDebug
//
//  Created by alxn1 on 26.11.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "MachOSymbol.h"
#import "MachOSymbol+Private.h"

@implementation MachOSymbol

@synthesize name =  _name;

+ (MachOSymbol*)symbolWithName:(NSString*)name info32:(const struct nlist*)info
{
    struct nlist_64 tmp;

    tmp.n_un.n_strx = info->n_un.n_strx;
    tmp.n_type      = info->n_type;
    tmp.n_sect      = info->n_sect;
    tmp.n_desc      = info->n_desc;
    tmp.n_value     = info->n_value;

    return [MachOSymbol symbolWithName:name info:&tmp];
}

+ (MachOSymbol*)symbolWithName:(NSString*)name info:(const struct nlist_64*)info
{
    return [[[MachOSymbol alloc] initWithName:name info:info] autorelease];
}

- (id)initWithName:(NSString*)name info:(const struct nlist_64*)info
{
    self = [super init];

    if(self == nil)
        return nil;

    _name = [name copy];
    memcpy(&_info, info, sizeof(struct nlist_64));

    return self;
}

- (void)dealloc
{
    [_name release];
    [super dealloc];
}

- (const struct nlist_64*)info
{
    return (&_info);
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"\"%@\": 0x%llX", _name, _info.n_value];
}

@end
