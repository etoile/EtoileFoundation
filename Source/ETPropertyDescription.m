/*
 ETPropertyDescription.m
 
 Property description in a model description framework inspired by FAME 
 (http://scg.unibe.ch/wiki/projects/fame)
 
 Copyright (C) 2009 Eric Wasylishen
 
 Author:  Eric Wasylishen <ewasylishen@gmail.com>
 Date:  July 2009
 License:  Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#import "ETPropertyDescription.h"
#import "ETPackageDescription.h"
#import "ETCollection.h"
#import "ETCollection+HOM.h"
#import "ETEntityDescription.h"
#import "ETReflection.h"
#import "ETUTI.h"
#import "ETValidationResult.h"
#import "NSObject+Model.h"
#import "Macros.h"
#import "EtoileCompatibility.h"


@implementation ETPropertyDescription

@synthesize derived = _derived, multivalued = _multivalued, ordered = _ordered, keyed = _keyed;
@synthesize persistent = _persistent, readOnly = _readOnly;
@synthesize opposite = _opposite, owner = _owner, package = _package, type = _type, role = _role;
@synthesize showsItemDetails = _showsItemDetails, detailedPropertyNames = _detailedPropertyNames;
@synthesize commitDescriptor = _commitDescriptor, indexed = _indexed,
	valueTransformerName = _valueTransformerName, persistentType = _persistentType;

+ (ETEntityDescription *) newEntityDescription
{
	ETEntityDescription *selfDesc = [self newBasicEntityDescription];

	if ([[selfDesc name] isEqual: [ETPropertyDescription className]] == NO) 
		return selfDesc;

	ETPropertyDescription *owner = 
		[ETPropertyDescription descriptionWithName: @"owner" type: (id)@"ETEntityDescription"];
	[owner setOpposite: (id)@"ETEntityDescription.propertyDescriptions"];
	ETPropertyDescription *composite = 
		[ETPropertyDescription descriptionWithName: @"composite" type: (id)@"BOOL"];
	[composite setDerived: YES];
	ETPropertyDescription *container = 
		[ETPropertyDescription descriptionWithName: @"container" type: (id)@"BOOL"];
	ETPropertyDescription *derived = 
		[ETPropertyDescription descriptionWithName: @"derived" type: (id)@"BOOL"];
	ETPropertyDescription *multivalued = 
		[ETPropertyDescription descriptionWithName: @"multivalued" type: (id)@"BOOL"];
	ETPropertyDescription *ordered = 
		[ETPropertyDescription descriptionWithName: @"ordered" type: (id)@"BOOL"];
	ETPropertyDescription *keyed =
		[ETPropertyDescription descriptionWithName: @"keyed" type: (id)@"BOOL"];
	ETPropertyDescription *showsItemDetails =
		[ETPropertyDescription descriptionWithName: @"showsItemDetails" type: (id)@"BOOL"];
	ETPropertyDescription *detailedProperties =
		[ETPropertyDescription descriptionWithName: @"detailedPropertyNames" type: (id)@"NSString"];
	[detailedProperties setMultivalued: YES];
	[detailedProperties setOrdered: YES];
	ETPropertyDescription *commitDescriptor =
		[ETPropertyDescription descriptionWithName: @"commitDescriptor" type: (id)@"NSObject"];
	ETPropertyDescription *opposite = 
		[ETPropertyDescription descriptionWithName: @"opposite" type: (id)@"ETPropertyDescription"];
	[opposite setOpposite: opposite];
	ETPropertyDescription *type = 
		[ETPropertyDescription descriptionWithName: @"type" type: (id)@"ETEntityDescription"];
	ETPropertyDescription *valueTransformerName =
		[ETPropertyDescription descriptionWithName: @"valueTransformerName" type: (id)@"NSString"];
	ETPropertyDescription *persistentType =
		[ETPropertyDescription descriptionWithName: @"persistentType" type: (id)@"ETEntityDescription"];
	ETPropertyDescription *package =
		[ETPropertyDescription descriptionWithName: @"package" type: (id)@"ETPackageDescription"];
	[package setOpposite: (id)@"ETPackageDescription.propertyDescriptions"];
	
	[selfDesc setPropertyDescriptions: A(owner, composite, container, derived, 
		multivalued, ordered, keyed, showsItemDetails, detailedProperties,
		commitDescriptor, opposite, type, valueTransformerName, persistentType,  package)];

	return selfDesc;
}

+ (ETPropertyDescription *) descriptionWithName: (NSString *)aName 
                                           type: (ETEntityDescription *)aType
{
	ETPropertyDescription *desc = AUTORELEASE([[self alloc] initWithName: aName]);
	NILARG_EXCEPTION_TEST(aType);
	[desc setType: aType];
	return desc;
}

- (id) initWithName: (NSString *)aName
{
	self = [super initWithName: aName];
	if (self == nil)
		return nil;

	_detailedPropertyNames = [NSArray new];
	return self;
}

- (void) dealloc
{
	DESTROY(_detailedPropertyNames);
	DESTROY(_commitDescriptor);
	DESTROY(_type);
	DESTROY(_valueTransformerName);
	DESTROY(_persistentType);
	DESTROY(_role);
	[super dealloc];
}

- (BOOL) isPropertyDescription
{
	return YES;
}

- (NSString *) typeDescription
{
	return [NSString stringWithFormat: @"%@ (%@)", @"Property", [[self type] name]];
}

/* Properties */

- (NSString *) fullName
{
	if (nil == [self owner] && nil != [self package])
	{
		return [NSString stringWithFormat: @"%@.%@", [[self package] fullName], [self name]];
	}
	else
	{
		return [super fullName];
	}
}

- (BOOL) isComposite
{
	return [[self opposite] isContainer];
}

- (BOOL) isContainer
{
	if (_opposite != nil && [_opposite isString] == NO)
	{
		if (_derived && !_multivalued)
		{
			return YES;
		}
	}
	return NO;
}

- (void) setDerived: (BOOL)isDerived
{
	[self checkNotFrozen];
	_derived = isDerived;
	[self setReadOnly: YES];
}

- (void) setMultivalued: (BOOL)isMultivalued
{
	[self checkNotFrozen];
	_multivalued = isMultivalued;
}

- (void) setOrdered: (BOOL)isOrdered
{
	[self checkNotFrozen];
	_ordered = isOrdered;
}

- (void) setKeyed: (BOOL)isKeyed
{
	[self checkNotFrozen];
	_keyed = isKeyed;
}

- (void) setPersistent: (BOOL)isPersistent
{
	[self checkNotFrozen];
	_persistent = isPersistent;
}

- (void) setReadOnly: (BOOL)isReadOnly
{
	[self checkNotFrozen];
	_readOnly = isReadOnly;
}

- (void) setCommitDescriptor: (id)aCommitDescriptor
{
	[self checkNotFrozen];
	ASSIGN(_commitDescriptor, aCommitDescriptor);
}

- (void) setShowsItemDetails: (BOOL)showsItemDetails
{
	[self checkNotFrozen];
	_showsItemDetails = showsItemDetails;
}

- (void)setDetailedPropertyNames: (NSArray *)detailedPropertyNames
{
	[self checkNotFrozen];
	ASSIGNCOPY(_detailedPropertyNames, detailedPropertyNames);
}

- (void) setIndexed: (BOOL)isIndexed
{
	[self checkNotFrozen];
	_indexed = isIndexed;
}

- (void) setOpposite: (ETPropertyDescription *)opposite
{
	[self checkNotFrozen];
	if ([_opposite isString])
	{
		DESTROY(_opposite);
	}
	if ([opposite isString])
	{
		_opposite = RETAIN(opposite);
		return;
	}

	if (_isSettingOpposite || opposite == _opposite)
	{
		return;
	}
	_isSettingOpposite = YES;

	ETPropertyDescription *oldOpposite = _opposite;

	_opposite = opposite;
	[self setType: [_opposite owner]];

	[oldOpposite setOpposite: nil];
	[_opposite setOpposite: self];

	_isSettingOpposite = NO;
}

- (void) setOwner: (ETEntityDescription *)owner
{
	[self checkNotFrozen];
	NSParameterAssert((_owner != nil && owner == nil) || (_owner == nil && owner != nil));
	_owner = owner;
	if ([self opposite] != nil && [[self opposite] isString] == NO)
	{
		[[self opposite] setType: owner];
	}
}

- (void) setPackage: (ETPackageDescription *)aPackage
{
	[self checkNotFrozen];
	_package = aPackage;
}

- (void) setType: (ETEntityDescription *)anEntityDescription
{
	[self checkNotFrozen];
	ASSIGN(_type, anEntityDescription);
}

- (void)setValueTransformerName: (NSString *)aTransformerName
{
	[self checkNotFrozen];
	ASSIGNCOPY(_valueTransformerName, aTransformerName);
}

- (void) setPersistentType: (ETEntityDescription *)anEntityDescription
{
	[self checkNotFrozen];
	ASSIGN(_persistentType, anEntityDescription);
}

- (BOOL) isRelationship
{
	return ([[self type] isPrimitive] == NO 
		|| [[self role] isKindOfClass: [ETRelationshipRole class]]);
}

- (BOOL) isAttribute
{
	return ([self isRelationship] == NO);
}

- (void) setRole: (ETRoleDescription *)role
{
	[self checkNotFrozen];
	ASSIGN(_role, role);
}

- (ETValidationResult *) validateValue: (id)value forKey: (NSString *)key
{
	ETRoleDescription *role = [self role];
	if (nil != role)
	{
		return [role validateValue: value forKey: key];
	}
	return [ETValidationResult validResult: value];
}

/* Inspired by the Java implementation of FAME */
- (void) checkConstraints: (NSMutableArray *)warnings
{
	if ([self isContainer] && [self isMultivalued])
	{
		[warnings addObject: [self warningWithMessage: 
			@"Container must refer to a single object"]];
	}
	if ([[self opposite] isString]) 
	{
		[warnings addObject: [self warningWithMessage: @"Failed to resolve opposite"]];
	}
	if ([self opposite] != nil && [[[self opposite] opposite] isEqual: self] == NO) 
	{
		[warnings addObject: [self warningWithMessage: 
			@"Opposites must refer to each other"]];
	}
	if ([[self type] isString])
	{
		[warnings addObject: [self warningWithMessage: @"Failed to resolve type"]];
	}
	if ([self type] == nil)
	{
		[warnings addObject: [self warningWithMessage: @"Miss a type"]];
	}
	if ([[self owner] isString])
	{
		[warnings addObject: [self warningWithMessage: @"Failed to resolve owner"]];
	}
	if ([self owner] == nil)
	{
		[warnings addObject: [self warningWithMessage: @"Miss an owner"]];
	}
	if ([[self owner] isKindOfClass: [ETEntityDescription class]] == NO)
	{
		[warnings addObject: [self warningWithMessage: 
			@"Owner must be an entity description"]];
	}
	if ([[self package] isString])
	{
		[warnings addObject: [self warningWithMessage: @"Failed to resolve package"]];
	}
	if ([self isDerived] && [self isReadOnly] == NO)
	{
		[warnings addObject: [self warningWithMessage: @"Derived implies read only"]];
	}
}

- (void)makeFrozen
{
	if (_isFrozen)
		return;

	_isFrozen = YES;
	
	[[self opposite] makeFrozen];
	[[self owner] makeFrozen];
}

@end


/*
 Property Role Description classes 
 
 These allow pluggable, more precise property descriptions with validation
 */
@implementation ETRoleDescription 

- (ETPropertyDescription *) parent
{
	return nil;
}

- (ETValidationResult *) validateValue: (id)value forKey: (NSString *)key
{
	return [ETValidationResult validResult: value];
}

@end


@implementation ETRelationshipRole

@synthesize mandatory = _mandatory, deletionRule = _deletionRule;

- (void) dealloc
{
	DESTROY(_deletionRule);
	[super dealloc];
}

- (void) setMandatory: (BOOL)isMandatory
{
	[[self parent] checkNotFrozen];
	_mandatory = isMandatory;
}

- (void) setDeletionRule: (NSString *)deletionRule
{
	[[self parent] checkNotFrozen];
	ASSIGNCOPY(_deletionRule, deletionRule);
}

@end


@implementation ETMultiOptionsRole

@synthesize allowedOptions = _allowedOptions;

- (void) dealloc
{
	DESTROY(_allowedOptions);
	[super dealloc];
}

- (void) setAllowedOptions: (NSArray *)options
{
	[[self parent] checkNotFrozen];
	ASSIGNCOPY(_allowedOptions, options);
}


- (ETValidationResult *) validateValue: (id)value forKey: (NSString *)key
{
	if ([(id)[[_allowedOptions mappedCollection] value] containsObject: value])
	{
		return [ETValidationResult validResult: value];
	}
	else
	{
		return [ETValidationResult validationResultWithValue: nil
													 isValid: NO
													   error: @"Value not in the allowable set"];
	}
}

@end


@implementation ETNumberRole

@synthesize  minimum = _minimum, maximum = _maximum;

- (void)setMinimum: (NSInteger)min
{
	[[self parent] checkNotFrozen];
	_minimum = min;
}

- (void)setMaximum: (NSInteger)max
{
	[[self parent] checkNotFrozen];
	_maximum = max;
}

- (ETValidationResult *) validateValue: (id)value forKey: (NSString *)key
{
	NSInteger intValue = [value integerValue];

	if (intValue <= _maximum && intValue >= _minimum)
	{
		return [ETValidationResult validResult: value];
	}
	else
	{
		NSNumber *invalidValue =
			[NSNumber numberWithInt: MAX(_minimum, MIN(_maximum, intValue))];

		return [ETValidationResult validationResultWithValue: invalidValue
													 isValid: NO
													   error: @"Value outside the allowable range"];
	}
}

@end
