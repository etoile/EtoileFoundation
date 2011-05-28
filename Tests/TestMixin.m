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

@interface TestTraitExclusionAndAliasing : NSObject <UKTest>
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

@interface TestTraitExclusionAndAliasing (BasicTrait)
- (void) bip;
- (NSString *) lost: (NSUInteger)aLocation;
@end

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

@implementation TestTraitExclusionAndAliasing

- (void) testApplyBasicTrait
{
	[[self class] applyTraitFromClass: [BasicTrait class]
	              excludedMethodNames: S(@"isOrdered")
	               aliasedMethodNames: D(@"lost:", @"wanderWhere:")];

	UKTrue([self respondsToSelector: @selector(bip)]);
	UKTrue([self respondsToSelector: @selector(lost:)]);
	UKFalse([self respondsToSelector: @selector(wanderWhere:)]);
	UKStringsEqual(@"Nowhere", [self lost: 5]);
	UKFalse([self respondsToSelector: @selector(isOrdered)]);
}

@end

/* Trait and Mixin Implementations */

@implementation BasicTrait
- (void) bip { }
- (NSString *) wanderWhere: (NSUInteger)aLocation { return @"Nowhere"; }
- (BOOL) isOrdered { return NO; }
@end

@implementation ComplexTrait
- (NSString *) wanderWhere: (NSUInteger)aLocation { return @"Somewhere"; }
- (int) intValue { return 3; };
@end
