#import <UnitKit/UnitKit.h>
#import <EtoileFoundation/EtoileFoundation.h>

/* Classes we use to test reflection */

@interface TestClass1 : NSObject <NSCopying>
{
	int ivar1;
}
- (id)copyWithZone: (NSZone *)zone;
@end
@implementation TestClass1
- (id)copyWithZone: (NSZone *)zone
{
	return nil;
}
@end

@interface TestClass2 : TestClass1
{
	int ivar2;
}
- (void)foo;
@end
@implementation TestClass2
- (void)foo
{
	;
}
@end

@interface TestClass3 : TestClass1
{
	@public
	double _isDouble;
	id object;
	NSRect rect;
	NSPoint _point;
	NSSize size;
	Class isClass;
	NSInteger integer;
	NSUInteger uinteger;
	int _int;
	CGFloat isFloat;
	NSRange range;
}
@end
@implementation TestClass3
@end



@interface TestReflection : NSObject <UKTest>
{
}
@end

@implementation TestReflection

- (void) testBasic
{
	id objMirror = [ETReflection reflectObject: [[NSObject alloc] init]];
	
	UKStringsEqual([[objMirror classMirror] name], @"NSObject");
	
	UKNil([[objMirror classMirror] superclassMirror]);
	
	/**
	 * Test that subclassMirrors/allSubclassMirrors works (roughly).
	 * Also test that two different class mirrors on the same class compare
	 * as equal.
	 */
	UKTrue([[[objMirror classMirror] allSubclassMirrors] containsObject:
			[ETReflection reflectClass: [NSMutableDictionary class]]]);
	
	UKFalse([[[objMirror classMirror] subclassMirrors] containsObject:
			[ETReflection reflectClass: [NSMutableDictionary class]]]);

	UKTrue([[[objMirror classMirror] subclassMirrors] containsObject:
			[ETReflection reflectClassWithName: @"NSDictionary"]]);
}

- (void) testProtocolInheritance
{
	id classMirror1 = [ETReflection reflectClassWithName: @"TestClass1"];
	id classMirror2 = [ETReflection reflectClassWithName: @"TestClass2"];

	UKTrue([[classMirror1 adoptedProtocolMirrors] containsObject:
		[ETReflection reflectProtocolWithName: @"NSCopying"]]);

	UKObjectsEqual([NSArray array],
		[classMirror2 adoptedProtocolMirrors]);

	UKTrue([[classMirror2 allAdoptedProtocolMirrors] containsObject:
		[ETReflection reflectProtocolWithName: @"NSObject"]]);
	UKTrue([[classMirror2 allAdoptedProtocolMirrors] containsObject:
		[ETReflection reflectProtocolWithName: @"NSCopying"]]);
}

- (void) testMetaClass
{
	UKFalse([[ETReflection reflectClass: [NSObject class]] isMetaClass]);
	UKTrue([[[ETReflection reflectObject: [NSObject class]] classMirror] isMetaClass]);
}

- (void) testBadValues
{
#if 0
	UKNil([ETReflection reflectClassWithName: @"ThisClassDoesNotExist"]);
	UKNil([ETReflection reflectProtocolWithName: @"ThisProtocolDoesNotExist"]);
#endif
	UKNil([ETReflection reflectObject: nil]);
	UKNil([ETReflection reflectClass: Nil]);
}

- (void) testIVars
{
	id test2 = [ETReflection reflectClass: [TestClass2 class]];
	
	UKStringsEqual(@"ivar2", [[[test2 instanceVariableMirrors] objectAtIndex: 0] name]);
	UKIntsEqual(1, [[test2 instanceVariableMirrors] count]);
	UKTrue([[test2 allInstanceVariableMirrors] count] > 2);
}

- (void) testMethods
{
	id test2 = [ETReflection reflectClass: [TestClass2 class]];
	
	UKStringsEqual(@"foo", [[[test2 methodMirrors] objectAtIndex: 0] name]);
	UKIntsEqual(1, [[test2 methodMirrors] count]);

	UKTrue([[test2 allMethodMirrors] count] > 10);

}

- (void) testInstanceVariableValueForKey
{
	TestClass3 *test3 = AUTORELEASE([[TestClass3 alloc] init]);

	ETSetInstanceVariableValueForKey(test3, @"bla", @"object");
	ETSetInstanceVariableValueForKey(test3, [self class], @"class");

	UKObjectsEqual(@"bla", test3->object);
	UKObjectsEqual([self class], test3->isClass);

	id objValue = nil;
	id classValue = nil;

	ETGetInstanceVariableValueForKey(test3, &objValue, @"object");
	ETGetInstanceVariableValueForKey(test3, &classValue, @"class");

	UKObjectsEqual(@"bla", objValue);
	UKObjectsEqual([self class], classValue);

	ETSetInstanceVariableValueForKey(test3, [NSNumber numberWithInteger: 50], @"integer");
	ETSetInstanceVariableValueForKey(test3, [NSNumber numberWithUnsignedInteger: -50], @"uinteger");
	ETSetInstanceVariableValueForKey(test3, [NSNumber numberWithInt: 2], @"int");
	ETSetInstanceVariableValueForKey(test3, [NSNumber numberWithFloat: 0.2], @"float");
	ETSetInstanceVariableValueForKey(test3, [NSNumber numberWithDouble: 1.5e+300], @"double");

	UKTrue(50 == test3->integer);
	UKTrue(-50 == test3->uinteger);
	UKIntsEqual(2, test3->_int);
	UKFloatsEqual(0.2, test3->isFloat, 0);
	UKTrue(1.5e+300 == test3->_isDouble);
	
	id integerValue = nil;
	id uintegerValue = nil;
	id intValue = nil;
	id floatValue = nil;
	id doubleValue = nil;

	ETGetInstanceVariableValueForKey(test3, &integerValue, @"integer");
	ETGetInstanceVariableValueForKey(test3, &uintegerValue, @"uinteger");
	ETGetInstanceVariableValueForKey(test3, &intValue, @"int");
	ETGetInstanceVariableValueForKey(test3, &floatValue, @"float");
	ETGetInstanceVariableValueForKey(test3, &doubleValue, @"double");

	UKTrue(50 == [integerValue integerValue]);
	UKTrue(-50 == [uintegerValue unsignedIntegerValue]);
	UKIntsEqual(2, [intValue intValue]);
	UKFloatsEqual(0.2, [floatValue floatValue], 0);
	UKTrue(1.5e+300 == [doubleValue doubleValue]);

	NSRect rect = NSMakeRect(-1, 5, 10, 20);
	NSPoint point = NSMakePoint(-3, 10);
	NSSize size = NSMakeSize(4, -10);
	NSRange range = NSMakeRange(3, 10);

	ETSetInstanceVariableValueForKey(test3, [NSValue valueWithRect: rect], @"rect");
	ETSetInstanceVariableValueForKey(test3, [NSValue valueWithPoint: point], @"point");
	ETSetInstanceVariableValueForKey(test3, [NSValue valueWithSize: size], @"size");
	ETSetInstanceVariableValueForKey(test3, [NSValue valueWithRange: range], @"range");

	UKTrue(NSEqualRects(test3->rect, rect));
	UKTrue(NSEqualPoints(test3->_point, point));
	UKTrue(NSEqualSizes(test3->size, size));
	UKTrue(NSEqualRanges(test3->range, range));

	id rectValue = nil;
	id pointValue = nil;
	id sizeValue = nil;
	id rangeValue = nil;

	ETGetInstanceVariableValueForKey(test3, &rectValue, @"rect");
	ETGetInstanceVariableValueForKey(test3, &pointValue, @"point");
	ETGetInstanceVariableValueForKey(test3, &sizeValue, @"size");
	ETGetInstanceVariableValueForKey(test3, &rangeValue, @"range");
	
	UKTrue(NSEqualRects(test3->rect, [rectValue rectValue]));
	UKTrue(NSEqualPoints(test3->_point, [pointValue pointValue]));
	UKTrue(NSEqualSizes(test3->size, [sizeValue sizeValue]));
	UKTrue(NSEqualRanges(test3->range, [rangeValue rangeValue]));
}

@end
