/*
    Copyright (C) 2007 Quentin Mathe

    Date:  December 2007
    License:  Modified BSD (see COPYING)
 */

#import <Foundation/NSKeyValueObserving.h>
#import "NSObject+Model.h"
#import "Macros.h"
#import "NSArray+Etoile.h"
#import "NSObject+Etoile.h"
#import "ETCollection.h"
#import "ETEntityDescription.h"
#import "ETModelDescriptionRepository.h"
#import "EtoileCompatibility.h"
#ifndef GNUSTEP
#import <objc/runtime.h>
#endif
//#define DEBUG_PVC 1


@implementation NSObject (ETModel)

/** <override-dummy />
Returns a new self-description (aka metamodel).

You must never use this method to retrieve an entity description, but only 
retrieves it through a ETModelDescriptionRepository instance.

This method can be invoked at runtime by a repository to automatically collect 
the entity descriptions and make them available in this repository.

You can implement this method to describe your subclasses more precisely than 
-basicNewEntityDescription.<br />
You must never call [super newEntityDescription] in the implementation.<br />
You must not return an autoreleased object.

For example:

<example>
ETEntityDescription *desc = [self newBasicEntityDescription];

// For subclasses that don't override -newEntityDescription, we must not add the 
// property descriptions that we will inherit through the parent (the 
// 'MyClassName' entity description).
if ([[desc name] isEqual: [MyClass className]] == NO) return desc;

ETPropertyDescription *city = [ETPropertyDescription descriptionWithName: @"city" type: (id)@"NSString"];
ETPropertyDescription *country = [ETPropertyDescription descriptionWithName: @"country" type: (id)@"NSString"];

[desc setPropertyDescriptions: A(city, country)];

[desc setAbstract: YES];

return desc;
</example>

If you want set the parent explicitly, replace -newBasicEntityDescription with:

<example>
ETEntityDescription *desc = [ETEntityDescription descriptionWithName: [self className]];

// Will be resolved when the entity description is put in the repository
[desc setParent: NSStringFromClass([self superclass])];
</example>
 */
+ (ETEntityDescription *) newEntityDescription
{
    return [self newBasicEntityDescription];
}

+ (NSString *) packageName
{
    NSBundle *bundle = [NSBundle bundleForClass: self];
    ETAssert(bundle != nil);
    NSString *packageName = [bundle bundleIdentifier];

    if (packageName == nil)
    {
        // NOTE: We return -executablePath since this gives a valid name even
        // with test bundles and tools, -bundlePath would the enclosing
        // directory for a tool.
        packageName = [[bundle executablePath] lastPathComponent];
    }

    return packageName;
}

/** <override-never />
Returns a new minimal self-description without any property descriptions.

This entity description uses the class name as its name and the parent name is
set to the superclass name.
 
The owner name is set to the bundle identifier (or executable path in last
resort).

The parent and owner will be resolved by
-[ETModelDescriptionRepository resolveNamedObjectReferences].

You must never use this method to retrieve an entity description, but only a 
ETModelDescriptionRepository instance to do so.

The returned object is not autoreleased.

See also -newEntityDescription, -[ETEntityDescription parentName] and 
-[ETEntityDescription ownerName]. */
+ (ETEntityDescription *) newBasicEntityDescription
{
    ETEntityDescription *desc = [[ETEntityDescription alloc] initWithName: [self className]];

    if ([self superclass] != nil)
    {
        [desc setParent: (id)[[self superclass] className]];
    }
    [desc setOwnerName: [self packageName]];

    return desc;
}

#ifndef GNUSTEP
- (BOOL) isClass
{
    return class_isMetaClass([self class]);
}
#endif

- (id) objectValue
{
    if ([self isCommonObjectValue])
    {
        return self;
    }
    else
    {
        return [self stringValue];
    }
}

/** <override-dummy />
Returns the description of the receiver by default.

Subclasses can override this method to return a string representation that 
encodes some basic infos about the receiver. This string representation can 
then be edited, validated by -validateValue:forKey:error: and used to 
instantiate another object by passing it to +objectWithStringValue:. */
- (NSString *) stringValue
{
    return [self description];
}

/** Returns YES if the receiver is an NSString instance, otherwise returns NO. */
- (BOOL) isString
{
    return [self isKindOfClass: [NSString class]];
}

/** Returns YES if the receiver is an NSNumber instance, otherwise returns NO. */
- (BOOL) isNumber
{
    return [self isKindOfClass: [NSNumber class]];
}

/** Returns a mutable counterpart class or Nil if such a class does not exist. */
+ (Class) mutableClass
{
    return Nil;
}

/** <override-dummy />
Returns YES if the receiver is declared as a group, otherwise returns NO. 

This method returns NO by default. You can override it to return YES if you 
want to declare your subclass instances as groups. 

A group is specialized model object which is a composite and can behave like a 
mutable collection. A basic collection object (like NSMutableArray, 
NSMutableDictionary, NSMutableSet) must never be declared as a group.<br />
COGroup in CoreObject or ETLayoutItemGroup in EtoileUI are typical examples.

A group should conform to ETCollectionMutation protocol. */
- (BOOL) isGroup
{
    return NO;
}

/** <override-dummy />
Returns YES if the receiver is declared as mutable, otherwise returns NO. 

This method returns NO by default. You can override it to return YES if you 
want to declare your subclass instances as mutable objects (which are 
collections most of time).

If you adopts ETCollectionMutation in a subclass, you don't need to override 
this method to declare your collection objects as mutable. */
- (BOOL) isMutable
{
    if ([self conformsToProtocol: @protocol(ETCollectionMutation)])
        return YES;

    return NO;
}

+ (BOOL) isMutable
{
    return NO;
}

/** <override-never />
Returns YES if the receiver is declared as a collection by conforming to 
ETCollection protocol, otherwise returns NO.

You must never override this method in your collection classes, you only need 
to adopt ETCollection protocol. */
- (BOOL) isCollection
{
    return [self conformsToProtocol: @protocol(ETCollection)];
}

+ (BOOL) isCollection
{
    return NO;
}

/** <override-never />
Returns YES if the receiver is declared as a collection by conforming to 
ETCollectionMutation protocol, otherwise returns NO. 

You must never override this method in your collection classes, you only need 
to adopt ETCollectionMutation protocol. */
- (BOOL) isMutableCollection
{
    return [self conformsToProtocol: @protocol(ETCollectionMutation)];
}

+ (BOOL) isMutableCollection
{
    return NO;
}

/** <override-never />
Returns YES if the receiver is a low-level collection such as NSArray, NSet, 
etc., otherwise returns NO. 

For a model object such as ETLayoutItemGroup that conforms to ETCollection 
protocol, would return NO. */
- (BOOL) isPrimitiveCollection
{
    return ([self isCollection] &&  self == [(id <ETCollection>)self content]);
}

- (BOOL) validateValue: (id *)value forKey: (NSString *)key error: (NSError **)err
{
    id val = *value;
    BOOL validated = YES;
    
    if ([val isCommonObjectValue])
        return YES;
    
    /* Validate non common value objects */
        
    //NSString *type = [self typeForKey: key];
    
    return validated;
}

/* Basic Properties */

/** Returns the receiver description.
    Subclasses can override this method to return a more appropriate display
    name. */
- (NSString *) displayName
{
    return [self description];
}

/** Returns YES when the receiver is an object which can be passed to 
    -setObjectValue: or returned by -objectValue. Some common object values
    like string and number can be displayed and edited transparently (in an 
    NSCell instance to take an example). If you define additional common object
    values, you usually have to write related formatters.
    Returns NO by default.
    Subclasses can override this method to specify an object can be accepted
    and used a common object value. */
- (BOOL) isCommonObjectValue
{
    return NO;
}

/** <override-never />
    Returns the description as NSObject would. 
    This method returns the same value as -description if the latter method 
    isn't overriden in your subclasses, otherwise it returns the value that
    -description would return if you haven't overriden it.
    Useful to get consistent short descriptions on all instances and can be
    used to provide custom description built with other short descriptions. */
- (NSString *) primitiveDescription
{
    // return [super primitiveDescription]; doesn't compile because super 
    // is keyword and not a pseudovar like self
    NSString * (*descIMP)(id, SEL, id) = NULL;
    
    descIMP = (NSString * (*)(id, SEL, id))[[NSObject class] 
        instanceMethodForSelector: @selector(description)];
    return descIMP(self, @selector(description), nil);
}

/** Returns a description generated based on the given options.

Might describe a tree or graph structure if a traversal key is provided to 
recursively invoke -descriptionsWithOptions: on each object node. To do so, 
put ETDescriptionOptionTraversalKey with a valid KVC key in the options. 
You can also set a max depth with ETDescriptionOptionMaxDepth to limit the 
description size or end a graph traversal.

You can collect key path values on each object node by specifying an array of 
key paths with ETDescriptionOptionValuesForKeyPaths.

The description format is roughly:
depth based indentation + object short description + keyPath1: value1, keyPath2: value2 etc.

By default, -description is used to print both object short description and key 
path values.

For customizing the object short description, put 
kETDescriptionOptionShortDescriptionSelector with a custom selector string in 
the options (-description is then used as fallback). <br />
If you override -description to call -descriptionWithOptions:, you must provide 
a valid kETDescriptionOptionShortDescriptionSelector to prevent an endless loop 
(for example, just use -primitiveDescription).

For presenting each key path on a new line, put kETDescriptionOptionPropertyIndent 
with a tab string in the options.

Here is an example based on EtoileUI that dumps an item tree structure:

<example>
// ObjC code
ETLog(@"\n%@\n", [browserItem descriptionWithOptions: [NSMutableDictionary dictionaryWithObjectsAndKeys: 
    A(@"frame", @"autoresizingMask"), kETDescriptionOptionValuesForKeyPaths,
    @"items", kETDescriptionOptionTraversalKey, nil]]);

// Console Output
&lt;ETLayoutItemGroup: 0x9e7b268&gt; { frame: {x = 0; y = 0; width = 600; height = 300}, autoresizingMask: 18 }
    &lt;ETLayoutItemGroup: 0x9fbea48&gt; { frame: {x = 0; y = 0; width = 1150; height = 53}, autoresizingMask: 2 }
        &lt;ETLayoutItem: 0x9f29240&gt; { frame: {x = 12; y = 12; width = 100; height = 22}, autoresizingMask: 0 }
        &lt;ETLayoutItem: 0x9e6fcf0&gt; { frame: {x = 124; y = 12; width = 100; height = 24}, autoresizingMask: 0 }
    &lt;ETLayoutItemGroup: 0x9fac170&gt; { frame: {x = 0; y = 0; width = 1150; height = 482}, autoresizingMask: 18 }
        &lt;ETLayoutItemGroup: 0x9fb2870&gt; { frame: {x = 0; y = 0; width = 50; height = 50}, autoresizingMask: 0 }
</example>

options must not be nil, otherwise raises an NSInvalidArgumentException.

You can override this method in subclasses, although it is not advised to. 
The options dictionary can be changed arbitrarily in a new implementation. */
- (NSString *) descriptionWithOptions: (NSMutableDictionary *)options
{
    NILARG_EXCEPTION_TEST(options);

    NSMutableString *desc = [NSMutableString string];
    NSArray *keyPaths = [options objectForKey: kETDescriptionOptionValuesForKeyPaths];
    NSString *traversalKey = [options objectForKey: kETDescriptionOptionTraversalKey];
    NSString *indent = [options objectForKey: @"kETDescriptionOptionCurrentIndent"];
    if (nil == indent)
    {
        indent = @"";
        [options setObject: indent forKey: @"kETDescriptionOptionCurrentIndent"];
    }
    NSString *propertyIndent = [options objectForKey: kETDescriptionOptionPropertyIndent];
    if (nil == propertyIndent)
    {
        propertyIndent = @"";
    }
    BOOL usesPropertyIndent = ([propertyIndent isEqualToString: @""] == NO);
    propertyIndent = [indent stringByAppendingString: propertyIndent];
    SEL shortDescriptionSel =
        NSSelectorFromString([options objectForKey: kETDescriptionOptionShortDescriptionSelector]);

    [desc appendString: @"\n"];
    [desc appendString: indent];
    if ([self respondsToSelector: shortDescriptionSel])
    {
        [desc appendString: [self performSelector: shortDescriptionSel]];
    }
    else
    {
        [desc appendString: [self description]];
    }
    [desc appendString: @" "];
    if (usesPropertyIndent)
    {
        [desc appendString: @"\n"];
    }

    /* Print Properties */

    if (usesPropertyIndent)
    {
        [desc appendString: indent];
        [desc appendString: @"{\n"];
    }
    else
    {
        [desc appendString: @"{ "];
    }

    NSArray *visibleKeyPaths =
        (usesPropertyIndent ? [keyPaths arrayByRemovingObject: traversalKey] : keyPaths);

    FOREACH(visibleKeyPaths, keyPath, NSString *)
    {
        if (usesPropertyIndent)
        {
            [desc appendString: propertyIndent];
        }
        [desc appendString: keyPath];
        [desc appendString: @": "];
        
        id value = [self valueForKeyPath: keyPath];
        NSString *valueString = nil;
        BOOL isPrimitiveCollection =
            ([value isCollection] && [(id <ETCollection>)value content] == value);
    
        /* For printing collections on multiple lines using the current indent */
        if (isPrimitiveCollection)
        {
            NSInteger labelLength = [propertyIndent length] + [keyPath length] + [@": " length];
            NSString *valueIndent = [propertyIndent stringByPaddingToLength: labelLength
                                                                 withString: @" "
                                                            startingAtIndex: 0];

            [options setObject: valueIndent forKey: @"kETDescriptionOptionCurrentIndent"];
            valueString = [value descriptionWithOptions: options];
            [options setObject: indent forKey: @"kETDescriptionOptionCurrentIndent"];
        }
        else
        {
            valueString = [value description];
        }

        BOOL isLast = ([keyPath isEqual: [visibleKeyPaths lastObject]]);

        [desc appendString: (valueString != nil ? valueString : @"nil")];
        if (isLast == NO)
        {
            [desc appendString: @", "];
        }
        if (usesPropertyIndent)
        {
            [desc appendString: @"\n"];
        }
    }

    if (usesPropertyIndent)
    {
        [desc appendString: indent];
        [desc appendString: @"}"];
    }
    else
    {
        [desc appendString: @" }"];
    }

    /* Print Children */

    NSString *newIndent = [propertyIndent stringByAppendingString: @"\t"];
    NSNumber *depthObject = [options objectForKey: @"kETDescriptionOptionCurrentDepth"];
    NSNumber *maxDepthObject = [options objectForKey: kETDescriptionOptionMaxDepth];

    if (nil == depthObject)
    {
        depthObject =  [NSNumber numberWithInteger: 0]; 
        [options setObject: depthObject forKey: @"ETDescriptionOptionCurrentDepth"];
    }
    if (nil == maxDepthObject)
    {
        maxDepthObject = [NSNumber numberWithInteger: 20];
        [options setObject: maxDepthObject forKey: kETDescriptionOptionMaxDepth];
    }

    NSInteger depth = [depthObject integerValue];
    NSInteger maxDepth = [maxDepthObject integerValue];

    if (depth < maxDepth && nil != traversalKey)
    {
        [options setObject: newIndent forKey: @"kETDescriptionOptionCurrentIndent"];
        [options setObject: [NSNumber numberWithInteger: depth + 1] 
                    forKey: @"kETDescriptionOptionCurrentDepth"];

        FOREACHI([self valueForKey: traversalKey], obj)
        {
            [desc appendString: [obj descriptionWithOptions: options]];
        }

        [options setObject: indent forKey: @"kETDescriptionOptionCurrentIndent"];
        [options setObject: [NSNumber numberWithInteger: depth] 
                    forKey: @"kETDescriptionOptionCurrentDepth"];
    }

    if (0 == depth)
    {
        [desc appendString: @"\n"];
    }

    return desc;
}

/* KVO Syntactic Sugar */

/** <override-dummy />
Returns an empty set.<br />
Overrides to return the receiver key paths to be observed when an observer is 
set up with -addObserver:.<br />

The returned set content must not change during the whole object lifetime, 
otherwise -removeObserver: will crash randomly. */
- (NSSet *) observableKeyPaths
{
    return [NSSet set];
}

/* Collection */

/** <override-dummy /> 
Returns a key for inserting the receiver into the given keyed collection.

By default, returns a key built by incrementing the integer value in the 
'Unknown &lt;number&gt;' pattern, until it provides a key not yet in use in the 
collection argument.

This key is retrieved by a collection in reply to -insertObjects:atIndexes:hints: 
of ETCollectionMutation protocol. You can return different keys depending on the 
type of collection. This parameter is usually the mutated collection itself. */
- (NSString *) insertionKeyForCollection: (id <ETKeyedCollection>)aCollection
{
    NSString *key = @"Unknown";
    NSString *uniqueKey = key;
    NSUInteger counter = 0;
    BOOL isUsed = NO;

    do
    {
        if (counter > 0)
        {
            uniqueKey = [NSString stringWithFormat: @"%@ %lu", key, (unsigned long)counter];
        }
        // TODO: Remove the content call once -objectForKey: is included in ETKeyedCollection
        isUsed = ([[aCollection content] objectForKey: uniqueKey] != nil);
        counter++;
    } while (isUsed);

    return uniqueKey;
}

@end

NSString * const kETDescriptionOptionValuesForKeyPaths = @"kETDescriptionOptionValuesForKeyPaths";;
NSString * const kETDescriptionOptionTraversalKey = @"kETDescriptionOptionTraversalKey";
NSString * const kETDescriptionOptionPropertyIndent = @"kETDescriptionOptionPropertyIndent";
NSString * const kETDescriptionOptionShortDescriptionSelector = @"kETDescriptionOptionShortDescriptionSelector";
NSString * const kETDescriptionOptionMaxDepth = @"kETDescriptionOptionMaxDepth";

NSString * const ETCollectionDidUpdateNotification = @"ETCollectionDidUpdateNotification";

/* Basic Common Value Classes */

@implementation NSString (ETModel)
/** Returns YES. */
- (BOOL) isCommonObjectValue { return YES; }
@end

@implementation NSNumber (ETModel)
/** Returns YES. */
- (BOOL) isCommonObjectValue { return YES; }
@end

@implementation NSDate (ETModel)
/** Returns YES. */
- (BOOL) isCommonObjectValue { return YES; }
@end
