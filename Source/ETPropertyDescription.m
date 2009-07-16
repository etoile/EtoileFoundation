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
#import "ETCollection.h"
#import "ETReflection.h"
#import "Macros.h"
#import "EtoileCompatibility.h"


@implementation ETPropertyDescription

+ (id)  propertyWithName: (NSString *)name
			    ofEntity: (ETEntityDescription *)owner
{
	return [[[ETPropertyDescription alloc] initWithName: name
												 entity: owner] autorelease];
}

- (id) initWithName: (NSString *)name
             entity: (ETEntityDescription *)owner
{
	SUPERINIT
	ASSIGN(_name, name);
	_owner = owner;
	return self;
}
- (void) dealloc
{
	[_name release];
	[_type release];
	[super dealloc];
}

/* Properties */

- (BOOL) isChildren
{
	return [[self opposite] isParent];
}
- (BOOL) isParent
{
	return _parent;
}
- (void) setIsParent: (BOOL)isParent
{
	_parent = isParent;
	[self _updateParentLink];
}
- (BOOL) isDerived
{
	return _derived;
}
- (void) setIsDerived: (BOOL)isDerived
{
	_derived = isDerived;
}
- (BOOL) isMultivalued
{
	return _multivalued;
}
- (BOOL) setIsMultivalued: (BOOL)isMultivalued
{
	_multivalued = isMultivalued;
}
- (NSString *) name
{
	return _name;
}
- (void) setName: (NSString *)name
{
	ASSIGN(_name, name);
}
- (ETPropertyDescription *) opposite
{
	return _opposite;
}
- (void) setOpposite: (ETPropertyDescription *)opposite
{
	if (opposite == self)
	{
		return;
	}
	if (_opposite != nil)
	{
		[_opposite setOpposite: nil];
	}
	[opposite setOpposite: self];
	_opposite = opposite;
}
- (ETEntityDescription *) owner
{
	return _owner;
}
- (void) setOwner: (ETEntityDescription *)owner
{
	if (_owner != nil)
	{
		[[_owner propertyDescriptions] removeObject: self];
	}
	[[owner propertyDescriptions] addObject: self];
	_owner = owner;
}
- (ETUTI *) type
{
	return _type;
}
- (void) setType: (ETUTI *)type
{
	ASSIGN(_type, type);
}


@end



/* Property Role Description classes 
 
 These allow a pluggable, more precise property description
 
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

- (BOOL) isMandatory
{
	return _isMandatory;
}

- (void) setIsMandatory: (BOOL)isMandatory
{
	_isMandatory = isMandatory;
}

- (NSString *) deletionRule
{
	return _deletionRule;
}

- (void) setDeletionRule: (NSString *)deletionRule
{
	ASSIGN(_deletionRule, deletionRule);
}

@end

@implementation ETMultiOptionsRole

- (void) dealloc
{
	DESTROY(_allowedOptions);
	[super dealloc];
}

- (void) setAllowedOptions: (NSString *)allowedOptions
{
	ASSIGN(_allowedOptions, [allowedOptions copy]);
}

- (NSArray *) allowedOptions
{
	return _allowedOptions;
}

- (ETValidationResult *) validateValue: (id)value forKey: (NSString *)key
{
	if ([_allowedOptions containsObject: value])
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
