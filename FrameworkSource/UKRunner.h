/**
	Copyright (C) 2004 James Duncan Davidson, Nicolas Roard, Quentin Mathe, Christopher Armstrong, Eric Wasylishen

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
 * @abstract UKTestRunner runs the test suite(s) and reports the results. 
 *
 * Usually you are not expected to use UKRunner directly to run a test suite, 
 * but to use <em>ukrun</em> that will ask UKRunner to do it with +runTests.
 *
 * @section Test Bundle Loading and Argument Parsing
 *
 * UKRunner will parse arguments from the command-line bound to 
 * -[UKTestHandler isQuiet] and -[UKRunner classRegex], and can load one or 
 * multiple test bundles, either passed among the arguments or to 
 * -runTestsInBundle:principalClass: (if you use the API directly instead of 
 * <em>ukrun</em>).
 *
 * @section Collecting Test Classes
 *
 * For each test bundle, UKRunner collects test classes marked with UKTest. 
 * If you don't use a test bundle, test classes can be passed explicitly with 
 * -runTestsWithClassNames:principalClass:.
 *
 * If -classRegex is set, not all the test classes passed to UKRunner API will 
 * be run, but just the subset whose name matches the regex.
 *
 * @section Executing Test Methods
 *
 * A test method is a method prefixed with <em>test</em> e.g. -testSometing.
 *
 * For each class marked with UKTest and each test method in this class (this 
 * also includes all the inherited test methods up to the superclass that 
 * conforms to UKTest), UKRunner will create an instance and invoke the test 
 * method, then release the instance, then create a new instance for the next 
 * test method, and so on. For details, see -runTests:onInstance:ofClass:.
 *
 * UKRunner also supports test class methods e.g. +testSomething.
 *
 * The test methods are executed in their alphabetical order.
 *
 * @section Notifications
 *
 * Each time methods -runTestsWithClassNames:principalClass: and 
 * -runTestsInBundle:principalClass: are invoked, the runner calls 
 * +willRunTestSuite and +didRunTestSuite on the principal class, and runs the 
 * test suite between them.
 *
 * For common use cases, see +[NSObject willRunTestSuite]. 
 */
@interface UKRunner : NSObject
{
	@private
   	NSString *classRegex;
	int testClassesRun;
	int testMethodsRun;
}


/** @taskunit Settings */


/**
 * Returns the regex string used to match classes to be tested (among the 
 * classes that conforms to UKTest).
 *
 * This is useful to run a test suite subset. For example, just a single class 
 * <code>TestB</code>, a class list <code>TestA|TestB|TestN</code> or a 
 * pattern-based list <code>Test*Persistency</code>.
 *
 * -classRegex is initialized to the value of the argument <em>-c</em> present 
 * in the <em>ukrun</em> arguments.
 *
 * See also -setClassRegex:.
 */
- (NSString *)classRegex;
/**
 * Sets the regex string used to match classes to be tested (among the 
 * classes that conforms to UKTest).
 *
 * See also -classRegex.
 */
- (void)setClassRegex: (NSString *)aRegex;


/** @taskunit Tool Support */


/**
 * Creates a new runner and uses it to run the tests based on the command-line
 * arguments.
 *
 * For all the test bundles collected (or provided as arguments), this method
 * uses -runTestsInBundleAtPath:currrentDirectory: to run the tests contained 
 * in each one. When all test bundles have been run, -reportTestResults is
 * called to output the combined results.
 *
 * ukrun main() creates an autorelease pool, and uses this method to run the
 * tests.
 */
+ (int)runTests;
/**
 * Loads the given test bundle, and runs all its tests.
 *
 * If the bundle path is not an absolute path, the method searches the test
 * bundles to load in the given directory (the current directory, when +runTests
 * is used).
 */
- (void)runTestsInBundleAtPath: (NSString *)bundlePath
              currentDirectory: (NSString *)cwd;


/** @taskunit Running Tests */


/**
 * Runs all the tests in the given test bundle.
 *
 * This method behaves the same than -runTestsWithClassNames:principalClass:, 
 * with the test bundle principal class as the test suite principal class.
 */
- (void)runTestsInBundle: (NSBundle *)bundle;
/**
 * Runs all the tests in the tested classes in the given test bundle.
 *
 * For test related configuration, +willRunTestSuite and +didRunTestSuite
 * are sent to the principal class, see NSObject(UKPrincipalClassNotifications).
 *
 * If testedClasses is nil, then it is the same than passing all the test
 * classes present in the bundle.
 *
 * This method and -runTestsInBundle: represents a test suite invocation.
 */
- (void)runTestsWithClassNames: (NSArray *)testClasses
                principalClass: (Class)principalClass;
/**
 * Runs the test methods against a test instance or class object. 
 *
 * testMethods contains the method names to execute on the test object or class 
 * object. If instance is YES, testMethods must contain instance methods, 
 * otherwise it must contain class methods (to be called directly on the test 
 * class).
 * 
 * For each method in the list, the test object will be initialized with -init,
 * and the test method called on it, then the test object will be released (and 
 * usually deallocated).
 *
 * If there is a problem with the test object initialization or release (once 
 * the test method returns the control), an uncaught exception will be reported 
 * and the test execution on this test object will end (other test methods 
 * are skipped). 
 *
 * If there is an exception while running a test method, an uncaught exception 
 * will be reported and execution will move on to the next test method.
 */
- (void)runTests: (NSArray *)testMethods
      onInstance: (BOOL)instance
         ofClass: (Class)testClass;


/** @taskunit Test Reporting */


/**
 * Logs a summary that reports the current run results:
 *
 * <list>
 * <item>how many test classes and test methods were executed</item>
 * <item>how many tests failed and passed</item>
 * <item>how many uncaught exceptions occurred</item>
 * </list>
 *
 * If no tests failed and no uncaught exceptions occured, returns 0 to indicate
 * success, otherwise returns -1.
 */
- (int)reportTestResults;

@end

/**
 * @abstract Test suite related notifications.
 *
 * These delegate methods can be implemented in the principal class. See the 
 * Notifications section in UKRunner class description. 
 */
@interface NSObject (UKPrincipalClassNotifications)
/**
 * Tells the principal class that the test suite is about to start.
 * 
 * The principal class comes from the test bundle Info.plist, 
 * -runTestsInBundle:principalClass: or -runTestsWithClassNames:principalClass: 
 * (if these last two methods are called directly without using <em>ukrun</em>).
 *
 * You can implement this method to set up some global state (e.g. create a  
 * NSApp object with +[NSApplication sharedApplication]) or test configuration.
 *
 * See also +didRunTestSuite.
 */
+ (void)willRunTestSuite;
/**
 * Tells the principal class that the test suite is about to end.
 *
 * You can implement this method to reset some global state or test 
 * configuration, previously adjusted in +willRunTestSuite, and also to report 
 * additional test results (e.g. benchmark results).
 * 
 * See also +willRunTestSuite.
 */
+ (void)didRunTestSuite;
@end

/**
 * Returns all the test classes present in the given bundle, and sorted by name.
 *
 * To be a test class, a class (or its superclass) must conform to UKTest 
 * protocol.
 */
NSArray *UKTestClasseNamesFromBundle (NSBundle *bundle);
/**
 * Returns all the test method names sorted by name, for the given class.
 *
 * All the superclass methods are collected (until the root class is reached).
 */
NSArray *UKTestMethodNamesFromClass(Class c);
