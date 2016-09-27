/*
    Copyright (C) 2007 Quentin Mathe
 
    Date:  December 2007
    License:  Modified BSD (see COPYING)
 */

#import "ETPropertyValueCoding.h"
#import "ETEntityDescription.h"
#import "ETModelDescriptionRepository.h"
#import "Macros.h"
#import "NSObject+Model.h"
#import "EtoileCompatibility.h"


@implementation NSObject (ETPropertyValueCoding)

- (BOOL) requiresKeyValueCodingForAccessingProperties
{
    return NO;
}

/** <override-dummy />
Returns the property names accessible through Property Value Coding but
not declared in the metamodel (e.g. NSObject or subclass entity description). 
 
For example, this includes properties such as <em>icon</em> or <em>isMutable</em>.
 
Can be overriden to include additional properties not declared in the metamodel, 
but must call the superclass implementation.

See -propertyNames. */
- (NSArray *) basicPropertyNames
{
    return [NSArray arrayWithObjects: @"icon", @"displayName", @"className",
        @"class", @"superclass", @"hash", @"self", @"isProxy", @"stringValue",
        @"objectValue", @"isCollection", @"isGroup",@"isMutable",
        @"isMutableCollection", @"isCommonObjectValue", @"isNumber", @"isString",
        @"isClass", @"description", @"primitiveDescription", nil];
}

- (NSArray *) propertyNames
{
    ETEntityDescription *description =
        [[ETModelDescriptionRepository mainRepository] entityDescriptionForClass: [self class]];
    ETAssert(description != nil);
    NSArray *properties = [description allPropertyDescriptionNames];
    ETAssert(properties != nil);
    return [[self basicPropertyNames] arrayByAddingObjectsFromArray: properties];
}

- (id) valueForProperty: (NSString *)key
{
    id value = nil;
    
    if ([[self propertyNames] containsObject: key])
    {
        value = [self basicValueForKey: key];
    }
    else
    {
        // TODO: Turn into an ETDebugLog which takes an object (or a class) to
        // to limit the logging to a particular object or set of instances.
        #ifdef DEBUG_PVC
        ETLog(@"WARNING: Found no value for property %@ in %@", key, self);
        #endif
    }
    
    return value;
}

- (BOOL) setValue: (id)value forProperty: (NSString *)key
{
    BOOL result = NO;
    
    if ([[self propertyNames] containsObject: key])
    {
        [self setBasicValue: value forKey: key];
        result = YES;
    }
    else
    {
        // TODO: Turn into an ETDebugLog which takes an object (or a class) to
        // to limit the logging to a particular object or set of instances.
        #ifdef DEBUG_PVC
        ETLog(@"WARNING: Trying to set value %@ for property %@ missing in "
            @"immutable property collection of %@", value, key, self);
        #endif
    }
    
    return result;
}

- (id) valueForPropertyPath: (NSString *)aPropertyPath
{
    id value = self;

    for (NSString *property in [aPropertyPath componentsSeparatedByString: @"."])
    {
        value = [value valueForProperty: property];
    }
    return value;
}

- (BOOL) setValue: (id)aValue forPropertyPath: (NSString *)aPropertyPath
{
    NSArray *components = [aPropertyPath componentsSeparatedByString: @"."];

    if ([components count] > 1)
    {
        NSString *property = [components lastObject];

        components = [components subarrayWithRange: NSMakeRange(0, [components count] - 1)];

        NSString *basePath = [components componentsJoinedByString: @"."];
        
        return [[self valueForPropertyPath: basePath] setValue: aValue forProperty: property];
    }
    else
    {
        return [self setValue: aValue forProperty: aPropertyPath];
    }
}

static id (*valueForKeyIMP)(id, SEL, NSString *) = NULL;
static void (*setValueForKeyIMP)(id, SEL, id, NSString *) = NULL;

/** Returns the value identified by key as NSObject does, even if -valueForKey:
is overriden.

This method allows to use basic KVC access (through ivars and accessors) from 
-valueForProperty: or other methods in subclasses, when a custom KVC strategy is 
implemented in subclasses for -valueForKey:. */
- (id) basicValueForKey: (NSString *)key
{
    valueForKeyIMP = (id (*)(id, SEL, NSString *))[[NSObject class] 
        instanceMethodForSelector: @selector(valueForKey:)];
    return valueForKeyIMP(self, @selector(valueForKey:), key);
}

/** Sets the value identified by key as NSObject does, even if -setValue:forKey:
is overriden.

This method allows to use basic KVC access (through ivars and accessors) from 
-setValue:forProperty: or other methods in subclasses, when a custom KVC 
strategy is implemented in subclasses for -setValue:forKey:. */
- (void) setBasicValue: (id)value forKey: (NSString *)key
{
    setValueForKeyIMP = (void (*)(id, SEL, id, NSString *))[[NSObject class] 
        instanceMethodForSelector: @selector(setValue:forKey:)];
    setValueForKeyIMP(self, @selector(setValue:forKey:), value, key);
}

@end


@implementation NSDictionary (ETPropertyValueCoding)
#if 0
- (NSArray *) propertyNames
{
    return [self allKeys];
}

- (id) valueForProperty: (NSString *)key
{
    return [self objectForKey: key];
}

- (BOOL) setValue: (id)value forProperty: (NSString *)key
{
    return NO;
}
#else

- (NSArray *) propertyNames
{
    NSArray *properties = [NSArray arrayWithObjects: @"count", @"firstObject", 
        @"lastObject", nil];
    
    return [[super propertyNames] arrayByAddingObjectsFromArray: properties];
}

- (id) valueForProperty: (NSString *)key
{
    id value = nil;
    
    if ([[self propertyNames] containsObject: key])
    {
        id (*NSObjectValueForKeyIMP)(id, SEL, id) = NULL;
        
        NSObjectValueForKeyIMP = (id (*)(id, SEL, id))[[NSObject class] 
            instanceMethodForSelector: @selector(valueForKey:)];
        value = NSObjectValueForKeyIMP(self, @selector(valueForKey:), key);
    }
    else
    {
        // TODO: Turn into an ETDebugLog which takes an object (or a class) to
        // to limit the logging to a particular object or set of instances.
        #ifdef DEBUG_PVC
        ETLog(@"WARNING: Found no value for property %@ in %@", key, self);
        #endif
    }
        
    return value;
}

- (BOOL) setValue: (id)value forProperty: (NSString *)key
{
    BOOL result = YES;
    
    if ([[self propertyNames] containsObject: key])
    {
        void (*NSObjectSetValueForKeyIMP)(id, SEL, id, id) = NULL;
        
        NSObjectSetValueForKeyIMP = (void (*)(id, SEL, id, id))[[NSObject class] 
            instanceMethodForSelector: @selector(setValue:forKey:)];
        NSObjectSetValueForKeyIMP(self, @selector(setValue:forKey:), value, key);
    }
    else
    {
        // TODO: Turn into an ETDebugLog which takes an object (or a class) to
        // to limit the logging to a particular object or set of instances.
        #ifdef DEBUG_PVC
        ETLog(@"WARNING: Found no value for property %@ in %@", key, self);
        #endif
    }
        
    return result;
}
#endif
@end


@implementation NSMutableDictionary (ETPropertyValueCoding)
#if 0
- (BOOL) setValue: (id)value forProperty: (NSString *)key
{
    BOOL result = YES;
    id object = value;
    
    // NOTE: Note sure we should really insert a null object when value is nil
    if (object == nil)
        object = [NSNull null];
    
    NS_DURING
        [self setObject: object forKey: key];
    NS_HANDLER
        result = NO;
        ETLog(@"Failed to set value %@ for property %@ in %@", value, key, self);
    NS_ENDHANDLER
    
    return result;
}
#endif
@end


@implementation NSArray (ETPropertyValueCoding)

- (NSArray *) propertyNames
{
    NSArray *properties = [NSArray arrayWithObjects: @"count", @"firstObject", 
        @"lastObject", nil];
    
    return [[super propertyNames] arrayByAddingObjectsFromArray: properties];
}

- (id) valueForProperty: (NSString *)key
{
    if ([[self propertyNames] containsObject: key])
    {
        id (*NSObjectValueForKeyIMP)(id, SEL, id) = NULL;
        
        NSObjectValueForKeyIMP = (id (*)(id, SEL, id))[[NSObject class] 
            instanceMethodForSelector: @selector(valueForKey:)];
        return NSObjectValueForKeyIMP(self, @selector(valueForKey:), key);
    }
    else
    {
        // TODO: Turn into an ETDebugLog which takes an object (or a class) to
        // to limit the logging to a particular object or set of instances.
        #ifdef DEBUG_PVC
        ETLog(@"WARNING: Found no value for property %@ in %@", key, self);
        #endif
        return nil;
    }
}

- (BOOL) setValue: (id)value forProperty: (NSString *)key
{
    return NO;
}

@end


@implementation NSMutableArray (ETPropertyValueCoding)

- (BOOL) setValue: (id)value forProperty: (NSString *)key
{
    BOOL result = YES;

    if ([[self propertyNames] containsObject: key])
    {
        void (*NSObjectSetValueForKeyIMP)(id, SEL, id, id) = NULL;
        
        NSObjectSetValueForKeyIMP = (void (*)(id, SEL, id, id))[[NSObject class] 
            instanceMethodForSelector: @selector(setValue:forKey:)];
        NSObjectSetValueForKeyIMP(self, @selector(setValue:forKey:), value, key);
    }
    else
    {
        // TODO: Turn into an ETDebugLog which takes an object (or a class) to
        // to limit the logging to a particular object or set of instances.
        #ifdef DEBUG_PVC
        ETLog(@"WARNING: Found no value for property %@ in %@", key, self);
        #endif
    }
    
    return result;
}

@end
