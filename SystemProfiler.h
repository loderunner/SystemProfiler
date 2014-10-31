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

#import <Foundation/Foundation.h>

/**
 System Profile levels
 */
// Minimal system profile
extern NSString * const SystemProfileLevelMini;
// Default system profile
extern NSString * const SystemProfileLevelDefault;
// Full system profile containing all profile keys
extern NSString * const SystemProfileLevelFull;

/**
 System Profile dictionary keys
 */
// Level 1 keys
extern NSString * const SystemProfileKeyHardware;
extern NSString * const SystemProfileKeyHost;
extern NSString * const SystemProfileKeyOS;
extern NSString * const SystemProfileKeyDisks;
extern NSString * const SystemProfileKeyKexts;
// Level 2 keys
extern NSString * const SystemProfileKeyHardwareMachine;
extern NSString * const SystemProfileKeyHardwareModel;
extern NSString * const SystemProfileKeyHardwareNumberOfCPUs;
extern NSString * const SystemProfileKeyHardwareCPUFrequency;
extern NSString * const SystemProfileKeyHardwareByteOrder;
extern NSString * const SystemProfileKeyHardwareMemory;
extern NSString * const SystemProfileKeyHardwareBusFrequency;
extern NSString * const SystemProfileKeyHostHostname;
extern NSString * const SystemProfileKeyHostId;
extern NSString * const SystemProfileKeyOSVersion;
extern NSString * const SystemProfileKeyOSKernelVersion;
extern NSString * const SystemProfileKeyOSLanguage;
extern NSString * const SystemProfileKeyDiskName;
extern NSString * const SystemProfileKeyDiskFormat;
extern NSString * const SystemProfileKeyDiskTotalCapacity;
extern NSString * const SystemProfileKeyDiskAvailableCapacity;
extern NSString * const SystemProfileKeyDiskNumberOfFiles;
extern NSString * const SystemProfileKeyKextName;
extern NSString * const SystemProfileKeyKextVersion;
extern NSString * const SystemProfileKeyKextIndex;
extern NSString * const SystemProfileKeyKextReferenceCount;
extern NSString * const SystemProfileKeyKextRunning;
extern NSString * const SystemProfileKeyKextAddress;
extern NSString * const SystemProfileKeyKextSize;
extern NSString * const SystemProfileKeyKextWired;
extern NSString * const SystemProfileKeyKextDependencies;

/**
 System Profiler profiling properties
 */
extern NSString * const SystemProfilerPropKexts;
extern NSString * const SystemProfilerPropDisks;
extern NSString * const SystemProfilerPropHardwareMachine;
extern NSString * const SystemProfilerPropHardwareModel;
extern NSString * const SystemProfilerPropHardwareNumberOfCPUs;
extern NSString * const SystemProfilerPropHardwareCPUFrequency;
extern NSString * const SystemProfilerPropHardwareByteOrder;
extern NSString * const SystemProfilerPropHardwareMemory;
extern NSString * const SystemProfilerPropHardwareBusFrequency;
extern NSString * const SystemProfilerPropHostHostname;
extern NSString * const SystemProfilerPropHostId;
extern NSString * const SystemProfilerPropOSName;
extern NSString * const SystemProfilerPropOSVersion;
extern NSString * const SystemProfilerPropOSKernelVersion;
extern NSString * const SystemProfilerPropOSLanguage;



@interface SystemProfiler : NSObject

+ (instancetype)systemProfiler;

- (instancetype)init;

- (NSDictionary*)systemProfile;

- (void)addProperty:(NSString*)prop;
- (NSArray*)getProperties;
- (void)removeProperty:(NSString*)prop;
- (void)removeAllProperties;

@property (nonatomic, assign) NSString* level;

@end