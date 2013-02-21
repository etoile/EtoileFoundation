/*
	Copyright (C) 2010 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  March 2010
	License:  Modified BSD (see COPYING)
 */

#import "ETModelDescriptionRepository.h"
#import "ETClassMirror.h"
#import "ETCollection.h"
#import "ETCollection+HOM.h"
#import "ETEntityDescription.h"
#import "ETPackageDescription.h"
#import "ETPropertyDescription.h"
#import "ETReflection.h"
#import "NSObject+Etoile.h"
#import "NSObject+Trait.h"
#import "NSObject+Model.h"
#import "Macros.h"
#import "EtoileCompatibility.h"
#if TARGET_OS_IPHONE
#import "ETCFMapTable.h"
#endif

#pragma GCC diagnostic ignored "-Wprotocol"

@implementation ETModelDescriptionRepository

+ (void) initialize
{
	if (self != [ETModelDescriptionRepository class])
		return;

	[self applyTraitFromClass: [ETCollectionTrait class]];
	[self applyTraitFromClass: [ETMutableCollectionTrait class]];
}

+ (ETEntityDescription *) newEntityDescription
{
	ETEntityDescription *selfDesc = [self newBasicEntityDescription];

	if ([[selfDesc name] isEqual: [ETModelDescriptionRepository className]] == NO)
		return selfDesc;

	// TODO: Add property descriptions...

	return selfDesc;
}

- (void) addUnresolvedEntityDescriptionForClass: (Class)aClass
{
	NSParameterAssert([_entityDescriptionsByClass objectForKey: aClass] == nil);
	NSParameterAssert([[[_classesByEntityDescription objectEnumerator] allObjects] containsObject: aClass] == NO);
	ETEntityDescription *entityDesc = [aClass newEntityDescription];
	[self addUnresolvedDescription: entityDesc];
	[self setEntityDescription: entityDesc forClass: aClass];
	RELEASE(entityDesc);
}

- (void) collectEntityDescriptionsFromClass: (Class)aClass
                            excludedClasses: (NSSet *)excludedClasses
                                 resolveNow: (BOOL)resolve
{
	NSSet *objectPrimitiveNames = (id)[[[self newObjectPrimitives] mappedCollection] name];

	/* Don't overwrite existing entity descriptions such as primitives e.g. NSObject/Object */
	if ([_entityDescriptionsByClass objectForKey: aClass] == nil)
	{
		[self addUnresolvedEntityDescriptionForClass: aClass];
	}

	FOREACH([[ETReflection reflectClass: aClass] allSubclassMirrors], mirror, ETClassMirror *)
	{
		if ([excludedClasses containsObject: [mirror representedClass]])
			continue;

		if ([objectPrimitiveNames containsObject: [mirror name]])
			 continue;

		[self addUnresolvedEntityDescriptionForClass: [mirror representedClass]];
	}
	if (resolve)
	{
		[self resolveNamedObjectReferences];
	}
}

static ETModelDescriptionRepository *mainRepo = nil;

+ (id) mainRepository
{
	if (nil == mainRepo)
	{
		mainRepo = [[self alloc] init];
		[mainRepo collectEntityDescriptionsFromClass: [NSObject class]
		                             excludedClasses: nil
		                                  resolveNow: YES];
	}
	return mainRepo;
}

- (NSArray *) newObjectPrimitives
{
	ETEntityDescription *objectDesc = [NSObject newEntityDescription];
	ETEntityDescription *stringDesc = [NSString newEntityDescription];
	ETEntityDescription *dateDesc = [NSDate newEntityDescription];
	/* We include NSValue because it is NSNumber superclass */
	ETEntityDescription *valueDesc = [NSValue newEntityDescription];
	ETEntityDescription *numberDesc = [NSNumber newEntityDescription];

	NSArray *objCPrimitives = A(objectDesc, stringDesc, dateDesc, valueDesc,
		numberDesc);

	FOREACHI(objCPrimitives, desc)
	{
		object_setClass(desc, [ETPrimitiveEntityDescription class]);
	}

	return objCPrimitives;
}

- (NSArray *) newCPrimitives
{
	return A([ETCPrimitiveEntityDescription descriptionWithName: @"BOOL"],
		[ETCPrimitiveEntityDescription descriptionWithName: @"NSInteger"],
		[ETCPrimitiveEntityDescription descriptionWithName: @"NSUInteger"],
		[ETCPrimitiveEntityDescription descriptionWithName: @"float"],
		[ETCPrimitiveEntityDescription descriptionWithName: @"NSPoint"],
		[ETCPrimitiveEntityDescription descriptionWithName: @"NSSize"],
		[ETCPrimitiveEntityDescription descriptionWithName: @"NSRect"],
		[ETCPrimitiveEntityDescription descriptionWithName: @"NSRange"],
		[ETCPrimitiveEntityDescription descriptionWithName: @"SEL"]);
}

/* FM3 names are Object, String, Date, Number and Boolean. */
- (NSString *) FM3NameForClassName: (NSString *)className
{
	Class class = NSClassFromString(className);
	NSString *typePrefix = (Nil != class ? [class typePrefix] : (NSString *)@"");
	int prefixEnd = [className rangeOfString: typePrefix
	                                 options: NSAnchoredSearch].length;

	return [className substringFromIndex: prefixEnd];
}

/* Special case to map FM3 Boolean object type to Number/NSNumber */								
- (void) setUpFM3BooleanPrimitive
{
	ETEntityDescription *booleanDesc = [ETPrimitiveEntityDescription descriptionWithName: @"Boolean"];
	[booleanDesc setParent: [_descriptionsByName objectForKey: @"Number"]];
	[_descriptionsByName setObject: booleanDesc forKey: @"Boolean"];
}

- (void) setUpWithCPrimitives: (NSArray *)cPrimitives
             objectPrimitives: (NSArray *)objcPrimitives
{
	NSArray *primitives = [objcPrimitives arrayByAddingObjectsFromArray: cPrimitives];

	FOREACH(primitives, cDesc, ETEntityDescription *)
	{
		[self addUnresolvedDescription: cDesc];
	}
	FOREACH(objcPrimitives, objcDesc, ETEntityDescription *)
	{
		NSString *className = [objcDesc name];
		Class class = NSClassFromString(className);
	
		if (Nil != class)
		{
			[self setEntityDescription: objcDesc forClass: class];
		}

		[_descriptionsByName setObject: objcDesc
								forKey: [self nameInAnonymousPackageForPartialName: className]];
		[_descriptionsByName setObject: objcDesc
								forKey: [self FM3NameForClassName: className]];
	}
	[self setUpFM3BooleanPrimitive];

	[self resolveNamedObjectReferences];
}

static NSString *anonymousPackageName = @"Anonymous";

- (id) init
{
	SUPERINIT;
	_unresolvedDescriptions = [[NSMutableSet alloc] init];
	_descriptionsByName = [[NSMutableDictionary alloc] init];
	ASSIGN(_entityDescriptionsByClass, [NSMapTable mapTableWithStrongToStrongObjects]);
	ASSIGN(_classesByEntityDescription, [NSMapTable mapTableWithStrongToStrongObjects]);
	[self addDescription: [ETPackageDescription descriptionWithName: anonymousPackageName]];
	[self setUpWithCPrimitives: [self newCPrimitives]
	          objectPrimitives: [self newObjectPrimitives]];

	ETAssert([[ETEntityDescription rootEntityDescriptionName] isEqual:
		[[self descriptionForName: @"Object"] name]]);

	return self;
}

- (void) dealloc
{
	DESTROY(_unresolvedDescriptions);
	DESTROY(_descriptionsByName);
	DESTROY(_entityDescriptionsByClass);
	DESTROY(_classesByEntityDescription);
	[super dealloc];
}

- (ETPackageDescription *) anonymousPackageDescription
{
	return [self descriptionForName: anonymousPackageName];
}

- (void) addDescriptions: (NSArray *)descriptions
{
	FOREACH(descriptions, desc, ETModelElementDescription *)
	{
		[self addDescription: desc];
	}
}

- (void) addDescription: (ETModelElementDescription *)aDescription
{
	if ([aDescription isEntityDescription] && [aDescription owner] == nil)
	{
		[[self anonymousPackageDescription] addEntityDescription: (ETEntityDescription *)aDescription];
	}
	[_descriptionsByName setObject: aDescription forKey: [aDescription fullName]];
}

- (void) removeDescription: (ETModelElementDescription *)aDescription
{
	[_descriptionsByName removeObjectForKey: [aDescription fullName]];
	ETAssert([[_descriptionsByName allKeysForObject: aDescription] isEmpty]);
}

- (NSArray *) packageDescriptions
{
	NSMutableArray *descriptions = [NSMutableArray arrayWithArray: [_descriptionsByName allValues]];
	[[descriptions filter] isPackageDescription];
	return descriptions;
}

- (NSArray *) entityDescriptions
{
	NSMutableArray *descriptions = [NSMutableArray arrayWithArray: [_descriptionsByName allValues]];
	[[descriptions filter] isEntityDescription];
	return descriptions;
}

- (NSArray *) propertyDescriptions
{
	NSMutableArray *descriptions = [NSMutableArray arrayWithArray: [_descriptionsByName allValues]];
	[[descriptions filter] isPropertyDescription];
	return descriptions;
}

- (NSArray *) allDescriptions
{
	return AUTORELEASE([[_descriptionsByName allValues] copy]);
}

- (NSString *)nameInAnonymousPackageForPartialName: (NSString *)aName
{
	return [anonymousPackageName stringByAppendingFormat: @".%@", aName];
}

- (id) descriptionForName: (NSString *)aFullName
{
	ETModelElementDescription *description = [_descriptionsByName objectForKey: aFullName];
	
	if (description!= nil)
		return description;

	return [_descriptionsByName objectForKey: [self nameInAnonymousPackageForPartialName: aFullName]];
}

/* Binding Descriptions to Class Instances and Prototypes */

- (ETEntityDescription *) entityDescriptionForClass: (Class)aClass
{
	ETEntityDescription *entityDescription = [_entityDescriptionsByClass objectForKey: aClass];

	/* Workaround multiple class objects for __NSCFConstantString on Mac OS X */
	if (entityDescription == nil)
	{
		Class usedClass = NSClassFromString(NSStringFromClass(aClass));
		entityDescription = [_entityDescriptionsByClass objectForKey: usedClass];
	}

	if (entityDescription == nil && [aClass superclass] != Nil)
	{
		entityDescription = [self entityDescriptionForClass: [aClass superclass]];
	}
	return entityDescription;
}

- (Class) classForEntityDescription: (ETEntityDescription*)anEntityDescription
{
       Class cls = [_classesByEntityDescription objectForKey: anEntityDescription];
       if (cls == Nil && [anEntityDescription parent] != nil)
       {
               cls = [self classForEntityDescription: [anEntityDescription parent]];
       }
       return cls;
}


- (void) setEntityDescription: (ETEntityDescription *)anEntityDescription
                     forClass: (Class)aClass
{
	if ([_descriptionsByName objectForKey: [anEntityDescription fullName]] == nil
	 && [_unresolvedDescriptions containsObject: anEntityDescription] == NO)
	{
		[NSException raise: NSInvalidArgumentException
		            format: @"The entity description must have been previously "
					         "added to the repository"];
	}
	[_entityDescriptionsByClass setObject: anEntityDescription forKey: aClass];
	[_classesByEntityDescription setObject: aClass forKey: anEntityDescription];
}

- (void) addUnresolvedDescription: (ETModelElementDescription *)aDescription
{
	NSParameterAssert([self descriptionForName: [aDescription fullName]] == nil);
	[_unresolvedDescriptions addObject: aDescription];
}

/* 'isPackageRef' prevents to wrongly look up a package as an entity (with the
same name). */
- (void) resolveProperty: (NSString *)aProperty
          forDescription: (ETModelElementDescription *)desc
            isPackageRef: (BOOL)isPackageRef
{
	id value = [desc valueForKey: aProperty];

	if ([value isString] == NO) return;

	id realValue = [self descriptionForName: (NSString *)value];
	BOOL lookUpInAnonymousPackage = (nil == realValue && NO == isPackageRef);

	if (lookUpInAnonymousPackage)
	{
		value = [self nameInAnonymousPackageForPartialName: value];
		realValue = [self descriptionForName: (NSString *)value];
	}
	if (nil != realValue)
	{
		[desc setValue: realValue forKey: aProperty];
	}
	else
	{
	        [NSException raise: NSInternalInconsistencyException
			            format: @"Couldn't resolve property %@ value %@ for %@",
			                    aProperty, value, desc];
	}
}

- (NSSet *) resolveAndAddEntityDescriptions: (NSSet *)unresolvedEntityDescs
{
	NSMutableSet *propertyDescs = [NSMutableSet set];

	FOREACH(unresolvedEntityDescs, desc, ETEntityDescription *)
	{
		[self resolveProperty: @"owner" forDescription: desc isPackageRef: YES];
		[propertyDescs addObjectsFromArray: [desc propertyDescriptions]];
		[self addDescription: desc];
	}

	FOREACH(unresolvedEntityDescs, desc2, ETEntityDescription *)
	{
		[self resolveProperty: @"parent" forDescription: desc2 isPackageRef: NO];
	}

	return propertyDescs;
}

- (void) resolveAndAddPropertyDescriptions:(NSMutableSet *)unresolvedPropertyDescs
{
	FOREACH(unresolvedPropertyDescs, desc, ETPropertyDescription *)
	{
		[self resolveProperty: @"type" forDescription: desc isPackageRef: NO];
		[self resolveProperty: @"owner" forDescription: desc isPackageRef: NO];
		/* A package is set when the property is an entity extension */
		[self resolveProperty: @"package" forDescription: desc isPackageRef: YES];
		 /* For property extension */
		[self addDescription: desc];
	}

	FOREACH(unresolvedPropertyDescs, desc2, ETPropertyDescription *)
	{
		[self resolveProperty: @"opposite" forDescription: desc2 isPackageRef: NO];
	}
}

- (void) resolveNamedObjectReferences
{
	NSMutableSet *unresolvedPackageDescs = [NSMutableSet setWithSet: _unresolvedDescriptions];
	NSMutableSet *unresolvedEntityDescs = [NSMutableSet setWithSet: _unresolvedDescriptions];
	NSMutableSet *unresolvedPropertyDescs = [NSMutableSet setWithSet: _unresolvedDescriptions];

	[[unresolvedPackageDescs filter] isPackageDescription];
	[[unresolvedEntityDescs filter] isEntityDescription];
	[[unresolvedPropertyDescs filter] isPropertyDescription];

	[self addDescriptions: [unresolvedPackageDescs allObjects]];
	NSSet *collectedPropertyDescs =
		[self resolveAndAddEntityDescriptions: unresolvedEntityDescs];
	[unresolvedPropertyDescs unionSet: collectedPropertyDescs];
	[self resolveAndAddPropertyDescriptions: unresolvedPropertyDescs];

	ASSIGN(_unresolvedDescriptions, [NSMutableSet set]);
}

- (void) checkConstraints: (NSMutableArray *)warnings
{
	FOREACH([self packageDescriptions], packageDesc, ETPackageDescription *)
	{
		[packageDesc checkConstraints: warnings];
	}
}

/** @taskunit Collection Protocol */

/** Returns YES when no package descriptions is registered, otherwise returns NO.

By default, returns NO since an anonymous package descriptions is registered in
any new repository. */
- (BOOL) isEmpty
{
	return ([[self packageDescriptions] count] == 0);
}

/** Returns a dictionary containing all the registered descriptions keyed by
full name.

The returned dictionary contains descriptions other than package descriptions.
You must assume that <code>[[self content] count] != [[self contentArray] count]</code>. */
- (id) content
{
	return _descriptionsByName;
}

/** Returns the registered package descriptions. See -packageDescriptions. */
- (NSArray *) contentArray
{
	return [self packageDescriptions];
}

/** Returns the number of registered package descriptions. */
- (NSUInteger) count
{
	return [[self packageDescriptions] count];
}

/** Returns an object to enumerate the registered package descriptions. */
- (id) objectEnumerator
{
	return [[self packageDescriptions] objectEnumerator];
}

- (void) insertObject: (id)object atIndex: (NSUInteger)index hint: (id)hint
{
	[self addDescription: object];
}

- (void) removeObject: (id)object atIndex: (NSUInteger)index hint: (id)hint

{
	[self removeDescription: object];
}

@end
