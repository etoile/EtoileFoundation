/*
    Copyright (C) 2007 Quentin Mathe

    Date:  September 2007
    License: Modified BSD (see COPYING)
 */

#import "NSArray+Etoile.h"
#import "ETCollection.h"
#import "NSObject+Model.h"
#import "Macros.h"
#import "EtoileCompatibility.h"


@implementation NSArray (Etoile)

/** Returns the first object in the array, otherwise returns nil if the array is
empty. */
- (id) firstObject
{
    if ([self isEmpty])
        return nil;

    return [self objectAtIndex: 0];
}

- (NSArray *)subarrayFromIndex: (NSUInteger)anIndex
{
    return [self subarrayWithRange: NSMakeRange(anIndex, [self count] - anIndex)];
}

/** Returns a new array by copying the receiver and removing the objects equal 
to the given one. */
- (NSArray *) arrayByRemovingObject: (id)anObject
{
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray: self];
    [mutableArray removeObject: anObject];
    /* For safety we return an immutable array */
    return [NSArray arrayWithArray: mutableArray];
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

/** Returns a filtered array as -filteredArrayWithPredicate: does but always 
includes in the new array the given objects to be ignored by the filtering. */
- (NSArray *) filteredArrayUsingPredicate: (NSPredicate *)aPredicate
                          ignoringObjects: (NSSet *)ignoredObjects
{
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity: [self count]];

    FOREACHI(self, object)
    {
        if ([ignoredObjects containsObject: object] 
         || [aPredicate evaluateWithObject: object])
        {
            [newArray addObject: object];
        }
    }

    return newArray;
}

/** <strong>Deprecated</strong>

Returns the objects on which -valueForKey: returns a value that matches 
the given one.

For every object in the receiver, -valueForKey: will be invoked with the given 
key.

<example>
NSArray *personsNamedJohn = [persons objectsMatchingValue: @"John" forKey: @"name"];
</example>

You should now use -filteredArrayUsingPredicate or -filter instead. For example:

<example>
NSArray *personsNamedJohn = [persons filteredArrayUsingPredicate: 
    [NSPredicate predicateWithFormat: @"name == %@", @"John"]];
</example> */
- (NSArray *) objectsMatchingValue: (id)value forKey: (NSString *)key
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray *values = [self valueForKey: key];

    if (values == nil)
        return result;
    
    NSUInteger n = [values count];
    
    for (int i = 0; i < n; i++)
    {
        if ([[values objectAtIndex: i] isEqual: value])
        {
            [result addObject: [self objectAtIndex: i]];
        }
    }
    
    return result;
}

/** <strong>Deprecated</strong>

Same as the -objectsMatchingValue:forKey:, except it returns the first 
object that matches the receiver.

Nil is returned when no object can be matched. */
- (id) firstObjectMatchingValue: (id)value forKey: (NSString *)key
{
    NSArray *matchedObjects = [self objectsMatchingValue: value forKey: key];

    if ([matchedObjects isEmpty])
        return nil;
    
    return [matchedObjects firstObject];
}

- (NSString *)descriptionWithOptions: (NSMutableDictionary *)options
{
    NSMutableString *desc = [NSMutableString string];
    NSString *indent = [options objectForKey: @"kETDescriptionOptionCurrentIndent"];
    if (nil == indent) indent = @"";
    NSString *propertyIndent = [options objectForKey: kETDescriptionOptionPropertyIndent];
    if (nil == propertyIndent) propertyIndent = @"";
    BOOL usesNewLineIndent = ([propertyIndent isEqualToString: @""] == NO);
    NSUInteger n = [self count];

    [desc appendString: @"("];

    if (usesNewLineIndent)
    {
        /* To line up the elements vertically, we increment the indent by the 
           length of the opening parenthesis */
        indent = [indent stringByAppendingString: @" "];
    }

    for (int i = 0; i < n; i++)
    {
        id obj = [self objectAtIndex: i];
        BOOL isLast = (i == (n - 1));
    
        [desc appendString: [obj description]];

        if (isLast)
            break;

        [desc appendString: @", "];
        if (usesNewLineIndent)
        {
            [desc appendString: @"\n"];
            [desc appendString: indent];
        }
    }
    
    [desc appendString: @")"];

    return desc;
}

@end


@implementation NSMutableArray (Etoile)

- (void) removeObjectsFromIndex: (NSUInteger)anIndex
{
    [self removeObjectsInRange: NSMakeRange(anIndex, [self count] - anIndex)];
}

@end

