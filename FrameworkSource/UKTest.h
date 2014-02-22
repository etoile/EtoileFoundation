/**
	Copyright (C) 2004 James Duncan Davidson, Michael Milvich, Nicolas Roard

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

#import <Foundation/NSObject.h>

/**
 * @abstract The protocol that marks a class as a test class.
 *
 * All classes that conforms to UKTest, including their subclasses, are picked 
 * up by UKRunner.
 *
 * If a filtering option such as -c is passed to <em>ukrun</em>, this can 
 * prevent the a test class to be picked up.
 */
@protocol UKTest
@end

/**
 * Reports a success.
 */
#define UKPass() [[UKTestHandler handler] passInFile:__FILE__ line:__LINE__]
/**
 * Reports a failure.
 */
#define UKFail() [[UKTestHandler handler] failInFile:__FILE__ line:__LINE__]
/**
 * Tests that an expression is true.
 */
#define UKTrue(condition) [[UKTestHandler handler] testTrue:(condition) inFile:__FILE__ line:__LINE__]
/**
 * Tests that an expression is false.
 */
#define UKFalse(condition) [[UKTestHandler handler] testFalse:(condition) inFile:__FILE__ line:__LINE__]
/**
 * Tests that <code>ref == nil</code>.
 */
#define UKNil(ref) [[UKTestHandler handler] testNil: (void *)(ref) inFile:__FILE__ line:__LINE__] 
/**
 * Tests that <code>ref != nil</code>.
 */
#define UKNotNil(ref) [[UKTestHandler handler] testNotNil: (void *)(ref) inFile:__FILE__ line:__LINE__]
/**
 * Tests that two primitive integers are equal.
 *
 * a is the expected value and b the tested value.
 */
#define UKIntsEqual(a, b) [[UKTestHandler handler] testInt:(a) equalTo:(b) inFile:__FILE__ line:__LINE__]
/**
 * Tests that two primitive integers are not equal.
 *
 * a is the non-expected value and b the tested value.
 */
#define UKIntsNotEqual(a, b) [[UKTestHandler handler] testInt:(a) notEqualTo:(b) inFile:__FILE__ line:__LINE__]
/**
 * Tests that two primitive floats are equal or almost, this evaluates whether 
 * <code>fabs(a - b) &lt;= d</code> is true.
 *
 * d is the error margin.
 *
 * a is the expected value and b the tested value.
 */
#define UKFloatsEqual(a, b, d) [[UKTestHandler handler] testFloat:(a) equalTo:(b) delta:(d) inFile:__FILE__ line:__LINE__]
/**
 * Tests that two primitive floats are not equal, this evaluates whether 
 * <code>fabs(a - b) &gt; d</code> is true. 
 *
 * d is the error margin.
 *
 * a is the non-expected value and b the tested value.
 */
#define UKFloatsNotEqual(a, b, d) [[UKTestHandler handler] testFloat:(a) notEqualTo:(b) delta:(d) inFile:__FILE__ line:__LINE__]
/**
 * Tests macro that a is a subclass of b, this uses -[NSObject isKindOfClass:] 
 * behind the scene. 
 *
 * Most of the time <code>UKObjectsEqual([a class], [b class])</code> would be 
 * similar, but not always (i.e. NSCFArray/NSArray on Mac OS X). Example:
 *
 * <example>
 * UKObjectKindOf(myObject, NSArray)
 * </example>
 */
#define UKObjectKindOf(a, b) [[UKTestHandler handler] testObject:(a) kindOf:[b class] inFile:__FILE__ line:__LINE__]
/**
 * Tests that <code>[a isEqual: b]</code>.
 *
 * a is the expected value and b the tested value.
 */
#define UKObjectsEqual(a, b) [[UKTestHandler handler] testObject:(a) equalTo:(b) inFile:__FILE__ line:__LINE__]
/**
 * Tests that <code>![a isEqual: b]</code>.
 *
 * a is the non-expected value and b the tested value.
 */
#define UKObjectsNotEqual(a, b) [[UKTestHandler handler] testObject:(a) notEqualTo:(b) inFile:__FILE__ line:__LINE__]
/**
 * Tests that the objects are identical with <code>a == b</code>.
 *
 * a is the expected value and b the tested value.
 */
#define UKObjectsSame(a, b) [[UKTestHandler handler] testObject:(a) sameAs:(b) inFile:__FILE__ line:__LINE__]
/**
 * Tests that the objects are not identical with a != b.
 *
 * a is the non-expected value and b the tested value.
 */
#define UKObjectsNotSame(a, b) [[UKTestHandler handler] testObject:(a) notSameAs:(b) inFile:__FILE__ line:__LINE__]
/**
 * Tests that <code>[a isEqual: b]</code>.
 *
 * a is the expected value and b the tested value.
 *
 * This is the same than UKObjectsEqual(), this just helps readibility a bit, 
 * since testing string equality is pretty common.
 */
#define UKStringsEqual(a, b) [[UKTestHandler handler] testString:(a) equalTo:(b) inFile:__FILE__ line:__LINE__]
/**
 * Tests that <code>![a isEqual: b]</code>.
 *
 * a is the non-expected value and b the tested value.
 *
 * This is the same than UKObjectsNotEqual(), this just helps readibility a bit, 
 * since testing string equality is pretty common.
 */
#define UKStringsNotEqual(a, b) [[UKTestHandler handler] testString:(a) notEqualTo:(b) inFile:__FILE__ line:__LINE__]
/**
 * Tests that b is a substring of a, this uses -[NSString rangeOfString:].
 */
#define UKStringContains(a, b) [[UKTestHandler handler] testString:(a) contains:(b) inFile:__FILE__ line:__LINE__]
/**
 * Tests that b is not a substring of a, this uses -[NSString rangeOfString:].
 */
#define UKStringDoesNotContain(a, b) [[UKTestHandler handler] testString:(a) doesNotContain:(b) inFile:__FILE__ line:__LINE__]
/** Tests that the code piece raises an exception.

The exception testing macros get a bit more involved than all the other ones 
we have here because of the need for embedding the try-catch in the generated 
code. In addition, the statements are wrapped in a do{...}while(NO) block so 
that the generated code is sane even if the macro appears in a context like: 

<example>
 if (someFlag)
    UKRaisesException(someExpression)
 else
    UKRaisesException(someOtherExpression)
</example> */
#define UKRaisesException(a) do{id p_exp = nil; @try { a; } @catch(id exp) { p_exp = exp; } [[UKTestHandler handler] raisesException:p_exp inFile:__FILE__ line:__LINE__]; } while(NO)
/** Tests that the code piece raises no exception.

See also UKRaisesException(). */
#define UKDoesNotRaiseException(a) do{id p_exp = nil; @try { a; } @catch(id exp) { p_exp = exp; } [[UKTestHandler handler] doesNotRaisesException:p_exp inFile:__FILE__ line:__LINE__]; } while(NO)
/** Tests that the code piece raises an exception of the name b.

See also -[NSException name]. */
#define UKRaisesExceptionNamed(a, b) do{ id p_exp = nil; @try{ a; } @catch(id exp) { p_exp = exp;}[[UKTestHandler handler] raisesException:p_exp named:b inFile:__FILE__ line:__LINE__]; } while(NO)
/** Tests that the code piece raises an exception of the class name b.

See NSException. */
#define UKRaisesExceptionClass(a, b) do{ id p_exp = nil; @try{ a; } @catch(id exp) { p_exp = exp;}[[UKTestHandler handler] raisesException:p_exp class:[b class] inFile:__FILE__ line:__LINE__]; } while(NO)
