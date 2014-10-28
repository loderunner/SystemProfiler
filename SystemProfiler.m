//
// Copyright (c) 2014 Charles Francoise
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//


#import "SystemProfiler.h"

#define MINI_PROFILE_KEYS SystemProfileKeyHardwareMachine,\
                          SystemProfileKeyHardwareNumberOfCPUs, \
                          SystemProfileKeyHardwareCPUFrequency, \
                          SystemProfileKeyHardwareMemory, \
                          SystemProfileKeyOSName, \
                          SystemProfileKeyOSVersion
#define DEFAULT_PROFILE_KEYS MINI_PROFILE_KEYS, \
                             SystemProfileKeyHardwareModel, \
                             SystemProfileKeyHostHostname, \
                             SystemProfileKeyOSLanguage
#define FULL_PROFILE_KEYS DEFAULT_PROFILE_KEYS, \
                          SystemProfileKeyHardwareArchitecture, \
                          SystemProfileKeyHardware64Bit, \
                          SystemProfileKeyHardwareCPUThreadType, \
                          SystemProfileKeyHardwareByteOrder, \
                          SystemProfileKeyHardwareBusFrequency, \
                          SystemProfileKeyHardwareL1Cache, \
                          SystemProfileKeyHardwareL2Cache, \
                          SystemProfileKeyHardwareL3Cache, \
                          SystemProfileKeyHostId, \
                          SystemProfileKeyOSKernelVersion, \
                          SystemProfileKeyDiskName, \
                          SystemProfileKeyKext



NSDictionary* keySets = nil;

@implementation SystemProfiler
{
    NSMutableSet* _keys;
}

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keySets = @{SystemProfileLevelMini : @[MINI_PROFILE_KEYS],
                    SystemProfileLevelDefault : @[DEFAULT_PROFILE_KEYS],
                    SystemProfileLevelFull : @[FULL_PROFILE_KEYS]};
    });
}

+ (instancetype)systemProfiler
{
    SystemProfiler* systemProfiler = [[[self class] alloc] init];
#if __has_feature(objc_arc)
    return systemProfiler;
#else
    return [systemProfiler autorelease];
#endif
}

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _level = SystemProfileLevelDefault;
        [self setKeysForLevel:_level];
    }
    return self;
}

- (void)setLevel:(NSString *)level
{
    if (![_level isEqualToString:level])
    {
        _level = level;
        [self setKeysForLevel:_level];
    }
}

- (void)setKeysForLevel:(NSString*)level
{
    [_keys removeAllObjects];
    [_keys addObjectsFromArray:keySets[level]];
}

- (void)addProperty:(NSString *)key
{
    [_keys addObject:key];
}

- (NSArray*)getProperties
{
    return [_keys allObjects];
}

- (void)removeProperty:(NSString *)key
{
    [_keys removeObject:key];
}

- (void)removeAllProperties
{
    [_keys removeAllObjects];
}

- (NSDictionary*)systemProfile
{
    
}

@end

NSString * const SystemProfileLevelMini = @"SystemProfileLevelMini";
NSString * const SystemProfileLevelDefault = @"SystemProfileLevelDefault";
NSString * const SystemProfileLevelFull = @"SystemProfileLevelFull";