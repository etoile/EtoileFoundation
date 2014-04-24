/*
	Copyright (C) 2009 Eric Wasylishen
 
	Author:  Eric Wasylishen <ewasylishen@gmail.com>
	Date:  February 2009
	License: Modified BSD (see COPYING)
*/

#import <Foundation/Foundation.h>
#import <UnitKit/UnitKit.h>
#import "Macros.h"
#import "ETUTI.h"


@interface TestUTI: NSObject <UKTest>
@end

@implementation TestUTI

- (void) testBasic
{
	id text = [ETUTI typeWithString: @"public.text"];
	id data = [ETUTI typeWithString: @"public.data"];

	UKNotNil(text);
	UKNotNil(data);
	UKStringsEqual(@"public.text", [text stringValue]);
	
}

- (void) testSuperAndSubclassTypes
{
	id stringType = [ETUTI typeWithClass: [NSString class]];
	id objectType = [ETUTI typeWithClass: [NSObject class]];
	id mutableArrayType = [ETUTI typeWithClass: [NSMutableArray class]];
	id arrayType = [ETUTI typeWithClass: [NSArray class]];

	UKTrue([stringType conformsToType: objectType]);
	UKFalse([[objectType subtypes] containsObject: mutableArrayType]);
	UKTrue([[objectType allSubtypes] containsObject: mutableArrayType]);
	UKFalse([[mutableArrayType supertypes] containsObject: objectType]);
	UKTrue([[mutableArrayType supertypes] containsObject: arrayType]);
	UKFalse([[mutableArrayType supertypes] containsObject: objectType]);
	UKTrue([[mutableArrayType allSupertypes] containsObject: objectType]);
}

- (void) testExtensions
{
	id jpeg = [ETUTI typeWithString: @"public.jpeg"];
	UKTrue([[jpeg fileExtensions] containsObject: @"jpg"]);
}

- (void) testRegister
{
	id item = [ETUTI typeWithString: @"public.item"];
	id image = [ETUTI typeWithString: @"public.image"];
	id audio = [ETUTI typeWithString: @"public.audio"];

	id new = [ETUTI registerTypeWithString: @"etoile.testtype"
	                           description: @"Testing type."
	                      supertypeStrings: A(@"public.composite-content", @"public.jpeg")
	                              typeTags: nil];
	
	UKNotNil(new);
	UKStringsEqual(@"Testing type.", [new typeDescription]);
	UKTrue([new conformsToType: item]);
	UKTrue([new conformsToType: image]);
	UKFalse([new conformsToType: audio]);
	UKTrue([new conformsToType: item]);

	UKTrue([[new allSupertypes] containsObject: item]);
	UKTrue([[item allSubtypes] containsObject: new]);
}

- (void) testTransient
{
	id item = [ETUTI typeWithString: @"public.item"];
	id image = [ETUTI typeWithString: @"public.image"];
	id audio = [ETUTI typeWithString: @"public.audio"];

	id new = [ETUTI transientTypeWithSupertypeStrings: A(@"public.composite-content", @"public.jpeg")];
	
	UKNotNil(new);
	UKTrue([new conformsToType: item]);
	UKTrue([new conformsToType: image]);
	UKFalse([new conformsToType: audio]);
	UKTrue([new conformsToType: item]);

	UKTrue([[new allSupertypes] containsObject: item]);
	UKFalse([[item allSubtypes] containsObject: new]);	// Note the expected result
}

- (void) testClassBinding
{
	UKTrue([[ETUTI typeWithClass: [NSString class]] conformsToType:
			[ETUTI typeWithString: @"public.text"]]);
	UKTrue([[ETUTI typeWithClass: [NSMutableString class]] conformsToType:
			[ETUTI typeWithString: @"public.text"]]);
}

- (void) testClassValue
{
	UKNil([[ETUTI typeWithString: @"public.text"] classValue]);
	UKObjectsEqual([self class], [[ETUTI typeWithClass: [self class]] classValue]);
}

@end
