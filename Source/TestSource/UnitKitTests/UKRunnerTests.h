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
#import <UnitKit/UnitKit.h>

/*
 Testing a test runner is a bit of a funky proposition. After all, it's a
 snake eating its tail kind of affair. However, it's done here by testing out
 the most critical functionality of the class--finding the test classes in a
 bundle and the test methods in a class--as well as running a test bundle
 from the outside and examining its output. Even though this isn't as fine
 grained a testing strategy as one might like, it will catch everything we
 need to catch. And hey, if the runner isn't working, then these tests won't
 even be run, right??? :)
 */

@interface UKRunnerTests : NSObject <UKTest> {
    NSBundle *testBundle;
}

@end
