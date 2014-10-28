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
 System Profile keys
 */
// Level 1 keys
extern NSString * const SystemProfileKeyHardware;
extern NSString * const SystemProfileKeyHost;
extern NSString * const SystemProfileKeyOS;
extern NSString * const SystemProfileKeyDisk;
extern NSString * const SystemProfileKeyKext;
// Level 2 keys
extern NSString * const SystemProfileKeyHardwareMachine;
extern NSString * const SystemProfileKeyHardwareModel;
extern NSString * const SystemProfileKeyHardwareArchitecture;
extern NSString * const SystemProfileKeyHardware64Bit;
extern NSString * const SystemProfileKeyHardwareNumberOfCPUs;
extern NSString * const SystemProfileKeyHardwareCPUFrequency;
extern NSString * const SystemProfileKeyHardwareCPUThreadType;
extern NSString * const SystemProfileKeyHardwareByteOrder;
extern NSString * const SystemProfileKeyHardwareMemory;
extern NSString * const SystemProfileKeyHardwareBusFrequency;
extern NSString * const SystemProfileKeyHardwareL1Cache;
extern NSString * const SystemProfileKeyHardwareL2Cache;
extern NSString * const SystemProfileKeyHardwareL3Cache;
extern NSString * const SystemProfileKeyHostHostname;
extern NSString * const SystemProfileKeyHostId;
extern NSString * const SystemProfileKeyOSName;
extern NSString * const SystemProfileKeyOSVersion;
extern NSString * const SystemProfileKeyOSKernelVersion;
extern NSString * const SystemProfileKeyOSLanguage;
extern NSString * const SystemProfileKeyDiskName;



@interface SystemProfiler : NSObject

+ (instancetype)systemProfiler;

- (instancetype)init;

- (NSDictionary*)systemProfile;

- (void)addProperty:(NSString*)key;
- (NSArray*)getProperties;
- (void)removeProperty:(NSString*)key;
- (void)removeAllProperties;

@property (nonatomic, assign) NSString* level;

@end