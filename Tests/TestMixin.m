#import <Foundation/Foundation.h>
#import <UnitKit/UnitKit.h>
#import "NSObject+Mixins.h"
#import "ETCollection.h"
#import "Macros.h"

#pragma clang diagnostic ignored "-Wprotocol"

@interface TestBasicTrait : NSObject <UKTest>
@end

@interface TestComplexTrait : NSObject <UKTest>
@end

@interface TestBasicTrait (BasicTrait)
- (void) bip;
- (NSString *) wanderWhere: (NSUInteger)aLocation;
- (BOOL) isOrdered;
@end

@interface TestComplexTrait (ComplexTrait)
- (NSString *) wanderWhere: (NSUInteger)aLocation;
- (BOOL) isOrdered;
- (int) intValue;
@end

#if 0
@interface TestBasicMixin : NSObject <UKTest>
@end

@interface TestComplexMixin : NSObject <UKTest>
@end

@interface TestMixinSequence : NSObject <UKTest>
@end

@interface TestBasicMixin (BasicTrait)
- (void) bip;
- (NSString *) wanderWhere: (NSUInteger)aLocation;
- (BOOL) isOrdered;
- (NSString *) hello;
@end

@interface TestComplexMixin (ComplexTrait)
- (NSString *) wanderWhere: (NSUInteger)aLocation;
- (BOOL) isOrdered;
- (int) intValue;
@end

@interface TestMixinSequence (ComplexTraitFollowedByBasicTrait)
- (void) bip;
- (NSString *) wanderWhere: (NSUInteger)aLocation;
- (BOOL) isOrdered;
- (int) intValue;
@end
#endif

/* Trait and Mixin Declarations */

@interface BasicTrait : NSObject
- (void) bip;
- (NSString *) wanderWhere: (NSUInteger)aLocation;
- (BOOL) isOrdered;
@end

@interface ComplexTrait : BasicTrait
- (NSString *) wanderWhere: (NSUInteger)aLocation;
- (int) intValue;
@end

/* Test Suite */

@implementation TestBasicTrait

- (BOOL) isOrdered
{
	return YES;
}

- (void) testApplyBasicTrait
{
	[[self class] applyTraitFromClass: [BasicTrait class]];

	UKTrue([self respondsToSelector: @selector(bip)]);
	UKStringsEqual(@"Nowhere", [self wanderWhere: 5]);
	UKTrue([self isOrdered]);
}

@end

@implementation TestComplexTrait

- (BOOL) isOrdered
{
	return YES;
}

- (void) testApplyComplexTrait
{
	[[self class] applyTraitFromClass: [ComplexTrait class]];

	UKFalse([self respondsToSelector: @selector(bip)]);
	UKStringsEqual(@"Somewhere", [self wanderWhere: 5]);
	UKTrue([self isOrdered]);
	UKIntsEqual(3, [self intValue]);	
}

@end

#if 0
/* We cannot shut down warnings such as -[BasicTrait hello], hence we have to 
   provide a no-op in NSObject until we have a better way to handle that. */
@interface NSObject (LateBoundSuperUseCases)
- (NSString *) hello;
@end
@implementation NSObject (LateBoundSuperUseCases)
- (NSString *) hello { return nil; }
@end

@implementation TestBasicMixin

- (BOOL) isOrdered
{
	return YES;
}

- (NSString *) hello
{
	return @"Hello";
}

+ (void) initialize
{
	[[self class] applyMixinFromClass: [BasicTrait class]];
}

- (void) testMethods
{
	UKTrue([self respondsToSelector: @selector(bip)]);
	UKStringsEqual(@"Nowhere", [self wanderWhere: 5]);
	UKFalse([self isOrdered]);
	UKStringsEqual(@"Hello", [super hello]);
	// FIXME: UKStringsEqual(@"Hello super", [self hello]);
}

- (void) testClassHierarchy
{
	UKObjectsEqual([TestBasicMixin class], [self class]);
	UKObjectsEqual(NSClassFromString(@"TestBasicMixin+BasicTrait"), [self superclass]);
	UKObjectsEqual([NSObject class], [[self superclass] superclass]);
}

@end

@implementation TestComplexMixin

- (BOOL) isOrdered
{
	return YES;
}

+ (void) initialize
{
	[[self class] applyMixinFromClass: [ComplexTrait class]];
}

- (void) testMethods
{
	UKFalse([self respondsToSelector: @selector(bip)]);
	UKStringsEqual(@"Somewhere", [self wanderWhere: 5]);
	UKTrue([self isOrdered]);
	UKIntsEqual(3, [self intValue]);
}

- (void) testClassHierarchy
{
	UKObjectsEqual([TestComplexMixin class], [self class]);
	UKObjectsEqual(NSClassFromString(@"TestComplexMixin+ComplexTrait"), [self superclass]);
	UKObjectsEqual([NSObject class], [[self superclass] superclass]);
}

@end

@implementation TestMixinSequence

- (BOOL) isOrdered
{
	return YES;
}

+ (void) initialize
{
	[[self class] applyMixinFromClass: [ComplexTrait class]];
	[[self class] applyMixinFromClass: [BasicTrait class]];
}

- (void) testMethods
{
	UKTrue([self respondsToSelector: @selector(bip)]);
	UKStringsEqual(@"Nowhere", [self wanderWhere: 5]);
	UKFalse([self isOrdered]);
	UKIntsEqual(3, [self intValue]);
}

- (void) testClassHierarchy
{
	UKObjectsEqual([TestMixinSequence class], [self class]);
	UKObjectsEqual(NSClassFromString(@"TestMixinSequence+BasicTrait"), [self superclass]);
	UKObjectsEqual(NSClassFromString(@"TestMixinSequence+ComplexTrait"), [[self superclass] superclass]);
	UKObjectsEqual([NSObject class], [[[self superclass] superclass] superclass]);
}

@end
#endif

/* Trait and Mixin Implementations */

@implementation BasicTrait
- (void) bip { }
- (NSString *) wanderWhere: (NSUInteger)aLocation { return @"Nowhere"; }
- (BOOL) isOrdered { return NO; }
//- (NSString *) hello { return [[super hello] stringByAppendingString: @" super"]; }
@end

@implementation ComplexTrait
- (NSString *) wanderWhere: (NSUInteger)aLocation { return @"Somewhere"; }
- (int) intValue { return 3; };
@end

/*@interface TestMixin1 (ETCollectionMixin)
- (BOOL) isEmpty;
- (id) content;
- (NSArray *) contentArray;
@end*/
