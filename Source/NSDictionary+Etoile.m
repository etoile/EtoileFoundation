/*
    Copyright (C) 2007 Quentin Mathe

    Date:  September 2007
    License: Modified BSD (see COPYING)
 */

#import "NSDictionary+Etoile.h"
#import "ETCollection.h"
#import "NSObject+Model.h"
#import "Macros.h"
#import "EtoileCompatibility.h"


@implementation NSDictionary (Etoile)


- (BOOL) containsKey: (id <NSCopying>)aKey
{
    return ([self objectForKey: aKey] != nil);
}

- (NSDictionary *)dictionaryByAddingEntriesFromDictionary: (NSDictionary *)aDict
{
    NSMutableDictionary *combinedDict = [NSMutableDictionary dictionaryWithDictionary: self];
    [combinedDict addEntriesFromDictionary: aDict];
    return [NSDictionary dictionaryWithDictionary: combinedDict];
}

- (NSDictionary *)subdictionaryForKeys: (NSArray *)keys
{
    INVALIDARG_EXCEPTION_TEST(keys,
        [[NSSet setWithArray: keys] isSubsetOfSet: [NSSet setWithArray: [self allKeys]]]);
    NSArray *values = [self objectsForKeys: keys notFoundMarker: [NSNull null]];
    return [NSDictionary dictionaryWithObjects: values
                                       forKeys: keys];
}

- (NSString *) descriptionWithOptions: (NSMutableDictionary *)options
{
    NSMutableString *desc = [NSMutableString string];
    NSString *indent = [options objectForKey: @"kETDescriptionOptionCurrentIndent"];
    if (nil == indent) indent = @"";
    NSString *propertyIndent = [options objectForKey: kETDescriptionOptionPropertyIndent];
    if (nil == propertyIndent) propertyIndent = @"";
    BOOL usesNewLineIndent = ([propertyIndent isEqualToString: @""] == NO);
    NSArray *allKeys = [self allKeys];
    NSUInteger n = [self count];

    [desc appendString: @"{"];

    if (usesNewLineIndent)
    {
        /* To line up the elements vertically, we increment the indent by the 
           length of the opening parenthesis */
        indent = [indent stringByAppendingString: @" "];
    }

    for (int i = 0; i < n; i++)
    {
        NSString *key = [allKeys objectAtIndex: i];
        id obj = [self objectForKey: key];
        BOOL isLast = (i == (n - 1));
    
        [desc appendFormat: @"%@ = ", key];
        [desc appendString: [obj description]];

        if (isLast)
            break;

        [desc appendString: @"; "];
        if (usesNewLineIndent)
        {
            [desc appendString: @"\n"];
            [desc appendString: indent];
        }
    }
    
    [desc appendString: @"}"];

    return desc;
}

@end

#ifdef GNUSTEP
@implementation NSMutableDictionary (Etoile)

- (void) addObject: anObject forKey: aKey
{
    id old = [self objectForKey: aKey];

    if (nil == old)
    {
        [self setObject: anObject forKey: aKey];
    }
    else
    {
        if ([old isKindOfClass: [NSMutableArray class]])
        {
            [(NSMutableArray*)old addObject: anObject];
        }
        else
        {
            [self setObject: [NSMutableArray arrayWithObjects: old, anObject, nil]
                     forKey: aKey];
        }
    }
}

@end
#endif
