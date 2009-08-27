/*
	ETCollection.h
	
	NSObject and collection class additions like a collection protocol.
 
	Copyright (C) 2007 Quentin Mathe
 
	Author:  Quentin Mathe <qmathe@club-internet.fr>
	Date:  September 2007
 
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

// This is a really ugly hack.  We define ETCollectionMutation before we define
// the prototype for it.  This allows us to not implement all of the methods
// that the protocol requires, which gets rid of a spurious GCC warning.
#import <Foundation/NSSet.h>
@implementation NSMutableSet (ETCollectionMutation)

- (void) insertObject: (id)object atIndex: (unsigned int)index
{
	[self addObject: object];
}

@end

#import <EtoileFoundation/ETCollection.h>
#import <EtoileFoundation/NSObject+Model.h>
#import <EtoileFoundation/EtoileCompatibility.h>


#if 0
@implementation ETCollectionMixin

- (unsigned int) count
{
	return [[self contentArray] count];
}

- (BOOL) isEmpty
{
	return ([self count] == 0);
}

- (BOOL) objectEnumerator
{
	return [[self contentArray] objectEnumerator];
}

@end
#endif

@implementation NSArray (ETCollection)

/** Returns NSMutableDictionary class. */
+ (Class) mutableClass
{
	return [NSMutableArray class];
}

- (BOOL) isOrdered
{
	return YES;
}

- (BOOL) isEmpty
{
	return ([self count] == 0);
}

- (id) content
{
	return self;
}

- (NSArray *) contentArray
{
	return [NSArray arrayWithArray: self];
}

- (NSString *) stringValue
{
	return [self descriptionWithLocale: nil];
}

- (NSString *) description
{
	return [NSString stringWithFormat: @"Array %d ordered objects", [self count]];
}

@end

@implementation NSDictionary (ETCollection)

/** Returns NSMutableDictionary class. */
+ (Class) mutableClass
{
	return [NSMutableDictionary class];
}

- (BOOL) isOrdered
{
	return NO;
}

- (BOOL) isEmpty
{
	return ([self count] == 0);
}

- (id) content
{
	return self;
}

- (NSArray *) contentArray
{
	return [self allValues];
}

- (NSString *) identifierAtIndex: (unsigned int)index
{
	// FIXME: In theory a bad implementation seeing that the documentation
	// states -allKeys and -allValues return objects in an undefined order.
	return [[self allKeys] objectAtIndex: index];
}

- (NSString *) stringValue
{
	return [self descriptionWithLocale: nil];
}

- (NSString *) description
{
	return [NSString stringWithFormat: @"Dictionary %d key/value pairs", [self count]];
}

@end

@implementation NSSet (ETCollection)

/** Returns NSMutableSet class. */
+ (Class) mutableClass
{
	return [NSMutableSet class];
}

- (BOOL) isOrdered
{
	return NO;
}

- (BOOL) isEmpty
{
	return ([self count] == 0);
}

- (id) content
{
	return self;
}

- (NSArray *) contentArray
{
	return [self allObjects];
}

@end

@implementation NSCountedSet (ETCollection)

/** Returns self, the NSCountedSet class.

NSCountedSet is always mutable and has not immutable equivalent. */
+ (Class) mutableClass
{
	return self;
}

@end

@implementation NSIndexSet (ETCollection)

/** Returns NSMutableIndexSet class. */
+ (Class) mutableClass
{
	return [NSMutableIndexSet class];
}

- (BOOL) isOrdered
{
	return NO;
}

- (BOOL) isEmpty
{
	return ([self count] == 0);
}

- (id) content
{
	return self;
}

- (NSArray *) contentArray
{
	NSMutableArray *indexes = [NSMutableArray arrayWithCapacity: [self count]];
	int nbOfIndexes = [self count];
	int nbOfCopiedIndexes = -1;
	unsigned int *copiedIndexes = calloc(sizeof(unsigned int), nbOfIndexes);
	
	nbOfCopiedIndexes = [self getIndexes: copiedIndexes maxCount: nbOfIndexes
		inIndexRange: NULL];
	
	NSAssert2(nbOfCopiedIndexes > -1, @"Invalid number of copied indexes for "
		@"%@, expected value is %d", self, nbOfIndexes);
	
	// NOTE: i < [self count] prevents the loop to be entered, because negative  
	// int (i) doesn't appear to be inferior to unsigned int (count)
	for (int i = 0; i < nbOfIndexes; i++)
	{
		unsigned int index = copiedIndexes[i];
			
		[indexes addObject: [NSNumber numberWithInt: index]];
	}
	
	free(copiedIndexes);
	
	return indexes;
}

- (NSEnumerator *) objectEnumerator
{
	return [[self contentArray] objectEnumerator];
}

@end

@implementation NSMutableDictionary (ETCollectionMutation)

/** Adds object to the receiver using as key the value returned by 
	-[object keyForCollection:] if not nil, otherwise falling back on the 
	highest integer value of all keys incremented by one. */
- (void) addObject: (id)object
{
	id key = [object keyForCollection: self];
	
	if (key == nil)
	{
		int i = 0;
		NSNumber *number = nil;
		id matchedObject = nil;

		do {
			number = [NSNumber numberWithInt: i];	
			matchedObject = [self objectForKey: number];
			i++;			
		} while (matchedObject != nil);

		key = number;
	}
	
	[self setObject: object forKey: key];
}

- (void) insertObject: (id)object atIndex: (unsigned int)index
{
	[self addObject: object];
}

/** Removes all occurrences of an object in  the receiver. */
- (void) removeObject: (id)object
{
	NSEnumerator *e = [[self allKeysForObject: object] objectEnumerator];
	id key = nil;
	
	while ((key = [e nextObject]) != nil)
	{
		[self removeObjectForKey: key];
	}
}

@end

@implementation NSMutableIndexSet (ETCollectionMutation)

- (void) addObject: (id)object
{
	if ([object isNumber])
	{
		[self addIndex: [object unsignedIntValue]];
	}
	else
	{
		// TODO: Evaluate whether logging a warning is a better choice than 
		// raising an exception.
		ETLog(@"Object %@ must be an NSNumber instance to be added to %@ "
			@"collection", object, self);
		return;	
	}
}

- (void) insertObject: (id)object atIndex: (unsigned int)index
{
	[self addObject: object];
}


- (void) removeObject: (id)object
{
	if ([object isNumber])
	{
		[self removeIndex: [object unsignedIntValue]];
	}
	else
	{
		// TODO: Evaluate whether logging a warning is a better choice than 
		// raising an exception.
		ETLog(@"Object %@ must be an NSNumber instance to be removed from %@ "
			@"collection", object, self);
		return;	
	}
}

@end


/* NSArray Extensions */

@implementation NSArray (Etoile)

/** Returns the first object in the array, otherwise returns nil if the array is
empty. */
- (id) firstObject
{
	if ([self isEmpty])
		return nil;

	return [self objectAtIndex: 0];
}

/** Returns a new array by copying the receiver and removing the objects equal 
to those contained in the given array. */
- (NSArray *) arrayByRemovingObjectsInArray: (NSArray *)anArray
{
	NSMutableArray *mutableArray = [NSMutableArray arrayWithArray: self];
	[mutableArray removeObjectsInArray: anArray];
	/* For safety we return an immutable array */
	return [NSArray arrayWithArray: mutableArray];
}

/** Deprecated. */
- (NSArray *) objectsMatchingValue: (id)value forKey: (NSString *)key
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray *values = [self valueForKey: key];
    int i, n = 0;
    
    if (values == nil)
        return result;
    
    n = [values count];
    
    for (i = 0; i < n; i++)
    {
        if ([[values objectAtIndex: i] isEqual: value])
        {
            [result addObject: [self objectAtIndex: i]];
        }
    }
    
    return result;
}

/** Deprecated. */
- (id) firstObjectMatchingValue: (id)value forKey: (NSString *)key
{
    return [[self objectsMatchingValue: value forKey: key] objectAtIndex: 0];
}

@end
