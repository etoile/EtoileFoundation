/*
 This source is part of UnitKit, a unit test framework for Mac OS X 
 development. You can find more information about UnitKit at:
 
 http://x180.net/Code/UnitKit
 
 Copyright (c)2004 James Duncan Davidson
 
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
#import <Foundation/Foundation.h>

/*!
 @class UKTask
 A simple class which wraps around NSTask and presents an easy to use
 interface.
 
 The environment in a UKTask is inhereted from the current environment as
 given by NSProcessInfo.
 */
@interface UKTask : NSObject {
    NSArray *arguments;
    NSString *launchPath;
    NSString *workingDirectoryPath;
    NSMutableDictionary *environment;
    NSString *stdInPath;
    NSString *stdOutPath;
    NSString *stdErrPath;
    int terminationStatus;
}

- (void) setArguments:(NSArray *)args;
- (void) setLaunchPath:(NSString *)path;
- (void) setWorkingDirectoryPath:(NSString *)path;
- (void) setEnvironmentValue:(NSString *)value forKey:(NSString *)key;
- (void) setStandardInput:(NSString *)input;
- (void) setStandardInputWithData:(NSData *)input;

- (void) run;

- (int) terminationStatus;
- (NSString *)standardOutput;
- (NSData *)standardOutputAsData;
- (NSString *)standardError;

@end
