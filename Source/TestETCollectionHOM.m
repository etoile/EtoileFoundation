/*
	TestETCollectionHOM.m

	Unit tests for higher-order messaging on collections.

	Copyright (C) 2009 Niels Grewe

	Author:  Niels Grewe <niels.grewe@halbordnung.de>
	Date:  June 2009

	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:

	* Redistributions of source code must retain the above copyright notice,
	  this list of conditions and the following disclaimer.
	* Redistributions in binary form must reproduce the above copyright notice,
	  this list of conditions and the following disclaimer in the documentation
	  and/or other materials provided with the distribution.
	* Neither the name of the Etoile project nor the names of its contributors
	  may be used to endorse or promote products derived from this software
	  without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
	THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <Foundation/Foundation.h>
#import <UnitKit/UnitKit.h>
#import "Macros.h"
#import "ETCollection.h"
#import "ETCollection+HOM.h"

#define	INPUTS NSArray *inputArray = A(@"foo",@"bar"); \
	NSDictionary *inputDictionary = D(@"foo",@"one",@"bar",@"two"); \
	NSSet *inputSet = [NSSet setWithArray: inputArray]; \
	NSCountedSet *inputCountedSet = [NSCountedSet set]; \
	[inputCountedSet addObject: @"foo"]; \
	[inputCountedSet addObject: @"bar"]; \
	[inputCountedSet addObject: @"foo"]; \
	NSIndexSet *inputIndexSet = [NSIndexSet indexSetWithIndexesInRange: \
	                                                   NSMakeRange(0,5)];

#define MUTABLEINPUTS NSMutableArray *array = [NSMutableArray \
	    arrayWithObjects: @"foo",@"bar", nil]; \
	NSMutableDictionary *dictionary = [NSMutableDictionary \
	    dictionaryWithObjectsAndKeys: @"foo",@"one",@"bar",@"two",nil];\
	NSMutableSet *set = [NSMutableSet setWithArray: array]; \
	NSCountedSet *countedSet = [NSCountedSet set]; \
	[countedSet addObject: @"foo"]; \
	[countedSet addObject: @"bar"]; \
	[countedSet addObject: @"foo"]; \
	int countOfFoo = [countedSet countForObject: @"foo"]; \
	int countOfBar = [countedSet countForObject: @"bar"]; \
	NSRange r = NSMakeRange(0,5); \
	NSMutableIndexSet *indexSet = [NSMutableIndexSet \
	                                       indexSetWithIndexesInRange: r]; \
	NSIndexSet *origIndexSet = [NSIndexSet indexSetWithIndexesInRange: r]; \
	TestAttributedObject *attrObject = [[[TestAttributedObject alloc] init] autorelease]; \
	TestAttributedObject *anotherAttrObject = [[[TestAttributedObject alloc] init] autorelease]; \
	[attrObject setString: @"foo"]; \
	[attrObject setNumber: [NSNumber numberWithInt: 1]]; \
	[anotherAttrObject setString: @"bar"]; \
	[anotherAttrObject setNumber: [NSNumber numberWithInt: 2]]; \
	NSMutableArray *attrArray = [NSMutableArray arrayWithObjects: \
	                                     attrObject, anotherAttrObject, nil]; \
	NSMutableSet *attrSet = [NSMutableSet setWithArray: attrArray]; \
	NSCountedSet *attrCountedSet = [NSCountedSet set]; \
	[attrCountedSet addObject: attrObject]; \
	[attrCountedSet addObject: attrObject]; \
	[attrCountedSet addObject: anotherAttrObject]; \
	NSMutableDictionary *attrDict = [NSMutableDictionary \
	 dictionaryWithObjectsAndKeys: attrObject, @"one", \
	                        anotherAttrObject, @"two", nil];

@interface NSNumber (ETTestHOM)
@end

@implementation NSNumber (ETTestHOM)
- (NSNumber*) twice
{
	int out = [self intValue] * 2;
	return [NSNumber numberWithInt: out];
}
- (NSNumber*) addNumber: (NSNumber*)aNumber
{
	int out = [self intValue] + [aNumber intValue];
	return [NSNumber numberWithInt: out];
}
@end

@interface NSString (ETTestHOM)
@end

@implementation NSString (ETTestHOM)
- (id) getNil
{
	return nil;
}
@end

@interface TestAttributedObject: NSObject
{
	NSString *stringAttribute;
	NSNumber *numericAttribute;
}
@end

@implementation TestAttributedObject
- (NSNumber *) numberAttribute
{
	return numericAttribute;
}

- (NSString *) stringAttribute
{
	return stringAttribute;
}

- (void) setNumber: (NSNumber *)aNumber
{
	[numericAttribute autorelease];
	numericAttribute = [aNumber retain];
}

- (void) setString: (NSString *)aString
{
	[stringAttribute autorelease];
	stringAttribute = [aString retain];
}

- (id) init
{
	SUPERINIT
	stringAttribute = nil;
	numericAttribute = nil;
	return self;
}

- (id) copyWithZone: (NSZone *)zone
{
	TestAttributedObject *newObject = [[TestAttributedObject allocWithZone: zone] init];
	[newObject setString: [stringAttribute copyWithZone: zone]];
	[newObject setNumber: [numericAttribute copyWithZone: zone]];
	return newObject;
}
DEALLOC( [stringAttribute release]; [numericAttribute release];)

@end

@interface TestETCollectionHOM: NSObject <UKTest>
@end

@implementation TestETCollectionHOM

/* -displayName is is defined in an NSObject category */
- (void) testDisplayNameAsArgumentMessage
{
	NSSet *inputSet = S(@"bla", @"bli", [NSNumber numberWithInt: 5]);
	NSSet *mappedSet = (NSSet *)[[inputSet mappedCollection] displayName];
	
	UKTrue([mappedSet containsObject: @"bla"]);
	UKTrue([mappedSet containsObject: @"bli"]);
	UKTrue([mappedSet containsObject: @"5"]);
}

/* -class is defined on both NSObject and NSProxy */
- (void) testClassAsArgumentMessage
{
	NSSet *inputSet = S([NSAffineTransform transform], [NSAffineTransform transform], [NSNull null]);
	NSSet *mappedSet = (NSSet *)[[inputSet mappedCollection] class];
	
	UKTrue([mappedSet containsObject: [NSAffineTransform class]]);
	UKTrue([mappedSet containsObject: [NSNull class]]);
}

- (void) testMappedEmptyCollection
{
	UKTrue([(id)[[[NSArray array] mappedCollection] uppercaseString] isEmpty]);
	UKTrue([(id)[[[NSSet set] mappedCollection] uppercaseString] isEmpty]);
	UKTrue([(id)[[[NSCountedSet set] mappedCollection] uppercaseString] isEmpty]);
	UKTrue([(id)[[[NSIndexSet indexSet] mappedCollection] twice] isEmpty]);
	UKTrue([(id)[[[NSDictionary dictionary] mappedCollection] uppercaseString] isEmpty]);
}

- (void) testMappedArray
{
	INPUTS
	NSArray *mappedArray = (NSArray*)[[inputArray mappedCollection] uppercaseString];
	
	UKTrue([mappedArray containsObject: @"FOO"]);
	UKTrue([mappedArray containsObject: @"BAR"]);
	UKFalse([mappedArray containsObject: @"foo"]);
	UKFalse([mappedArray containsObject: @"bar"]);
}

- (void) testMappedSet
{
	INPUTS
	NSSet *mappedSet = (NSSet*)[[inputSet mappedCollection] uppercaseString];

	UKTrue([mappedSet containsObject: @"FOO"]);
	UKTrue([mappedSet containsObject: @"BAR"]);
	UKFalse([mappedSet containsObject: @"foo"]);
	UKFalse([mappedSet containsObject: @"bar"]);
}

- (void) testMappedCountedSet
{
	INPUTS
	NSCountedSet *mappedCountedSet = (NSCountedSet*)[[inputCountedSet mappedCollection] uppercaseString];

	UKTrue([mappedCountedSet containsObject: @"FOO"]);
	UKTrue([mappedCountedSet containsObject: @"BAR"]);
	UKFalse([mappedCountedSet containsObject: @"foo"]);	
	UKFalse([mappedCountedSet containsObject: @"bar"]);
	UKIntsEqual([inputCountedSet countForObject: @"foo"],
	            [mappedCountedSet countForObject: @"FOO"]);
	UKIntsEqual([inputCountedSet countForObject: @"bar"],
	            [mappedCountedSet countForObject: @"BAR"]);
}

- (void) testMappedIndexSet
{
	INPUTS
	NSIndexSet *mappedIndexSet = (NSIndexSet*)[[inputIndexSet mappedCollection]	twice];
	
	NSEnumerator *indexEnumerator = [(NSArray*)inputIndexSet objectEnumerator];
	FOREACHE(inputIndexSet,number,id,indexEnumerator)
	{	
		int input = [(NSNumber*)number intValue];
		UKTrue([mappedIndexSet containsIndex: input*2]);
	}
}

- (void) testMappedDictionary
{
	INPUTS
	NSDictionary *mappedDictionary = (NSDictionary*)[[inputDictionary mappedCollection] uppercaseString];

	UKObjectsEqual([mappedDictionary objectForKey: @"one"],@"FOO");
	UKObjectsEqual([mappedDictionary objectForKey: @"two"],@"BAR");
}

- (void) testMapEmptyCollection
{
	UKTrue([(id)[[[NSMutableArray array] map] uppercaseString] isEmpty]);
	UKTrue([(id)[[[NSMutableSet set] map] uppercaseString] isEmpty]);
	UKTrue([(id)[[[NSCountedSet set] map] uppercaseString] isEmpty]);
	UKTrue([(id)[[[NSMutableIndexSet indexSet] map] twice] isEmpty]);
	UKTrue([(id)[[[NSMutableDictionary dictionary] map] uppercaseString] isEmpty]);
}

- (void) testMapArray
{
	MUTABLEINPUTS
	[[array map] uppercaseString];
	
	UKTrue([array containsObject: @"FOO"]);
	UKTrue([array containsObject: @"BAR"]);
	UKFalse([array containsObject: @"foo"]);
	UKFalse([array containsObject: @"bar"]);
}

- (void) testMapSet
{
	MUTABLEINPUTS
	[[set map] uppercaseString];
	UKTrue([set containsObject: @"FOO"]);
	UKTrue([set containsObject: @"BAR"]);
	UKFalse([set containsObject: @"foo"]);
	UKFalse([set containsObject: @"bar"]);
}

- (void) testMapCountedSet
{
	MUTABLEINPUTS
	[[countedSet map] uppercaseString];
	UKTrue([countedSet containsObject: @"FOO"]);
	UKTrue([countedSet containsObject: @"BAR"]);
	UKFalse([countedSet containsObject: @"foo"]);	
	UKFalse([countedSet containsObject: @"bar"]);
	UKIntsEqual(countOfFoo, [countedSet countForObject: @"FOO"]);
	UKIntsEqual(countOfBar, [countedSet countForObject: @"BAR"]);
}

- (void) testMapIndexSet
{
	MUTABLEINPUTS
	[[indexSet map] twice];
	NSEnumerator *indexEnumerator = [(NSArray*)origIndexSet objectEnumerator];
	FOREACHE(origIndexSet,number,id,indexEnumerator)
	{	
		int input = [(NSNumber*)number intValue];
		UKTrue([indexSet containsIndex: input*2]);
	}
}

- (void) testMapDictionary
{
	MUTABLEINPUTS
	[[dictionary map] uppercaseString];
	UKObjectsEqual([dictionary objectForKey: @"one"],@"FOO");
	UKObjectsEqual([dictionary objectForKey: @"two"],@"BAR");
}

- (void)testMapNilSubstitution
{
	INPUTS
	MUTABLEINPUTS
	NSArray *mappedArray = (NSArray*)[[inputArray mappedCollection] getNil];
	[[array map] getNil];

	UKIntsEqual([inputArray count],[mappedArray count]);
	UKIntsNotEqual(0,[array count]);
}

- (void) testFoldEmptyCollection
{
	UKNil([[[NSMutableArray array] leftFold] stringByAppendingString: @"foo"]);
	UKNil([[[NSMutableSet set] leftFold] stringByAppendingString: @"foo"]);
	UKNil([[[NSCountedSet set] leftFold] stringByAppendingString: @"foo"]);
	UKNil([[[NSMutableIndexSet indexSet] leftFold] addNumber: [NSNumber numberWithInt: 0]]);
	UKNil([[[NSMutableDictionary dictionary] leftFold] stringByAppendingString: @"foo"]);
}

- (void) testFoldArray;
{
	INPUTS
	UKObjectsEqual(@"letters: foobar",[[inputArray
	  leftFold]stringByAppendingString: @"letters: "]);
	UKObjectsEqual(@"foobar: letters",[[inputArray
	 rightFold]stringByAppendingString: @": letters"]);
}

- (void) testFoldSet
{
	INPUTS
	BOOL success = NO; 
	NSString* folded = [[inputSet leftFold] stringByAppendingString: @""];
	if([folded isEqual: @"foobar"] || [folded isEqual: @"barfoo"])
	{
		success = YES;
	}
	UKTrue(success);
}

- (void) testFoldCountedSet
{
	INPUTS
	BOOL success = NO;
	NSString *folded = [[inputCountedSet leftFold] stringByAppendingString: @""];
	if([folded isEqual: @"foofoobar"] 
	 || [folded isEqual: @"barfoofoo"]
	 || [folded isEqual: @"foobarfoo"])
	{
		success = YES;
	}
	UKTrue(success);
}

- (void) testFoldIndexSet
{
	INPUTS
	UKIntsEqual(10,[(NSNumber*)[[inputIndexSet leftFold] addNumber: 
	                   [NSNumber numberWithInt: 0]] intValue]);
}

- (void) testFilterEmptyCollection
{
	UKTrue([[[NSMutableArray array] filter] isEqualToString: @"foo"]);
	UKTrue([[[NSMutableSet set] filter] isEqualToString: @"foo"]);
	UKTrue([[[NSCountedSet set] filter] isEqualToString: @"foo"]);
	NSNumber *nb = [NSNumber numberWithInt: 2];
	UKTrue([[[NSMutableIndexSet indexSet] filter] isEqualToNumber: nb]);
	UKTrue([[[NSMutableDictionary dictionary] filter] isEqualToString: @"foo"]);
}

- (void) testFilterArraysAndSets
{
	MUTABLEINPUTS
	NSArray *someInputs = A(array,set,countedSet);
	FOREACHI(someInputs, collection)
	{
		[[(NSMutableArray*)collection filter]isEqualToString: @"foo"];
		UKTrue([(NSMutableArray*)collection containsObject: @"foo"]);
		UKFalse([(NSMutableArray*)collection containsObject: @"bar"]);
	}
}

- (void) testFilterDictionary
{
	MUTABLEINPUTS
	[[dictionary filter] isEqualToString: @"foo"];
	UKObjectsEqual(@"foo",[dictionary objectForKey: @"one"]);
	UKNil([dictionary objectForKey: @"two"]);
}

- (void) testFilterIndexSet
{
	MUTABLEINPUTS
	[[indexSet filter] isEqualToNumber: [NSNumber numberWithInt: 2]];
	NSEnumerator *indexEnumerator = [(NSArray*)indexSet objectEnumerator];
	FOREACHE(indexSet,anIndex,id,indexEnumerator)
	{
		UKIntsEqual(2,[(NSNumber*)anIndex intValue]);
	}
}

- (void) testAttributeAwareFilterArray
{
	MUTABLEINPUTS
	[[[attrArray filter] stringAttribute] isEqualToString: @"foo"];
	UKTrue([attrArray containsObject: attrObject]);
	UKFalse([attrArray containsObject: anotherAttrObject]);
}

- (void) testAttributeAwareFilterSet
{
	MUTABLEINPUTS
	[[[attrSet filter] stringAttribute] isEqualToString: @"foo"];
	UKTrue([attrSet containsObject: attrObject]);
	UKFalse([attrSet containsObject: anotherAttrObject]);
}

- (void) testAttributeAwareFilterCountedSet
{
	MUTABLEINPUTS
	[[[attrCountedSet filter] stringAttribute] isEqualToString: @"foo"];
	UKTrue([attrCountedSet containsObject: attrObject]);
	UKIntsEqual(2, [attrCountedSet countForObject: attrObject]);
	UKFalse([attrCountedSet containsObject: anotherAttrObject]);
}
- (void) testAttributeAwareFilterDictionary
{
	MUTABLEINPUTS
	[[[attrDict filter] stringAttribute] isEqualToString: @"foo"];
	UKObjectsEqual(attrObject, [attrDict objectForKey: @"one"]);
	UKNil([attrDict objectForKey: @"two"]);
}

- (void) testDeepAttributeAwareFilter
{
	MUTABLEINPUTS
	NSArray *someInputs = A(attrArray,attrSet,attrCountedSet,attrDict);
	FOREACHI(someInputs, collection)
	{
		[[[[(NSMutableArray*)collection filter] numberAttribute] twice] isEqualToNumber:
		                                          [NSNumber numberWithInt: 4]];
		if ((void*)collection == (void*)attrDict)
		{
			UKObjectsEqual(anotherAttrObject, [attrDict objectForKey: @"two"]);
			UKNil([attrDict objectForKey: @"one"]);
		}
		else
		{
			UKTrue([(NSMutableArray*)collection containsObject: anotherAttrObject]);
			UKFalse([(NSMutableArray*)collection containsObject: attrObject]);
		}
	}
}

- (void) testZippedEmptyCollection
{
	NSArray *second = A(@"bar", @"BAR");

	UKTrue([(id)[[[NSMutableArray array] zippedCollectionWithCollection: second] 
		stringByAppendingString: @"foo"] isEmpty]);
	UKTrue([(id)[[[NSMutableSet set] zippedCollectionWithCollection: second] 
		stringByAppendingString: @"foo"] isEmpty]);
	UKTrue([(id)[[[NSCountedSet set] zippedCollectionWithCollection: second] 
		stringByAppendingString: @"foo"] isEmpty]);
	UKTrue([(id)[[[NSMutableIndexSet indexSet] zippedCollectionWithCollection: second] 
		addNumber: [NSNumber numberWithInt: 0]] isEmpty]);
	UKTrue([(id)[[[NSMutableDictionary dictionary] zippedCollectionWithCollection: second] 
		stringByAppendingString: @"foo"] isEmpty]);
}

- (void) testZippedArray
{
	NSArray *first = A(@"foo", @"FOO");
	NSArray *second = A(@"bar", @"BAR");
	NSArray *result = (NSArray*)[[first zippedCollectionWithCollection: second] stringByAppendingString: nil];
	if (2 == [result count])
	{
		UKTrue([[result objectAtIndex: 0] isEqual: @"foobar"]);
		UKTrue([[result objectAtIndex: 1] isEqual: @"FOOBAR"]);
	}
	else
	{
		UKFail();
	}

}

- (void) testZippedDictionary
{
	INPUTS
	NSDictionary *result = (NSDictionary*)[[inputDictionary zippedCollectionWithCollection: inputDictionary] stringByAppendingString: nil];
	UKObjectsEqual([result objectForKey: @"one"],@"foofoo");
	UKObjectsEqual([result objectForKey: @"two"],@"barbar");
}

- (void) testZippedSet
{
	INPUTS
	NSSet *result = (NSSet*)[[inputSet zippedCollectionWithCollection: inputSet] stringByAppendingString: nil];

	// FIXME: This test wrongly assumes that sets are ordered. Since the
	// implementation behaves that way, that's not a problem (yet).
	UKTrue([result containsObject: @"foofoo"]);
	UKTrue([result containsObject: @"barbar"]);
}

- (void) testZippedCountedSet
{
	INPUTS
	NSCountedSet *result = (NSCountedSet*)[[inputCountedSet zippedCollectionWithCollection: inputCountedSet] stringByAppendingString: nil];
	UKTrue([result containsObject: @"foofoo"]);
	UKTrue([result containsObject: @"barbar"]);
	UKIntsEqual(2,[result countForObject: @"foofoo"]);
	UKIntsEqual(1,[result countForObject: @"barbar"]);
}

- (void) testZippedIndexSet
{
	INPUTS
	NSIndexSet *result = (NSIndexSet*)[[inputIndexSet zippedCollectionWithCollection: inputIndexSet] addNumber: nil];
	NSEnumerator *indexEnumerator = [(NSArray*)inputIndexSet objectEnumerator];
	FOREACHE(inputIndexSet,number,id,indexEnumerator)
	{
		UKTrue([result containsIndex: [[(NSNumber*)number twice] unsignedIntValue]]);
	}
}

- (void) testZipEmptyCollection
{
	NSArray *second = A(@"bar", @"BAR");

	UKTrue([(id)[[[NSMutableArray array] zipWithCollection: second] 
		stringByAppendingString: @"foo"] isEmpty]);
	UKTrue([(id)[[[NSMutableSet set] zipWithCollection: second] 
		stringByAppendingString: @"foo"] isEmpty]);
	UKTrue([(id)[[[NSCountedSet set] zipWithCollection: second] 
		stringByAppendingString: @"foo"] isEmpty]);
	UKTrue([(id)[[[NSMutableIndexSet indexSet] zipWithCollection: second] 
		addNumber: [NSNumber numberWithInt: 0]] isEmpty]);
	UKTrue([(id)[[[NSMutableDictionary dictionary] zipWithCollection: second] 
		stringByAppendingString: @"foo"] isEmpty]);
}

- (void) testZipArray
{
	MUTABLEINPUTS
	[[array zipWithCollection: array] stringByAppendingString: nil];
	UKTrue([array containsObject: @"foofoo"]);
	UKTrue([array containsObject: @"barbar"]);
	UKFalse([array containsObject: @"foo"]);
	UKFalse([array containsObject: @"bar"]);
}

- (void) testZipDict
{
	MUTABLEINPUTS
	[[dictionary zipWithCollection: dictionary] stringByAppendingString: nil];
	UKObjectsEqual(@"foofoo",[dictionary objectForKey: @"one"]);
	UKObjectsEqual(@"barbar",[dictionary objectForKey: @"two"]);
}

- (void) testZipSet
{
	MUTABLEINPUTS
	[[set zipWithCollection: set] stringByAppendingString: nil];
	UKTrue([set containsObject: @"foofoo"]);
	UKTrue([set containsObject: @"barbar"]);
	UKFalse([set containsObject: @"foo"]);
	UKFalse([set containsObject: @"foo"]);
}

- (void) testZipCountedSet
{
	MUTABLEINPUTS
	[[countedSet zipWithCollection: countedSet] stringByAppendingString: nil];
	UKIntsEqual(2,[countedSet countForObject: @"foofoo"]);
	UKIntsEqual(1,[countedSet countForObject: @"barbar"]);
	UKIntsEqual(0,[countedSet countForObject: @"foo"]);
	UKIntsEqual(0,[countedSet countForObject: @"bar"]);
}

- (void) testZipIndexSet
{
	MUTABLEINPUTS
	[[indexSet zipWithCollection: indexSet] addNumber: nil];
	NSEnumerator *indexEnumerator = [(NSArray*)origIndexSet objectEnumerator];
	FOREACHE(origIndexSet,number,NSNumber*,indexEnumerator)
	{
		UKTrue([indexSet containsIndex: [[number twice] unsignedIntValue]]);
	}
}
@end
