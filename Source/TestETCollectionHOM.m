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
#import "ETCollection+HOM.h"

#define	INPUTS NSArray *inputArray = A(@"foo",@"bar"); \
	NSDictionary *inputDictionary = D(@"foo",@"one",@"bar",@"two"); \
	NSSet *inputSet = [NSSet setWithArray: inputArray]; \
	NSCountedSet *inputCountedSet = [[NSCountedSet alloc] init]; \
	[inputCountedSet addObject: @"foo"]; \
	[inputCountedSet addObject: @"bar"]; \
	[inputCountedSet addObject: @"foo"]; \
	[inputCountedSet autorelease]; \
	NSIndexSet *inputIndexSet = [NSIndexSet indexSetWithIndexesInRange: \
	                                                   NSMakeRange(0,5)];

#define MUTABLEINPUTS NSMutableArray *array; \
	array = [NSMutableArray arrayWithObjects: @"foo",@"bar", nil]; \
	NSMutableDictionary *dictionary = [NSMutableDictionary \
	       dictionaryWithObjectsAndKeys: @"foo",@"one",@"bar",@"two",nil];\
	NSMutableSet *set = [NSMutableSet setWithArray: array]; \
	NSCountedSet *countedSet = [[NSCountedSet alloc] init]; \
	[countedSet addObject: @"foo"]; \
	[countedSet addObject: @"bar"]; \
	[countedSet addObject: @"foo"]; \
	[countedSet autorelease]; \
	int countOfFoo = [countedSet countForObject: @"foo"]; \
	int countOfBar = [countedSet countForObject: @"bar"]; \
	NSRange r = NSMakeRange(0,5); \
	NSMutableIndexSet *indexSet = [NSMutableIndexSet \
	                                       indexSetWithIndexesInRange: r]; \
	NSIndexSet *origIndexSet = [NSIndexSet indexSetWithIndexesInRange: r]; \

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
@interface TestETCollectionHOM: NSObject <UKTest>
@end

@implementation TestETCollectionHOM

- (void) testMappedCollection
{
	INPUTS
	NSArray *mappedArray;
	NSDictionary *mappedDictionary;
	NSSet *mappedSet;
	NSCountedSet *mappedCountedSet;
	NSIndexSet *mappedIndexSet;
	mappedArray = (NSArray*)[[inputArray mappedCollection] uppercaseString];
	mappedDictionary = (NSDictionary*)[[inputDictionary mappedCollection]uppercaseString];
	mappedSet = (NSSet*)[[inputSet mappedCollection] uppercaseString];
	mappedCountedSet = (NSCountedSet*)[[inputCountedSet mappedCollection] uppercaseString];
	mappedIndexSet = (NSIndexSet*)[[inputIndexSet mappedCollection] twice];
	
	UKTrue([mappedArray containsObject: @"FOO"]);
	UKTrue([mappedArray containsObject: @"BAR"]);
	UKFalse([mappedArray containsObject: @"foo"]);
	UKFalse([mappedArray containsObject: @"bar"]);
	UKTrue([mappedSet containsObject: @"FOO"]);
	UKTrue([mappedSet containsObject: @"BAR"]);
	UKFalse([mappedSet containsObject: @"foo"]);
	UKFalse([mappedSet containsObject: @"bar"]);
	UKTrue([mappedCountedSet containsObject: @"FOO"]);
	UKTrue([mappedCountedSet containsObject: @"BAR"]);
	UKFalse([mappedCountedSet containsObject: @"foo"]);	
	UKFalse([mappedCountedSet containsObject: @"bar"]);
	UKIntsEqual([inputCountedSet countForObject: @"foo"],
	            [mappedCountedSet countForObject: @"FOO"]);
	UKIntsEqual([inputCountedSet countForObject: @"bar"],
	            [mappedCountedSet countForObject: @"BAR"]);
	
	NSEnumerator *indexEnumerator = [(NSArray*)inputIndexSet
	                                      objectEnumerator];
	FOREACHW(inputIndexSet,number,id,indexEnumerator)
	{	
		int input = [(NSNumber*)number intValue];
		UKTrue([mappedIndexSet containsIndex: input*2]);
	}
	UKObjectsEqual([mappedDictionary objectForKey: @"one"],@"FOO");
	UKObjectsEqual([mappedDictionary objectForKey: @"two"],@"BAR");

	//Test nil substitution.
	mappedArray = (NSArray*)[[inputArray mappedCollection]getNil];
	UKIntsEqual([inputArray count],[mappedArray count]);
}

- (void) testMap
{
	MUTABLEINPUTS
	[[array map] uppercaseString];
	[[dictionary map]uppercaseString];
	[[set map] uppercaseString];
	[[countedSet map] uppercaseString];
	[[indexSet map] twice];
	
	UKTrue([array containsObject: @"FOO"]);
	UKTrue([array containsObject: @"BAR"]);
	UKFalse([array containsObject: @"foo"]);
	UKFalse([array containsObject: @"bar"]);
	UKTrue([set containsObject: @"FOO"]);
	UKTrue([set containsObject: @"BAR"]);
	UKFalse([set containsObject: @"foo"]);
	UKFalse([set containsObject: @"bar"]);
	UKTrue([countedSet containsObject: @"FOO"]);
	UKTrue([countedSet containsObject: @"BAR"]);
	UKFalse([countedSet containsObject: @"foo"]);	
	UKFalse([countedSet containsObject: @"bar"]);
	UKIntsEqual(countOfFoo,
	            [countedSet countForObject: @"FOO"]);
	UKIntsEqual(countOfBar,
	            [countedSet countForObject: @"BAR"]);
	
	NSEnumerator *indexEnumerator = [(NSArray*)origIndexSet
	                                      objectEnumerator];
	FOREACHW(origIndexSet,number,id,indexEnumerator)
	{	
		int input = [(NSNumber*)number intValue];
		UKTrue([indexSet containsIndex: input*2]);
	}
	UKObjectsEqual([dictionary objectForKey: @"one"],@"FOO");
	UKObjectsEqual([dictionary objectForKey: @"two"],@"BAR");

	//Test nil substitution.
	[[array map]getNil];
	UKIntsNotEqual(0,[array count]);

}

- (void) testFold;
{
	INPUTS;
	UKObjectsEqual(@"letters: foobar",[[inputArray
	  leftFold]stringByAppendingString: @"letters: "]);
	UKObjectsEqual(@"foobar: letters",[[inputArray
	 rightFold]stringByAppendingString: @": letters"]);

	BOOL success = NO; 
	NSString* folded;
	folded = [[inputSet leftFold] stringByAppendingString: @""];
	if([folded isEqualToString: @"foobar"] ||
	   [folded isEqualToString: @"barfoo"])
	{
		success = YES;
	}
	UKTrue(success);
	success = NO;
	folded = [[inputCountedSet leftFold] stringByAppendingString: @""];
	if([folded isEqualToString: @"foofoobar"] ||
	   [folded isEqualToString: @"barfoofoo"] ||
	   [folded isEqualToString: @"foobarfoo"])
	{
		success = YES;
	}
	UKTrue(success);
	UKIntsEqual(10,[(NSNumber*)[[inputIndexSet leftFold]addNumber: 
	                   [NSNumber numberWithInt: 0]]intValue]);
}
- (void) testFilter
{
	MUTABLEINPUTS
	NSArray *someInputs = A(array,set,countedSet);
	FOREACHI(someInputs, collection)
	{
		[[(NSMutableArray*)collection filter]isEqualToString: @"foo"];
		UKTrue([(NSMutableArray*)collection containsObject: @"foo"]);
		UKFalse([(NSMutableArray*)collection containsObject: @"bar"]);
	}
	[[dictionary filter] isEqualToString: @"foo"];
	UKObjectsEqual(@"foo",[dictionary objectForKey: @"one"]);
	UKNil([dictionary objectForKey: @"two"]);
	[[indexSet filter] isEqualToNumber: [NSNumber numberWithInt: 2]];
	NSEnumerator *indexEnumerator = [(NSArray*)indexSet objectEnumerator];
	FOREACHW(indexSet,anIndex,id,indexEnumerator)
	{
		UKIntsEqual(2,[(NSNumber*)anIndex intValue]);
	}
}
@end
