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

#import <sys/sysctl.h>
#import <sys/mount.h>

#import <IOKit/kext/KextManager.h>
#import <CoreFoundation/CoreFoundation.h>

NSString * const kOSBundleMachOHeadersKey = @"OSBundleMachOHeaders";
NSString * const kOSBundleCPUTypeKey = @"OSBundleCPUType";
NSString * const kOSBundleCPUSubtypeKey = @"OSBundleCPUSubtype";
NSString * const kOSBundlePathKey = @"OSBundlePath";
NSString * const kOSBundleExecutablePathKey = @"OSBundleExecutablePath";
NSString * const kOSBundleUUIDKey = @"OSBundleUUID";
NSString * const kOSBundleStartedKey = @"OSBundleStarted";
NSString * const kOSBundlePrelinkedKey = @"OSBundlePrelinked";
NSString * const kOSBundleLoadTagKey = @"OSBundleLoadTag";
NSString * const kOSBundleLoadAddressKey = @"OSBundleLoadAddress";
NSString * const kOSBundleLoadSizeKey = @"OSBundleLoadSize";
NSString * const kOSBundleWiredSizeKey = @"OSBundleWiredSize";
NSString * const kOSBundleDependenciesKey = @"OSBundleDependencies";
NSString * const kOSBundleRetainCountKey = @"OSBundleRetainCount";

#define MINI_PROFILE_PROPS SystemProfilerPropHardwareMachine,\
                           SystemProfilerPropHardwareNumberOfCPUs, \
                           SystemProfilerPropHardwareCPUFrequency, \
                           SystemProfilerPropHardwareMemory, \
                           SystemProfilerPropOSVersion
#define DEFAULT_PROFILE_PROPS MINI_PROFILE_PROPS, \
                              SystemProfilerPropHardwareModel, \
                              SystemProfilerPropHostHostname, \
                              SystemProfilerPropOSLanguage
#define FULL_PROFILE_PROPS DEFAULT_PROFILE_PROPS, \
                           SystemProfilerPropHardwareByteOrder, \
                           SystemProfilerPropHardwareBusFrequency, \
                           SystemProfilerPropOSKernelVersion, \
                           SystemProfilerPropDisks, \
                           SystemProfilerPropKexts


NSDictionary* propSets = nil;

@implementation SystemProfiler
{
    NSMutableSet* _props;
}

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        propSets = @{SystemProfileLevelMini : @[MINI_PROFILE_PROPS],
                    SystemProfileLevelDefault : @[DEFAULT_PROFILE_PROPS],
                    SystemProfileLevelFull : @[FULL_PROFILE_PROPS]};
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
        _props = [[NSMutableSet alloc] init];
        _level = SystemProfileLevelDefault;
        [self setPropertiesForLevel:_level];
    }
    return self;
}

- (void)setLevel:(NSString *)level
{
    if (![_level isEqualToString:level])
    {
        _level = level;
        [self setPropertiesForLevel:_level];
    }
}

- (void)setPropertiesForLevel:(NSString*)level
{
    [_props removeAllObjects];
    [_props addObjectsFromArray:propSets[level]];
}

- (void)addProperty:(NSString *)prop
{
    [_props addObject:prop];
}

- (NSArray*)getProperties
{
    return [_props allObjects];
}

- (void)removeProperty:(NSString *)prop
{
    [_props removeObject:prop];
}

- (void)removeAllProperties
{
    [_props removeAllObjects];
}

- (NSDictionary*)systemProfile
{
    int n;
    char str[256];
    size_t len;
    
    NSMutableDictionary* profile = [NSMutableDictionary dictionary];
    
    // **** HARDWARE ****
    {
        NSMutableDictionary* hwProps = [NSMutableDictionary dictionary];
        profile[SystemProfileKeyHardware] = hwProps;
        
        if ([_props containsObject:SystemProfilerPropHardwareMachine])
        {
            len = 256;
            if (sysctlbyname("hw.machine", str, &len, NULL, 0) == 0)
            {
                hwProps[SystemProfileKeyHardwareMachine] = @(str);
            }
        }
        
        if ([_props containsObject:SystemProfilerPropHardwareModel])
        {
            len = 256;
            if (sysctlbyname("hw.model", str, &len, NULL, 0) == 0)
            {
                hwProps[SystemProfileKeyHardwareModel] = @(str);
            }
        }
        
        if ([_props containsObject:SystemProfilerPropHardwareNumberOfCPUs])
        {
            len = sizeof(n);
            if (sysctlbyname("hw.ncpu", &n, &len, NULL, 0) == 0)
            {
                hwProps[SystemProfileKeyHardwareNumberOfCPUs] = @(n);
            }
        }
        
        if ([_props containsObject:SystemProfilerPropHardwareCPUFrequency])
        {
            len = sizeof(n);
            if (sysctlbyname("hw.cpufrequency", &n, &len, NULL, 0) == 0)
            {
                hwProps[SystemProfileKeyHardwareCPUFrequency] = @(n);
            }
        }
        
        if ([_props containsObject:SystemProfilerPropHardwareByteOrder])
        {
            len = sizeof(n);
            if (sysctlbyname("hw.byteorder", &n, &len, NULL, 0) == 0)
            {
                if (n == 1234)
                {
                    hwProps[SystemProfileKeyHardwareByteOrder] = @"Little-Endian";
                }
                else if (n == 4321)
                {
                    hwProps[SystemProfileKeyHardwareByteOrder] = @"Big-Endian";
                }
            }
        }
        
        if ([_props containsObject:SystemProfilerPropHardwareMemory])
        {
            NSUInteger memsize;
            len = sizeof(memsize);
            if (sysctlbyname("hw.memsize", &memsize, &len, NULL, 0) == 0)
            {
                hwProps[SystemProfileKeyHardwareMemory] = @(memsize);
            }
        }
        
        if ([_props containsObject:SystemProfilerPropHardwareBusFrequency])
        {
            len = sizeof(n);
            if (sysctlbyname("hw.busfrequency", &n, &len, NULL, 0) == 0)
            {
                hwProps[SystemProfileKeyHardwareBusFrequency] = @(n);
            }
        }
        
        if (hwProps.count == 0)
        {
            [profile removeObjectForKey:SystemProfileKeyHardware];
        }
    }
    
    // **** HOST ****
    {
        NSMutableDictionary* hostProps = [NSMutableDictionary dictionary];
        profile[SystemProfileKeyHost] = hostProps;
        
        if ([_props containsObject:SystemProfilerPropHostHostname])
        {
            hostProps[SystemProfileKeyHostHostname] = [[NSHost currentHost] localizedName];
        }
        
        if (hostProps.count == 0)
        {
            [profile removeObjectForKey:SystemProfileKeyHost];
        }
    }
    
    // **** OS ****
    {
        NSMutableDictionary* osProps = [NSMutableDictionary dictionary];
        profile[SystemProfileKeyOS] = osProps;
        
        if ([_props containsObject:SystemProfilerPropOSVersion])
        {
            osProps[SystemProfileKeyOSVersion] = [[NSProcessInfo processInfo] operatingSystemVersionString];
        }
        
        if ([_props containsObject:SystemProfilerPropOSKernelVersion])
        {
            len = 256;
            if (sysctlbyname("kern.version", str, &len, NULL, 0) == 0)
            {
                osProps[SystemProfileKeyOSKernelVersion] = @(str);
            }
        }
        
        if ([_props containsObject:SystemProfilerPropOSLanguage])
        {
            NSArray* languages = [NSLocale preferredLanguages];
            osProps[SystemProfileKeyOSLanguage] = languages[0];
        }
        
        if (osProps.count == 0)
        {
            [profile removeObjectForKey:SystemProfileKeyOS];
        }
    }
    
    // **** DISKS ****
    {
        NSMutableArray* disksProps = [NSMutableArray array];
        profile[SystemProfileKeyDisks] = disksProps;
        
        if ([_props containsObject:SystemProfilerPropDisks])
        {
            NSArray* volumes = [[NSFileManager defaultManager] mountedVolumeURLsIncludingResourceValuesForKeys:nil options:0];
            
            for (NSURL* volume in volumes)
            {
                NSDictionary* diskProps = [volume resourceValuesForKeys:@[NSURLVolumeLocalizedFormatDescriptionKey,
                                                                          NSURLVolumeTotalCapacityKey,
                                                                          NSURLVolumeAvailableCapacityKey,
                                                                          NSURLVolumeResourceCountKey,
                                                                          NSURLVolumeNameKey
                                                                          ]
                                                             error:NULL];
                if (diskProps != nil)
                {
                    [disksProps addObject:@{SystemProfileKeyDiskMountpoint : [volume path],
                                            SystemProfileKeyDiskFormat : diskProps[NSURLVolumeLocalizedFormatDescriptionKey],
                                            SystemProfileKeyDiskTotalCapacity : diskProps[NSURLVolumeTotalCapacityKey],
                                            SystemProfileKeyDiskAvailableCapacity : diskProps[NSURLVolumeAvailableCapacityKey],
                                            SystemProfileKeyDiskNumberOfFiles : diskProps[NSURLVolumeResourceCountKey],
                                            SystemProfileKeyDiskName : diskProps[NSURLVolumeNameKey]}];
                }
            }
        }
        
        if (disksProps.count == 0)
        {
            [profile removeObjectForKey:SystemProfileKeyDisks];
        }
    }
    
    // **** KEXTS ****
    {
        NSMutableArray* kextsProps = [NSMutableArray array];
        profile[SystemProfileKeyKexts] = kextsProps;
        
        if ([_props containsObject:SystemProfilerPropKexts])
        {
            
            NSDictionary* kextsDict = (__bridge NSDictionary*)KextManagerCopyLoadedKextInfo(NULL, (__bridge CFArrayRef)@[(__bridge NSString*)kCFBundleIdentifierKey,
                                                                                                                         (__bridge NSString*)kCFBundleVersionKey,
                                                                                                                         kOSBundleLoadTagKey,
                                                                                                                         kOSBundleRetainCountKey,
                                                                                                                         kOSBundleStartedKey,
                                                                                                                         kOSBundleLoadAddressKey,
                                                                                                                         kOSBundleLoadSizeKey,
                                                                                                                         kOSBundleWiredSizeKey,
                                                                                                                         kOSBundleDependenciesKey]);
            NSArray* kexts = [[kextsDict allValues] sortedArrayUsingComparator:^NSComparisonResult(id kext1, id kext2) {
                NSNumber* n1 = kext1[kOSBundleLoadTagKey];
                NSNumber* n2 = kext2[kOSBundleLoadTagKey];
                return [n1 compare:n2];
            }];
            
            for (NSDictionary* kext in kexts)
            {
                if (kext != nil)
                {
                    NSMutableDictionary* props = [NSMutableDictionary dictionaryWithCapacity:9];
                    
                    props[SystemProfileKeyKextIndex] = kext[kOSBundleLoadTagKey];
                    props[SystemProfileKeyKextName] = kext[(__bridge NSString*)kCFBundleIdentifierKey];
                    props[SystemProfileKeyKextVersion] = kext[(__bridge NSString*)kCFBundleVersionKey];
                    props[SystemProfileKeyKextReferenceCount] = kext[kOSBundleRetainCountKey];
                    props[SystemProfileKeyKextRunning] = ([kext[kOSBundleStartedKey] boolValue] ? @"YES" : @"NO");
                    props[SystemProfileKeyKextAddress] = [NSString stringWithFormat:@"0x%llx", [kext[kOSBundleLoadAddressKey] unsignedLongLongValue]];
                    props[SystemProfileKeyKextSize] = [NSString stringWithFormat:@"0x%lx", [kext[kOSBundleLoadSizeKey] longValue]];
                    props[SystemProfileKeyKextWired] = [NSString stringWithFormat:@"0x%lx", [kext[kOSBundleWiredSizeKey] longValue]];
                    if(kext[kOSBundleDependenciesKey] != nil)
                    {
                        props[SystemProfileKeyKextDependencies] = kext[kOSBundleDependenciesKey];
                    }
                    
                    [kextsProps addObject:props];
                }
            }
        }
        
        if (kextsProps.count == 0)
        {
            [profile removeObjectForKey:SystemProfileKeyKexts];
        }
    }
    
    return profile;
}

@end

NSString * const SystemProfileLevelMini = @"SystemProfileLevelMini";
NSString * const SystemProfileLevelDefault = @"SystemProfileLevelDefault";
NSString * const SystemProfileLevelFull = @"SystemProfileLevelFull";


/**
 System Profile keys
 */
// Level 1 keys
NSString * const SystemProfileKeyHardware = @"Hardware";
NSString * const SystemProfileKeyHost = @"Host";
NSString * const SystemProfileKeyOS = @"OS";
NSString * const SystemProfileKeyDisks = @"Disks";
NSString * const SystemProfileKeyKexts = @"KernelExtensions";
// Level 2 keys
NSString * const SystemProfileKeyHardwareMachine = @"Machine";
NSString * const SystemProfileKeyHardwareModel = @"Model";
NSString * const SystemProfileKeyHardwareNumberOfCPUs = @"NumberOfCPUs";
NSString * const SystemProfileKeyHardwareCPUFrequency = @"CPUFrequency";
NSString * const SystemProfileKeyHardwareByteOrder = @"ByteOrder";
NSString * const SystemProfileKeyHardwareMemory = @"Memory";
NSString * const SystemProfileKeyHardwareBusFrequency = @"BusFrequency";
NSString * const SystemProfileKeyHostHostname = @"Hostname";
NSString * const SystemProfileKeyOSVersion = @"Version";
NSString * const SystemProfileKeyOSKernelVersion = @"KernelVersion";
NSString * const SystemProfileKeyOSLanguage = @"Language";
NSString * const SystemProfileKeyDiskMountpoint = @"Mountpoint";
NSString * const SystemProfileKeyDiskName = @"Name";
NSString * const SystemProfileKeyDiskFormat = @"Format";
NSString * const SystemProfileKeyDiskTotalCapacity = @"TotalCapacity";
NSString * const SystemProfileKeyDiskAvailableCapacity = @"AvailableCapacity";
NSString * const SystemProfileKeyDiskNumberOfFiles = @"NumberOfFiles";
NSString * const SystemProfileKeyKextName = @"Name";
NSString * const SystemProfileKeyKextVersion = @"Version";
NSString * const SystemProfileKeyKextIndex = @"Index";
NSString * const SystemProfileKeyKextReferenceCount = @"ReferenceCount";
NSString * const SystemProfileKeyKextRunning = @"Running";
NSString * const SystemProfileKeyKextAddress = @"Address";
NSString * const SystemProfileKeyKextSize = @"Size";
NSString * const SystemProfileKeyKextWired = @"Wired";
NSString * const SystemProfileKeyKextDependencies = @"Dependencies";

/**
 System Profiler profiling properties
 */
NSString * const SystemProfilerPropKexts = @"SystemProfilerPropKexts";
NSString * const SystemProfilerPropDisks = @"SystemProfilerPropDisks";
NSString * const SystemProfilerPropHardwareMachine = @"SystemProfilerPropHardwareMachine";
NSString * const SystemProfilerPropHardwareModel = @"SystemProfilerPropHardwareModel";
NSString * const SystemProfilerPropHardwareNumberOfCPUs = @"SystemProfilerPropHardwareNumberOfCPUs";
NSString * const SystemProfilerPropHardwareCPUFrequency = @"SystemProfilerPropHardwareCPUFrequency";
NSString * const SystemProfilerPropHardwareByteOrder = @"SystemProfilerPropHardwareByteOrder";
NSString * const SystemProfilerPropHardwareMemory = @"SystemProfilerPropHardwareMemory";
NSString * const SystemProfilerPropHardwareBusFrequency = @"SystemProfilerPropHardwareBusFrequency";
NSString * const SystemProfilerPropHostHostname = @"SystemProfilerPropHostHostname";
NSString * const SystemProfilerPropHostId = @"SystemProfilerPropHostId";
NSString * const SystemProfilerPropOSVersion = @"SystemProfilerPropOSVersion";
NSString * const SystemProfilerPropOSKernelVersion = @"SystemProfilerPropOSKernelVersion";
NSString * const SystemProfilerPropOSLanguage = @"SystemProfilerPropOSLanguage";

