/*
	Copyright (C) 2009 Eric Wasylishen, Quentin Mathe

	Date:  July 2009
	License:  Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#import "ETEntityDescription.h"
#import "ETPackageDescription.h"
#import "ETCollection.h"
#import "ETCollection+HOM.h"
#import "ETPropertyDescription.h"
#import "ETReflection.h"
#import "ETValidationResult.h"
#import "NSObject+Trait.h"
#import "NSObject+Model.h"
#import "Macros.h"
#import "EtoileCompatibility.h"


@implementation ETEntityDescription

@synthesize abstract = _abstract, parent = _parent, owner = _owner;
@synthesize parentName = _parentName, ownerName = _ownerName;
@synthesize localizedDescription = _localizedDescription;
@synthesize UIBuilderPropertyNames = _UIBuilderPropertyNames;
@synthesize diffAlgorithm = _diffAlgorithm;

+ (void) initialize
{
	if (self != [ETEntityDescription class])
		return;

	[self applyTraitFromClass: [ETCollectionTrait class]];
	[self applyTraitFromClass: [ETMutableCollectionTrait class]];
}

+ (NSString *) rootEntityDescriptionName
{
	return @"NSObject";
}

- (id)  initWithName: (NSString *)name
{
	self = [super initWithName: name];
	if (nil == self) return nil;

	_abstract = NO;
	_propertyDescriptions = [[NSMutableDictionary alloc] init];
	_parent = nil;
	_children = [[NSPointerArray alloc] initWithOptions: NSPointerFunctionsObjectPointerPersonality | NSPointerFunctionsOpaqueMemory];
	ASSIGNCOPY(_localizedDescription, name);
	_UIBuilderPropertyNames = [NSArray new];
	return self;
}

- (void) removeFromParentChildrenArray
{
	if (_parent != nil)
	{
		const NSUInteger count = [_parent->_children count];
		for (NSUInteger i = 0; i < count; i++)
		{
			if ([_parent->_children pointerAtIndex: i] == self)
			{
				[_parent->_children removePointerAtIndex: i];
				break;
			}
		}
	}
}

- (void) addToParentChildrenArray
{
	if (_parent != nil)
	{
		[_parent->_children addPointer: self];
	}
}

- (void) dealloc
{
	[self removeFromParentChildrenArray];
	DESTROY(_cachedAllPropertyDescriptions);
	DESTROY(_cachedAllPropertyDescriptionsByName);
	DESTROY(_cachedAllPropertyDescriptionNames);
	DESTROY(_cachedAllPersistentPropertyDescriptions);
	DESTROY(_propertyDescriptions);
	DESTROY(_parent);
	DESTROY(_children);
	DESTROY(_parentName);
	DESTROY(_ownerName);
	DESTROY(_localizedDescription);
	DESTROY(_UIBuilderPropertyNames);
	[super dealloc];
}

- (void) clearCaches
{
	DESTROY(_cachedAllPropertyDescriptions);
	DESTROY(_cachedAllPropertyDescriptionsByName);
	DESTROY(_cachedAllPropertyDescriptionNames);
	DESTROY(_cachedAllPersistentPropertyDescriptions);
	
	for (ETEntityDescription *child in [_children allObjects])
	{
		[child clearCaches];
	}
}

+ (ETEntityDescription *) newEntityDescription
{
	ETEntityDescription *selfDesc = [self newBasicEntityDescription];

	if ([[selfDesc name] isEqual: [ETEntityDescription className]] == NO)
		return selfDesc;

	ETPropertyDescription *owner =
		[ETPropertyDescription descriptionWithName: @"owner" type: (id)@"ETPackageDescription"];
	[owner setOpposite: (id)@"ETPackageDescription.entityDescriptions"];
	ETPropertyDescription *abstract =
		[ETPropertyDescription descriptionWithName: @"abstract" type: (id)@"BOOL"];
	ETPropertyDescription *root =
		[ETPropertyDescription descriptionWithName: @"root" type: (id)@"BOOL"];
	[root setDerived: YES];
	ETPropertyDescription *propertyDescriptions =
		[ETPropertyDescription descriptionWithName: @"propertyDescriptions" type: (id)@"ETPropertyDescription"];
	[propertyDescriptions setMultivalued: YES];
	[propertyDescriptions setOpposite: (id)@"ETPropertyDescription.owner"];
	ETPropertyDescription *parent =
		[ETPropertyDescription descriptionWithName: @"parent" type: (id)@"ETEntityDescription"];
	ETPropertyDescription *diffAlgorithm =
		[ETPropertyDescription descriptionWithName: @"diffAlgorithm" type: (id)@"NSString"];
	
	[selfDesc setPropertyDescriptions: A(owner, abstract, root, propertyDescriptions, parent, diffAlgorithm)];

	return selfDesc;
}

- (NSString *) typePrefix
{
	return [NSClassFromString([self name]) typePrefix];
}

- (BOOL) isEntityDescription
{
	return YES;
}

- (NSString *) typeDescription;
{
	return @"Entity";
}

- (void) setAbstract: (BOOL)isAbstract
{
	[self checkNotFrozen];
	_abstract = isAbstract;
}

- (BOOL) isRoot
{
	return _parent == nil;
}

- (NSArray *) propertyDescriptionNames
{
	return (id)[[[self propertyDescriptions] mappedCollection] name];
}

- (NSArray *) allPropertyDescriptionNames
{
	//NSLog(@"Called -allPropertyDescriptionNames %@ on %@", (id)[[[self allPropertyDescriptions] mappedCollection] name], self);

	if (_cachedAllPropertyDescriptionNames == nil)
	{
		ASSIGN(_cachedAllPropertyDescriptionNames, (id)[[[self allPropertyDescriptions] mappedCollection] name]);
	}
	return _cachedAllPropertyDescriptionNames;
}

- (NSArray *) propertyDescriptions
{
	return [_propertyDescriptions allValues];
}

- (void) setPropertyDescriptions: (NSArray *)propertyDescriptions
{
	[self checkNotFrozen];
	[self clearCaches];
	
	FOREACH([self propertyDescriptions], oldProperty, ETPropertyDescription *)
	{
		[oldProperty setOwner: nil];
	}
	[_propertyDescriptions release];

	_propertyDescriptions = [[NSMutableDictionary alloc] initWithCapacity:
		[propertyDescriptions count]];
	FOREACH(propertyDescriptions, propertyDescription, ETPropertyDescription *)
	{
		[self addPropertyDescription: propertyDescription];
	}
}

- (void) addPropertyDescription: (ETPropertyDescription *)propertyDescription
{
	if ([propertyDescription isPersistent])
	{
		[self checkNotFrozen];
	}
	[self clearCaches];
	
	ETEntityDescription *owner = [propertyDescription owner];

	if (nil != owner)
	{
		[owner removePropertyDescription: propertyDescription];
	}
	[propertyDescription setOwner: self];
	[_propertyDescriptions setObject: propertyDescription
							  forKey: [propertyDescription name]];
}

- (void) removePropertyDescription: (ETPropertyDescription *)propertyDescription
{
	if ([propertyDescription isPersistent])
	{
		[self checkNotFrozen];
	}
	[self clearCaches];
	
	[propertyDescription setOwner: nil];
	[_propertyDescriptions removeObjectForKey: [propertyDescription name]];
}

static void CacheAllPropertyDescriptionsRecursive(ETEntityDescription *entity, NSMutableDictionary *allPropertyDescriptions)
{
	if (entity->_parent != nil)
	{
		CacheAllPropertyDescriptionsRecursive(entity->_parent, allPropertyDescriptions);
	}

	// N.B. This automatically makes child properties replace parent properties
	[allPropertyDescriptions addEntriesFromDictionary: entity->_propertyDescriptions];

	ASSIGN(entity->_cachedAllPropertyDescriptionsByName, allPropertyDescriptions);
	ASSIGN(entity->_cachedAllPropertyDescriptions, [allPropertyDescriptions allValues]);
}

- (NSArray *) allPropertyDescriptions
{
	if (_cachedAllPropertyDescriptions == nil)
	{
		NSMutableDictionary *allPropertyDescriptions = [NSMutableDictionary dictionary];
		CacheAllPropertyDescriptionsRecursive(self, allPropertyDescriptions);
	}
	return _cachedAllPropertyDescriptions;
}

- (NSDictionary *) allPropertyDescriptionsByName
{
	if (_cachedAllPropertyDescriptionsByName == nil)
	{
		NSMutableDictionary *allPropertyDescriptions = [NSMutableDictionary dictionary];
		CacheAllPropertyDescriptionsRecursive(self, allPropertyDescriptions);
	}
	return _cachedAllPropertyDescriptionsByName;
}

- (NSArray *) allPersistentPropertyDescriptions
{
	if (_cachedAllPersistentPropertyDescriptions == nil)
	{
		NSMutableArray *propertyDescs = [NSMutableArray arrayWithArray: self.allPropertyDescriptions];
		[[propertyDescs filter] isPersistent];
		ASSIGN(_cachedAllPersistentPropertyDescriptions, propertyDescs);
	}
	return _cachedAllPersistentPropertyDescriptions;
}

- (void) setParent: (ETEntityDescription *)parentDescription
{
	[self checkNotFrozen];
	// TODO: Remove once all code used -setParentName:
	if ([parentDescription isString])
	{
		[self setParentName: (id)parentDescription];
		return;
	}

	[self clearCaches];
	[self removeFromParentChildrenArray];
	ASSIGN(_parent, parentDescription);
	[self addToParentChildrenArray];
}

- (BOOL) isKindOfEntity: (ETEntityDescription *)anEntityDesc
{
	ETEntityDescription *entity = self;

	while (entity != nil)
	{
		if ([[entity name] isEqual: [anEntityDesc name]])
			return YES;

		entity = [entity parent];
	}
	return NO;
}

- (BOOL) isValidValue: (id)aValue type: (ETEntityDescription *)anEntityDesc
{
	return [anEntityDesc isKindOfEntity: self];
}

- (void) setOwner: (ETPackageDescription *)owner
{
	[self checkNotFrozen];
	// TODO: Remove once all code used -setOwnerName:
	if ([owner isString])
	{
		[self setOwnerName: (id)owner];
		return;
	}

	_owner = owner;
}

- (NSArray *)allPackageDescriptions
{
	ETEntityDescription *entity = self;
	ETPackageDescription *package = nil;
	NSMutableArray *allPackages = [NSMutableArray array];

	while (![entity isRoot])
	{
		ETPackageDescription *owner = entity.owner;

		if (owner != nil && owner != package)
		{
			package = owner;
			[allPackages addObject: package];
		}
		entity = entity.parent;
	}
	return allPackages;
}

- (ETPropertyDescription *)propertyDescriptionForName: (NSString *)name
{
	return [self allPropertyDescriptionsByName][name];
}

- (NSArray *)propertyDescriptionsForNames: (NSArray *)names
{
	return [[self allPropertyDescriptionsByName] objectsForKeys: names
	                                             notFoundMarker: [NSNull null]];
}

- (ETValidationResult *) validateValue: (id)value forKey: (NSString *)key
{
	return [[self propertyDescriptionForName: key] validateValue: value forKey: key];
}

- (NSArray *) allUIBuilderPropertyNames
{
	if ([self isRoot])
	{
		return [self UIBuilderPropertyNames];
	}
	else
	{
		return [[[self parent] allUIBuilderPropertyNames]
			arrayByAddingObjectsFromArray: [self UIBuilderPropertyNames]];
	}
}

- (BOOL) isPrimitive
{
	return NO;
}

- (BOOL) isCPrimitive
{
	return NO;
}

/* Inspired by the Java implementation of FAME */
- (void) checkConstraints: (NSMutableArray *)warnings
{
	// NOTE: ProjectDemo violates this constraint
	// because OutlineItem has the OutlineItem.parent <=> OutlineItem.contents relationship,
	// as well as the Document.rootDocObject <=> DocumentItem.document
	// (OutlineItem is a subentity of DocumentItem)
	//
	// Basically the OutlineItem.parent/contents relationship defines the tree of outliner items,
	// and the OutlineItem.document/Document.rootDocObject relationship connects the top node of the
	// outline the the document object.
	//
	// So I'm disabling this for now and we can revisit it after the first release.
#if 0
	{
		NSMutableArray *containers = [NSMutableArray array];

		FOREACH([self allPropertyDescriptions], propertyDesc, ETPropertyDescription *)
		{
			if ([propertyDesc isContainer])
				[containers addObject: propertyDesc];
		}
		if ([containers count] > 1)
		{
			[warnings addObject: [self warningWithMessage:
				[NSString stringWithFormat: @"Found more than one container/composite relationship: %@", containers]]];
		}
	}
#endif

	/* Primitives belongs to a package unlike FAME */
	if ([self ownerName] != nil)
	{
		[warnings addObject: [self warningWithMessage:
			@"Failed to resolve owner (a package)"]];
	}
	if ([self owner] == nil)
	{
		[warnings addObject: [self warningWithMessage: @"Miss an owner (a package)"]];
	}

	if ([[self name] isEqual: [[self class] rootEntityDescriptionName]] == NO)
	{
		if ([self parentName] != nil)
		{
			[warnings addObject: [self warningWithMessage:
				@"Failed to resolve parent"]];
		}
		// NOTE: C primitives have no parent unlike ObjC primitives
		if ([self parent] == nil && [self isCPrimitive] == NO)
		{
			[warnings addObject: [self warningWithMessage: @"Miss a parent"]];
		}
		if ([[self parent] isCPrimitive])
		{
			[warnings addObject: [self warningWithMessage:
				@"C Primitives are not allowed to be parent"]];
		}
	}

	NSMutableSet *entityDescSet = [NSMutableSet setWithObject: self];
	ETEntityDescription *entityDesc = [self parent];

	while (entityDesc != nil)
	{
		if ([entityDescSet containsObject: entityDesc])
		{
			[warnings addObject: [self warningWithMessage:
				@"Found a loop in the parent chain"]];
			break;
		}
		[entityDescSet addObject: entityDesc];
		entityDesc = [entityDesc parent];
	}

	/* We put it at the end to get the entity warnings first */
	FOREACH([self propertyDescriptions], propertyDesc2, ETPropertyDescription *)
	{
		[propertyDesc2 checkConstraints: warnings];
	}
}

- (id) content
{
	return _propertyDescriptions;
}

- (NSArray *) contentArray
{
	return [_propertyDescriptions allValues];
}

- (void) insertObject: (id)object atIndex: (NSUInteger)index hint: (id)hint
{
	[self addPropertyDescription: object];
}

- (void) removeObject: (id)object atIndex: (NSUInteger)index hint: (id)hint
{
	[self removePropertyDescription: object];
}

- (BOOL) isFrozen
{
	return _isFrozen;
}

- (void)makeFrozen
{
	if (_isFrozen)
		return;
	
	_isFrozen = YES;
	
	[[self parent] makeFrozen];
	
	for (ETPropertyDescription *propDesc in [_propertyDescriptions allValues])
	{
		[propDesc makeFrozen];
	}
}

@end


@implementation ETPrimitiveEntityDescription

- (BOOL) isPrimitive
{
	return YES;
}

- (NSString *) typeDescription
{
	return @"Primitive Entity";
}

@end

@implementation ETCPrimitiveEntityDescription

- (BOOL) isCPrimitive
{
	return YES;
}

- (NSString *) typeDescription
{
	return @"C Primitive Entity";
}

- (NSSet *) validNumberEntityNames
{
	return S(@"BOOL", @"NSInteger", @"NSUInteger", @"CGFloat", @"double");
}

- (const char *) objCType
{
	if ([[self name] isEqualToString: @"NSPoint"])
	{
		return @encode(NSPoint);
	}
	else if ([[self name] isEqualToString: @"NSSize"])
	{
		return @encode(NSSize);
	}
	else if ([[self name] isEqualToString: @"NSRect"])
	{
		return @encode(NSRect);
	}
	else if ([[self name] isEqualToString: @"NSRange"])
	{
		return @encode(NSRange);
	}
	else if ([[self name] isEqualToString: @"SEL"])
	{
		return @encode(SEL);
	}
	return "";
}

- (BOOL) isValidValue: (id)aValue type: (ETEntityDescription *)anEntityDesc
{
	if ([super isValidValue: aValue type: anEntityDesc])
		return YES;

	if ([aValue isKindOfClass: [NSNumber class]])
	{
		/* We don't check [aValue objCType] vs [self objCType] are equal, since 
		   type conversions are common for numbers. We accept the value  even in 
		   case it doesn't match exactly, because the mismatch is usually due to 
		   a type conversion in the code. For example, we use KVC to set a
		   NSInteger property in this way:

		   [someObject setValue: [NSNumber numberWithUnsignedInteger: number]
		                 forKey: @"integerValue"];
		   
		   If someObject implementation calls -isValidValue:type:, checking 
		   the -objCType equality would prevent the number object to be accepted.
		   
		   In addition, Apple documentation states the following: "If you ask 
		   a number for its objCType, the returned type does not necessarily 
		   match the method the receiver was created with." */
		return [[self validNumberEntityNames] containsObject: [self name]];
	}
	else if ([aValue isKindOfClass: [NSValue class]])
	{
		return (strcmp([aValue objCType], [self objCType]) == 0);
	}
	return NO;
}

@end


#if 0
// Serialization

/**
 * Serialize the object using the ETModelDescription meta-meta model.
 */
- (NSDictionary *) _ETModelDescriptionSerializationOfObject: (id)obj withAlreadySerializedObjectsAndIds:
{
	NSMutableDictionary *serialization = [NSMutableDictionary dictionary];
	id desc = [obj entityDescription];
	if (desc)
	{
		FOREACH([desc propertyDescriptions], propertyDescription, ETPropertyDescription *)
		{

		}
	}
	else if ([obj class] == [NSArray class]) // NSDictionary, NSNumber
	{
		return D(@"primitiveType", @"NSArray",
		@"value", [[obj map] serialize...];
		}
		else if ([NSValueAdaptor blahBlahBlah] works..)
		{
			// serialize using value adapter stuff
		}
		return serialization;
		}

#endif
