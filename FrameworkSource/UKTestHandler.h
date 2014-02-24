/**
	Copyright (C) 2004 James Duncan Davidson, Michael Milvich, Mark Dalrymple, Nicolas Roard, Quentin Mathe

	License:  Apache License, Version 2.0  (see LICENSE)
 
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

/**
 * @abstract UKTestHandler implements the test assertions built into UnitKit
 * and support to report the results
 *
 * For each test assertion invoked on the test handler, the handler collects
 * the result and reports it or not based on the reporting settings.
 *
 * At any time, you can query the current test results using -testsPassed,
 * -testsFailed and -exceptionsReported, for all the test assertions invoked
 * since the test handler has been created.
 *
 * A single test handler exists for all UKRunner instances. For multiple run
 * test requests against UKRunner instances, all test results are reported
 * together.
*/
@interface UKTestHandler : NSObject
{
	@private
	id delegate;
	int testsPassed;
	int testsFailed;
	int exceptionsReported;
	BOOL quiet;
}


/** @taskunit Initialization */


/**
 * Returns the shared test handler.
 */
+ (UKTestHandler *)handler;


/** @taskunit Controlling Test Result Reporting */


/**
 * Returns a delegate that can implement the same reporting methods than
 * UKTestHandler.
 *
 * By default, returns nil.
 *
 * For more details, see -setDelegate:.
 */
- (id)delegate;
/**
 * Sets a delegate that can implement the same reporting methods than
 * UKTestHandler.
 *
 * If the delegate implements a reporting method, it takes priority over
 * UKTestHandler.
 * As a result, what was previously reported by UKTestHandler is not going to
 * be automatically logged in the console unless the delegate does it.
 */
- (void)setDelegate: (id)aDelegate;
/**
 * Returns whether the handler to report just the test failures and uncaught
 * exceptions, and nothing on test successes.
 *
 * By default, returns NO.
 *
 * -isQuiet is initialized to YES if the argument '-q' is present in the 
 * 'ukrun' arguments.
 */
- (BOOL)isQuiet;
/**
 * Tells the handler to report just the test failures and uncaught exceptions,
 * and nothing on test successes.
 */
- (void)setQuiet: (BOOL)isQuiet;
/**
 * If we have a delegate, then by all means use it. If we don't, then check to
 * see if we have any errors which should be reported off to std out.
 */
- (void)reportStatus: (BOOL)cond
              inFile: (const char *)filename
                line: (int)line
             message: (NSString *)msg;
/**
 * Reports an uncaught exception and a hint that represents the context in
 * which the exception was raised.
 *
 * To indicate the context, three hints are supported:
 *
 * <deflist>
 * <term>errExceptionOnInit</term><desc>inside -init on a test object</desc>
 * <term>errExceptionOnRelease</term><desc>inside -dealloc on a test object</desc>
 * <term>a test method name</term><desc>inside a test method</desc>
 * </deflist>
 *
 * By default, forwards the message to the delegate if there is one, otherwise
 * uses -reportWarning: to print the exception reason.
 */
- (void)reportException: (NSException *)exception
                inClass: (Class)testClass
                   hint: (NSString *)hint;
/**
 * Reports a warning message.
 *
 * By default, forwards the message to the delegate if there is one, otherwise
 * uses NSLog() to print the message.
 *
 * This method is used by -reportStatus:inFile:line:message: and
 * -reportException:inClass:hint: to report test failures and uncaught exceptions.
 */
- (void)reportWarning: (NSString *)message;


/** @taskunit Test Results */


/**
 * Returns the current number of test successes.
 *
 * See -reportStatus:inFile:line:message:.
 */
- (int)testsPassed;
/**
 * Returns the current number of test failures.
 *
 * See -reportStatus:inFile:line:message:.
 */
- (int)testsFailed;
/**
 * Returns the current number of exceptions caught by UKRunner and reported to
 * the test handler.
 *
 * See -reportException:inClass:hint:.
 */
- (int)exceptionsReported;


/** @taskunit Basic Test Assertions */


- (void)passInFile: (const char *)filename
              line: (int)line;
- (void)failInFile: (const char *)filename
              line: (int)line;


/** @taskunit Primitive Test Assertions */


- (void)testTrue: (BOOL)cond
          inFile: (const char *)filename
            line: (int)line;
- (void)testFalse: (BOOL)cond
           inFile: (const char *)filename
             line: (int)line;
- (void)testNil: (void *)ref
         inFile: (const char *)filename
           line: (int)line;
- (void)testNotNil: (void *)ref
            inFile: (const char *)filename
              line: (int)line;


/** @taskunit Number Primitive Test Assertions */


- (void)testInt: (int)a
        equalTo: (int)b
         inFile: (const char *)filename
           line: (int)line;
- (void)testInt: (int)a
     notEqualTo: (int)b
         inFile: (const char *)filename
           line: (int)line;
- (void)testFloat: (float)a
          equalTo: (float)b
            delta: (float)delta
           inFile: (const char *)filename
             line: (int)line;
- (void)testFloat: (float)a
       notEqualTo: (float)b
            delta: (float)delta
           inFile: (const char *)filename
             line: (int)line;


/** @taskunit Object Test Assertions */


- (void)testObject: (id)a
            kindOf: (id)b
            inFile: (const char *)filename
              line: (int)line;
- (void)testObject: (id)a
           equalTo: (id)b
            inFile: (const char *)filename
              line: (int)line;
- (void)testObject: (id)a
        notEqualTo: (id)b
            inFile: (const char *)filename
              line: (int)line;
- (void)testObject: (id)a
            sameAs: (id)b
            inFile: (const char *)filename
              line: (int)line;
- (void)testObject: (id)a
         notSameAs: (id)b
            inFile: (const char *)filename
              line: (int)line;


/** @taskunit String Test Assertions */


- (void)testString: (NSString *)a
           equalTo: (NSString *)b
            inFile: (const char *)filename
              line: (int)line;
- (void)testString: (NSString *)a
        notEqualTo: (NSString *)b
            inFile: (const char *)filename
              line: (int)line;
- (void)testString: (NSString *)a
          contains: (NSString *)b
            inFile: (const char *)filename
              line: (int)line;
- (void)testString: (NSString *)a
    doesNotContain: (NSString *)b
            inFile: (const char *)filename
              line: (int)line;


/** @taskunit Exception Test Assertions */


- (void)raisesException: (NSException *)exception
                 inFile: (const char *)filename
                   line: (int)line;
- (void)doesNotRaisesException: (NSException *)exception
                        inFile: (const char *)filename
                          line: (int)line;
- (void)raisesException: (NSException *)exception
                  named: (NSString *)expected
                 inFile: (const char *)filename
                   line: (int)line;
- (void)raisesException: (id)raisedObject
                  class: (Class)expectedClass
                 inFile: (const char *)filename
                   line: (int)line;

@end
