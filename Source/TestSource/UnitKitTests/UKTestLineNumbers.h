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
 Tests to make sure that the line numbers reported by the various macros make
 it through the macro and through the test handler methods in UKTestHandler. 
 This is done by setting this class to be the UKTestHandler's delegate, 
 performing a test, and then setting the UKTestHandler's delegeate to nil so
 that the normal reporting mechanism is back in place.
 
 Because the code paths in the various test methods are conditional, both
 positive and negative tests are performed on each macro.
 */

@interface UKTestLineNumbers : NSObject <UKTest> {
    UKTestHandler *handler;
    int reportedLine;
}

@end
