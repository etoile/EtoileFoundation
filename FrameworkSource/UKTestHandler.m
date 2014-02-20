/*
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

#import "UKTestHandler.h"

@implementation UKTestHandler

#pragma mark - Initialization

+ (UKTestHandler *)handler
{
	static UKTestHandler *handler = nil;

	if (handler == nil)
	{
		handler = [[self alloc] init];
	}
	return handler;
}

#pragma mark - Localization Support

+ (NSString *)localizedString: (NSString *)key
{
	NSBundle *bundle = [NSBundle bundleForClass: [self class]];
	return NSLocalizedStringFromTableInBundle(key, @"UKTestHandler", bundle, @"");
}

+ (NSString *)displayStringForObject: (id)obj
{
	NSString *description = [obj description];
	// TODO: It might be nice to abbreviate the descriptions if the test passes and
	// print the whole description if the test fails. For now, always print the
	// whole description since it's very annoying to see failed tests with an
	// useless truncated description
#if 0
    if ([description hasPrefix:@"<"] && [description hasSuffix:@">"]) {
        // assume it's <Classname 0x2394920> and return
        if ([description length] < 30) {
            return description;
        } else {
            description = [description substringWithRange:NSMakeRange(0, 26)];
            description = [description stringByAppendingString:@"...>"];
            return description;
        }
    } else if ([description length] > 30) {
        description = [description substringWithRange:NSMakeRange(0, 27)];
        description = [description stringByAppendingString:@"..."];
    } 
#endif
	return [NSString stringWithFormat: @"\"%@\"", description];
}

+ (NSString *)displayStringForException: (id)exc
{
	if ([exc isKindOfClass: [NSException class]])
	{
		return [NSString stringWithFormat: @"NSException: %@ %@",
		                                   [exc name], [exc reason]];
	}
	else
	{
		return NSStringFromClass([exc class]);
	}
}

#pragma mark - Controlling Test Result Reporting

- (id)delegate
{
	return delegate;
}

- (void)setDelegate: (id)aDelegate
{
	[delegate autorelease];
	delegate = [aDelegate retain];
}

- (BOOL)isQuiet
{
	return quiet;
}

- (void)setQuiet: (BOOL)isQuiet
{
	quiet = isQuiet;
}

- (void)reportStatus: (BOOL)cond
              inFile: (const char *)filename
                line: (int)line
             message: (NSString *)msg
{
	if (delegate != nil
	  && [delegate respondsToSelector: @selector(reportStatus:inFile:line:message:)])
	{
		[delegate reportStatus: cond inFile: filename line: line message: msg];
		return;
	}
	else if (cond)
	{
		testsPassed++;

		if (!quiet)
		{
			NSLog(@"%s:%i %s\n", filename, line, [msg UTF8String]);
		}
	}
	else
	{
		testsFailed++;

		NSLog(@"%s:%i: warning: %s\n", filename, line, [msg UTF8String]);
	}
}

- (void)reportException: (NSException *)exception
                inClass: (Class)testClass
                   hint: (NSString *)hint
{
	if (delegate != nil
	  && [delegate respondsToSelector: @selector(reportException:inClass:hint:)])
	{
		[delegate reportException: exception inClass: testClass hint: hint];
	}
	else
	{
		exceptionsReported++;

		NSString *excstring = [[self class] displayStringForException: exception];
		NSString *msg = nil;

		if ([hint isEqual: @"errExceptionOnInit"] || [hint isEqual: @"errExceptionOnRelease"])
		{
			msg = [[self class] localizedString: hint];
			msg = [NSString stringWithFormat: msg, NSStringFromClass(testClass), excstring];
		}
		else
		{
			NSString *testMethodName = hint;

			msg = [[self class] localizedString: @"errExceptionInTestMethod"];
			msg = [NSString stringWithFormat: msg, NSStringFromClass(testClass),
			                                  testMethodName, excstring];
		}

		[self reportWarning: msg];
	}
}

- (void)reportWarning: (NSString *)msg
{
	if (delegate != nil && [delegate respondsToSelector: @selector(reportWarning:)])
	{
		[delegate reportWarning: msg];
	}
	else
	{
		NSLog(@":: warning: %s\n", [msg UTF8String]);
	}
}

#pragma mark - Test Results

- (int)testsPassed
{
	return testsPassed;
}

- (int)testsFailed
{
	return testsFailed;
}

- (int)exceptionsReported
{
	return exceptionsReported;
}

#pragma mark - Basic Test Assertions

- (void)passInFile: (const char *)filename
              line: (int)line
{
	NSString *msg = [UKTestHandler localizedString: @"msgUKPass"];

	[self reportStatus: YES inFile: filename line: line message: msg];
}

- (void)failInFile: (const char *)filename
              line: (int)line
{
	NSString *msg = [UKTestHandler localizedString: @"msgUKFail"];

	[self reportStatus: NO inFile: filename line: line message: msg];
}

#pragma mark - Primitive Test Assertions

- (void)testTrue: (BOOL)cond
          inFile: (const char *)filename
            line: (int)line
{
	if (cond)
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKTrue.pass"];

		[self reportStatus: YES inFile: filename line: line message: msg];
	}
	else
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKTrue.fail"];

		[self reportStatus: NO inFile: filename line: line message: msg];
	}
}

- (void)testFalse: (BOOL)cond
           inFile: (const char *)filename
             line: (int)line
{
	if (!cond)
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKFalse.pass"];

		[self reportStatus: YES inFile: filename line: line message: msg];
	}
	else
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKFalse.fail"];

		[self reportStatus: NO inFile: filename line: line message: msg];
	}
}

- (void)testNil: (void *)ref
         inFile: (const char *)filename
           line: (int)line
{
	if (ref == nil)
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKNil.pass"];

		[self reportStatus: YES inFile: filename line: line message: msg];
	}
	else
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKNil.fail"];
		// FIXME: We are *so* assuming that this pointer is an object...
		NSString *s = [UKTestHandler displayStringForObject: ref];
		msg = [NSString stringWithFormat: msg, s];

		[self reportStatus: NO inFile: filename line: line message: msg];
	}
}

- (void)testNotNil: (void *)ref
            inFile: (const char *)filename
              line: (int)line
{
	if (ref != nil)
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKNotNil.pass"];
		// FIXME: We are *so* assuming that this pointer is an object...
		NSString *s = [UKTestHandler displayStringForObject: ref];
		msg = [NSString stringWithFormat: msg, s];

		[self reportStatus: YES inFile: filename line: line message: msg];
	}
	else
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKNotNil.fail"];

		[self reportStatus: NO inFile: filename line: line message: msg];
	}
}

#pragma mark - Primitive Number Test Assertions

- (void)testInt: (int)a
        equalTo: (int)b
         inFile: (const char *)filename
           line: (int)line
{
	if (a == b)
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKIntsEqual.pass"];
		msg = [NSString stringWithFormat: msg, a, b];

		[self reportStatus: YES inFile: filename line: line message: msg];
	}
	else
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKIntsEqual.fail"];
		msg = [NSString stringWithFormat: msg, a, b];

		[self reportStatus: NO inFile: filename line: line message: msg];
	}
}

- (void)testInt: (int)a
     notEqualTo: (int)b
         inFile: (const char *)filename
           line: (int)line
{
	if (a != b)
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKIntsNotEqual.pass"];
		msg = [NSString stringWithFormat: msg, a, b];

		[self reportStatus: YES inFile: filename line: line message: msg];
	}
	else
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKIntsNotEqual.fail"];
		msg = [NSString stringWithFormat: msg, a, b];

		[self reportStatus: NO inFile: filename line: line message: msg];
	}
}

- (void)testFloat: (float)a
          equalTo: (float)b
            delta: (float)delta
           inFile: (const char *)filename
             line: (int)line
{
	// TODO: Need to figure out how to report the numbers in such a way that
	// they are shortened to the degree of precision...
	float c = fabs(a - b);

	if (c <= delta)
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKFloatsEqual.pass"];
		msg = [NSString stringWithFormat: msg, a - delta, a + delta, b];

		[self reportStatus: YES inFile: filename line: line message: msg];
	}
	else
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKFloatsEqual.fail"];
		msg = [NSString stringWithFormat: msg, a - delta, a + delta, b];

		[self reportStatus: NO inFile: filename line: line message: msg];
	}
}

- (void)testFloat: (float)a
       notEqualTo: (float)b
            delta: (float)delta
           inFile: (const char *)filename
             line: (int)line
{
	// TODO: Need to figure out how to report the numbers in such a way that
	// they are shortened to the degree of precision...
	float c = fabs(a - b);

	if (c > delta)
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKFloatsNotEqual.pass"];
		msg = [NSString stringWithFormat: msg, a - delta, a + delta, b];

		[self reportStatus: YES inFile: filename line: line message: msg];
	}
	else
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKFloatsNotEqual.fail"];
		msg = [NSString stringWithFormat: msg, a - delta, a + delta, b];

		[self reportStatus: NO inFile: filename line: line message: msg];
	}
}

#pragma mark - Object Test Assertions

- (void)testObject: (id)a
            kindOf: (id)b
            inFile: (const char *)filename
              line: (int)line
{
	NSString *dispA = [UKTestHandler displayStringForObject: [a class]];
	NSString *dispB = [UKTestHandler displayStringForObject: b];

	if ([a isKindOfClass: b])
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKObjectKindOf.pass"];
		msg = [NSString stringWithFormat: msg, dispB, dispA];

		[self reportStatus: YES inFile: filename line: line message: msg];
	}
	else
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKObjectKindOf.fail"];
		msg = [NSString stringWithFormat: msg, dispB, dispA];

		[self reportStatus: NO inFile: filename line: line message: msg];
	}
}

- (void)testObject: (id)a equalTo: (id)b inFile: (const char *)filename line: (int)line
{
	NSString *dispA = [UKTestHandler displayStringForObject: a];
	NSString *dispB = [UKTestHandler displayStringForObject: b];

	if ([a isEqual: b])
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKObjectsEqual.pass"];
		msg = [NSString stringWithFormat: msg, dispA, dispB];

		[self reportStatus: YES inFile: filename line: line message: msg];
	}
	else
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKObjectsEqual.fail"];
		msg = [NSString stringWithFormat: msg, dispA, dispB];

		[self reportStatus: NO inFile: filename line: line message: msg];
	}
}

- (void)testObject: (id)a
        notEqualTo: (id)b
            inFile: (const char *)filename
              line: (int)line
{
	NSString *dispA = [UKTestHandler displayStringForObject: a];
	NSString *dispB = [UKTestHandler displayStringForObject: b];

	if (![a isEqual: b])
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKObjectsNotEqual.pass"];
		msg = [NSString stringWithFormat: msg, dispA, dispB];

		[self reportStatus: YES inFile: filename line: line message: msg];
	}
	else
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKObjectsNotEqual.fail"];
		msg = [NSString stringWithFormat: msg, dispA, dispB];

		[self reportStatus: NO inFile: filename line: line message: msg];
	}
}

- (void)testObject: (id)a
            sameAs: (id)b
            inFile: (const char *)filename
              line: (int)line
{
	NSString *dispA = [UKTestHandler displayStringForObject: a];
	NSString *dispB = [UKTestHandler displayStringForObject: b];

	if (a == b)
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKObjectsSame.pass"];
		msg = [NSString stringWithFormat: msg, dispA, dispB];

		[self reportStatus: YES inFile: filename line: line message: msg];
	}
	else
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKObjectsSame.fail"];
		msg = [NSString stringWithFormat: msg, dispA, dispB];

		[self reportStatus: NO inFile: filename line: line message: msg];
	}
}

- (void)testObject: (id)a
         notSameAs: (id)b
            inFile: (const char *)filename
              line: (int)line
{
	NSString *dispA = [UKTestHandler displayStringForObject: a];
	NSString *dispB = [UKTestHandler displayStringForObject: b];

	if (a != b)
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKObjectsNotSame.pass"];
		msg = [NSString stringWithFormat: msg, dispA, dispB];

		[self reportStatus: YES inFile: filename line: line message: msg];
	}
	else
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKObjectsNotSame.fail"];
		msg = [NSString stringWithFormat: msg, dispA, dispB];

		[self reportStatus: NO inFile: filename line: line message: msg];
	}
}

#pragma mark - String Test Assertions

- (void)testString: (NSString *)a
           equalTo: (NSString *)b
            inFile: (const char *)filename
              line: (int)line
{
	NSString *dispA = [UKTestHandler displayStringForObject: a];
	NSString *dispB = [UKTestHandler displayStringForObject: b];

	if ([a isEqualToString: b])
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKStringsEqual.pass"];
		msg = [NSString stringWithFormat: msg, dispA, dispB];

		[self reportStatus: YES inFile: filename line: line message: msg];
	}
	else
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKStringsEqual.fail"];
		msg = [NSString stringWithFormat: msg, dispA, dispB];

		[self reportStatus: NO inFile: filename line: line message: msg];
	}
}

- (void)testString: (NSString *)a notEqualTo: (NSString *)b inFile: (const char *)filename line: (int)line
{
	NSString *dispA = [UKTestHandler displayStringForObject: a];
	NSString *dispB = [UKTestHandler displayStringForObject: b];

	if (![a isEqualToString: b])
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKStringsNotEqual.pass"];
		msg = [NSString stringWithFormat: msg, dispA, dispB];

		[self reportStatus: YES inFile: filename line: line message: msg];
	}
	else
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKStringsNotEqual.fail"];
		msg = [NSString stringWithFormat: msg, dispA, dispB];

		[self reportStatus: NO inFile: filename line: line message: msg];
	}
}

- (void)testString: (NSString *)a
          contains: (NSString *)b
            inFile: (const char *)filename
              line: (int)line
{
	NSString *dispA = [UKTestHandler displayStringForObject: a];
	NSString *dispB = [UKTestHandler displayStringForObject: b];

	if ([a rangeOfString: b].location != NSNotFound)
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKStringContains.pass"];
		msg = [NSString stringWithFormat: msg, dispA, dispB];

		[self reportStatus: YES inFile: filename line: line message: msg];
	}
	else
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKStringContains.fail"];
		msg = [NSString stringWithFormat: msg, dispA, dispB];

		[self reportStatus: NO inFile: filename line: line message: msg];
	}
}

- (void)testString: (NSString *)a
    doesNotContain: (NSString *)b
            inFile: (const char *)filename
              line: (int)line
{
	NSString *dispA = [UKTestHandler displayStringForObject: a];
	NSString *dispB = [UKTestHandler displayStringForObject: b];

	if ([a rangeOfString: b].location == NSNotFound)
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKStringDoesNotContain.pass"];
		msg = [NSString stringWithFormat: msg, dispA, dispB];

		[self reportStatus: YES inFile: filename line: line message: msg];
	}
	else
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKStringDoesNotContain.fail"];
		msg = [NSString stringWithFormat: msg, dispA, dispB];

		[self reportStatus: NO inFile: filename line: line message: msg];
	}
}

#pragma mark - Exception Test Assertions

- (void)raisesException: (NSException *)exception
                 inFile: (const char *)filename
                   line: (int)line
{
	if (exception != nil)
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKExceptionRaised.pass"];
		msg = [NSString stringWithFormat: msg, [[exception class] description]];

		[self reportStatus: YES inFile: filename line: line message: msg];
	}
	else
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKExecptionRaised.fail"];

		[self reportStatus: NO inFile: filename line: line message: msg];
	}
}

- (void)doesNotRaisesException: (NSException *)exception
                        inFile: (const char *)filename
                          line: (int)line
{
	if (exception == nil)
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKExceptionNotRaised.pass"];

		[self reportStatus: YES inFile: filename line: line message: msg];
	}
	else
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKExceptionNotRaised.fail"];
		msg = [NSString stringWithFormat: msg, [[exception class] description]];

		[self reportStatus: NO inFile: filename line: line message: msg];
	}
}

- (void)raisesException: (NSException *)exception
                  named: (NSString *)expected
                 inFile: (const char *)filename
                   line: (int)line;
{
	if (![exception isKindOfClass: [NSException class]])
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKSpecificNSExceptionRaised.failNotNSException"];
		msg = [NSString stringWithFormat: msg, [exception description]];

		[self reportStatus: NO inFile: filename line: line message: msg];
	}
	else if ([[exception name] isEqualToString: expected])
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKSpecificNSExceptionRaised.pass"];
		msg = [NSString stringWithFormat: msg, expected];

		[self reportStatus: YES inFile: filename line: line message: msg];
	}
	else
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKSpecificNSExceptionRaised.fail"];
		msg = [NSString stringWithFormat: msg, expected, [exception name]];

		[self reportStatus: NO inFile: filename line: line message: msg];
	}
}

- (void)raisesException: (id)raisedObject
                  class: (Class)expectedClass
                 inFile: (const char *)filename
                   line: (int)line
{
	if ([raisedObject isKindOfClass: expectedClass])
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKRaisesSpecificClass.pass"];
		msg = [NSString stringWithFormat: msg, [expectedClass description]];

		[self reportStatus: YES inFile: filename line: line message: msg];
	}
	else
	{
		NSString *msg = [UKTestHandler localizedString: @"msgUKRaisesSpecificClass.fail"];
		msg = [NSString stringWithFormat: msg, [expectedClass description],
		                                       [[raisedObject class] description]];

		[self reportStatus: NO inFile: filename line: line message: msg];
	}
}

@end
