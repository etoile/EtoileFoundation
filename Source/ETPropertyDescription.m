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

+ (id) descriptionWithName: (NSString *)name
                     owner: (ETEntityDescription *)owner
{
	return [[[ETPropertyDescription alloc] initWithName: name
	                                             owner: owner] autorelease];
}

- (id) initWithName: (NSString *)name
              owner: (ETEntityDescription *)owner
{
	SUPERINIT
	ASSIGN(_name, name);
	_ordered = NO;
	_owner = owner;
	_multivalued = NO;
	_parent = NO;
	_role = nil;
	_UTI = [[ETUTI typeWithClass: [NSObject class]] retain];

	[_owner addPropertyDescriptionsObject: self];
	return self;
}
- (void) dealloc
{
	[_name release];
	[_UTI release];
	[_role release];
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
- (void) setParent: (BOOL)isParent
{
	_parent = isParent;
	if (isParent)
	{
		FOREACH([[self owner] propertyDescriptions], otherProperty, ETPropertyDescription *)
		{
			if (otherProperty != self)
			{
				[otherProperty setParent: NO];
			}
		}
		[self setMultivalued: NO];
	}
	//FIXME: do other checks that the parent link is valid
}
- (BOOL) isDerived
{
	return _derived;
}
- (void) setDerived: (BOOL)isDerived
{
	_derived = isDerived;
}
- (BOOL) isMultivalued
{
	return _multivalued;
}
- (void) setMultivalued: (BOOL)isMultivalued
{
	_multivalued = isMultivalued;
}
- (BOOL) isOrdered
{
	return _ordered;
}
- (void) setOrdered: (BOOL)isOrdered
{
	_ordered = isOrdered;
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
	if (opposite == _opposite || opposite == self)
	{
		return;
	}
	if (nil != _opposite)
	{
		[_opposite setOpposite: nil];
	}
	
	_opposite = opposite;
	if (nil != _opposite)
	{
		if ([_opposite opposite] != self)
		{
			[_opposite setOpposite: self];
		}
		[self setUTI: [[_opposite owner] UTI]];
	}
}
- (ETEntityDescription *) owner
{
	return _owner;
}
- (void) setOwner: (ETEntityDescription *)owner
{
	if ([self owner] != nil)
	{
		[[self owner] removePropertyDescriptionsObject: self]; // TODO: use correct accessor to modify collection
	}
	[owner addPropertyDescriptionsObject: self];
	_owner = owner;
}
- (ETUTI *) UTI
{
	return _UTI;
}
- (void) setUTI: (ETUTI *)type
{
	ASSIGN(_UTI, type);
}
- (ETRoleDescription *) role
{
	return _role;
}
- (void) setRole: (ETRoleDescription *)role
{
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

- (BOOL) isMandatory
{
	return _isMandatory;
}

- (void) setMandatory: (BOOL)isMandatory
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

- (void) setAllowedOptions: (NSArray *)allowedOptions
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


@implementation ETNumberRole
- (int)minimum
{
	return _min;
}
- (void)setMinimum: (int)min
{
	_min = min;
}
- (int)maximum
{
	return _max;
}
- (void)setMaximum: (int)max
{
	_max = max;
}

- (ETValidationResult *) validateValue: (id)value forKey: (NSString *)key
{
	int intValue = [value intValue];
	if (intValue <= _max && intValue >= _min)
	{
		return [ETValidationResult validResult: value];
	}
	else
	{
		return [ETValidationResult validationResultWithValue: [NSNumber numberWithInt: MAX(_min, MIN(_max, intValue))]
													 isValid: NO
													   error: @"Value outside the allowable range"];
	}
}
@end
