/*
 This source is part of UnitKit, a unit test framework for Mac OS X 
 development. You can find more information about UnitKit at:
 
 http://x180.net/Code/UnitKit
 
 Copyright (c)2004 James Duncan Davidson
 
 Contributions by Quentin mathe
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 The use of the Apache License does not indicate that this project is
 affiliated with the Apache Software Foundation.
 */

#import "UKTask.h"

// XXX this will leave turds around in /tmp if not released... need to do
// the stdin/out/err in memory really....

#ifdef GNUSTEP
	static int gsuuid = 0;
#endif

@implementation UKTask

- (id) init
{
    self = [super init];
    
    // inherit the current environment
    
    environment = [[NSMutableDictionary alloc] initWithDictionary:[[NSProcessInfo processInfo] environment]];
    
    // create our temp file nameswith a UUID
    
#ifndef GNUSTEP
	
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    stdInPath = [[NSString stringWithFormat:@"/tmp/%@-stdin", uuidString] retain];
    stdOutPath = [[NSString stringWithFormat:@"/tmp/%@-stdout", uuidString] retain];
    stdErrPath = [[NSString stringWithFormat:@"/tmp/%@-stderr", uuidString] retain];
    CFRelease(uuidString);
    CFRelease(uuid);
	
#else
	
	gsuuid++;
	NSString *uuidString = [NSString stringWithFormat:@"%d", gsuuid];
	stdInPath = [[NSString stringWithFormat:@"/tmp/%@-stdin", uuidString] retain];
    stdOutPath = [[NSString stringWithFormat:@"/tmp/%@-stdout", uuidString] retain];
    stdErrPath = [[NSString stringWithFormat:@"/tmp/%@-stderr", uuidString] retain];
	
#endif
    
    // "touch" our temp files. This could be done better...
    
    [@"" writeToFile:stdInPath atomically:NO];
    [@"" writeToFile:stdOutPath atomically:NO];
    [@"" writeToFile:stdErrPath atomically:NO];
    
    return self;
}

- (void) dealloc
{
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeFileAtPath:stdInPath handler:nil];
    [fm removeFileAtPath:stdOutPath handler:nil];
    [fm removeFileAtPath:stdErrPath handler:nil];
    
    [arguments release];
    [launchPath release];
    [workingDirectoryPath release];
    [environment release];
    [stdInPath release];
    [stdOutPath release];
    [stdErrPath release];
    
    [super dealloc];
}

- (void) setArguments:(NSArray *)args
{
    [arguments autorelease];
    arguments = [args retain];
}

- (void) setLaunchPath:(NSString *)path
{
    [launchPath release];
    launchPath = [path retain];
}

- (void) setWorkingDirectoryPath:(NSString *)path
{
    [workingDirectoryPath release];
    workingDirectoryPath = [path retain];
}

- (void) setEnvironmentValue:(NSString *)value forKey:(NSString *)key
{
    [environment setObject:value forKey:key];
}

- (void) setStandardInput:(NSString *)input
{
    [input writeToFile:stdInPath atomically:NO];
}

- (void) setStandardInputWithData:(NSData *)input
{
    [input writeToFile:stdInPath atomically:NO];
}

- (void) run
{
    NSTask *task = [[NSTask alloc] init];
    if (arguments) {
        [task setArguments:arguments];
    }
    if (environment) {
        [task setEnvironment:environment];
    }
    if (workingDirectoryPath) {
        [task setCurrentDirectoryPath:workingDirectoryPath];
    }
    [task setLaunchPath:launchPath];
    
    // XXX using files in /tmp is nice and all, but could leave crap laying
    // around if the program exits badly. These need to be turned to pipes
    // that gets slurped up into NSData objects...
    
    [task setStandardInput:[NSFileHandle fileHandleForReadingAtPath:stdInPath]];
    [task setStandardOutput:[NSFileHandle fileHandleForWritingAtPath:stdOutPath]];
    [task setStandardError:[NSFileHandle fileHandleForWritingAtPath:stdErrPath]];
    
    [task launch];
    [task waitUntilExit];
    terminationStatus = [task terminationStatus];
    [task release];
}

- (int) terminationStatus
{
    return terminationStatus;
}

- (NSString *)standardOutput
{
    return [NSString stringWithContentsOfFile:stdOutPath];
}

- (NSData *)standardOutputAsData
{
    return [NSData dataWithContentsOfFile:stdOutPath];
}

- (NSString *)standardError
{
    return [NSString stringWithContentsOfFile:stdErrPath];
}


@end
