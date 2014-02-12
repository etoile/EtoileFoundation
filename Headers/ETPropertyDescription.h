/*
 ETPropertyDescription.h
 
 A model description framework inspired by FAME 
 (http://scg.unibe.ch/wiki/projects/fame)
 
 Copyright (C) 2009 Eric Wasylishen
 
 Author:  Eric Wasylishen <ewasylishen@gmail.com>
 Date:  July 2009
 License:  Modified BSD (see COPYING)
 */

#import <EtoileFoundation/ETPropertyValueCoding.h>
#import <EtoileFoundation/ETCollection.h>
#import <EtoileFoundation/ETModelElementDescription.h>

@class ETUTI, ETEntityDescription, ETPackageDescription, ETValidationResult;
@class ETRoleDescription;

/**
 * @group Model and Metamodel
 *
 * Description of an entity's property.
 */
@interface ETPropertyDescription : ETModelElementDescription
{
	@private
	BOOL _derived;
	BOOL _container;
	BOOL _multivalued;
	BOOL _ordered;
	BOOL _keyed;
	BOOL _persistent;
	BOOL _readOnly;
	BOOL _showsItemDetails;
	NSArray *_detailedPropertyNames;
	id _commitDescriptor;
	ETPropertyDescription *_opposite;
	ETEntityDescription *_owner;
	ETPackageDescription *_package;
	ETEntityDescription *_type;
	ETRoleDescription *_role;
	BOOL _isSettingOpposite; /* Flag to exit when -setOpposite: is reentered */
	BOOL _indexed;
	NSString *_valueTransformerName;
	ETEntityDescription *_persistentType;
}

/** @taskunit Initialization */

/** Returns an autoreleased property description.

The given name and type must not be nil, otherwise an NSInvalidArgumentException 
is raised. */
+ (ETPropertyDescription *) descriptionWithName: (NSString *)aName 
                                           type: (ETEntityDescription *)aType;

/** @taskunit Querying Type */

/** Returns YES. */
@property (nonatomic, readonly) BOOL isPropertyDescription;
/** Returns 'Property (type of the value)'.

If -type returns a valid entity description, the parenthesis contains the 
entity name in the returned string. */
@property (nonatomic, readonly) NSString *typeDescription;

/** @taskunit Model Specification */

/**
 * If YES, this property's value/values are the child/children of the entity
 * this property belongs to.
 *
 * isComposite is derived from opposite.isContainer
 *
 * See also -isContainer.
 */
@property (nonatomic, readonly) BOOL isComposite;
/**
 * If YES, this property's value is the parent of the entity this property
 * belongs to. 
 *
 * isContainer/isComposite describes an aggregate relationship where:
 * <deflist>
 * <term>isContainer</term><desc>is a child property and the to-one relationship 
 * to the parent</desc>
 * <term>isComposite</term><desc>is a parent property and the to-many 
 * relationship to the children</desc>
 * </deflist>
 *
 * isContainer is derived, it is automatically YES when for a one-to-many
 * relationship.
 */
@property (nonatomic, readonly) BOOL isContainer;
@property (nonatomic, assign, getter=isDerived) BOOL derived;
@property (nonatomic, assign, getter=isMultivalued) BOOL multivalued;
@property (nonatomic, assign, getter=isOrdered) BOOL ordered;
@property (nonatomic, assign, getter=isKeyed) BOOL keyed;
@property (nonatomic, assign, getter=isPersistent) BOOL persistent;
@property (nonatomic, assign, getter=isReadOnly) BOOL readOnly;
@property (nonatomic, retain) id commitDescriptor;
@property (nonatomic, assign) BOOL showsItemDetails;
@property (nonatomic, copy) NSArray *detailedPropertyNames;

@property (nonatomic, assign, getter=isIndexed) BOOL indexed;

/** Can be self, if the relationship is reflexive. For example, a "spouse" 
property or a "cousins" property that belong to a "person" entity.<br />
For reflexive relationships, one-to-one or many-to-many are the only valid 
cardinality. */
@property (nonatomic, assign) ETPropertyDescription *opposite;
@property (nonatomic, assign) ETEntityDescription *owner;
@property (nonatomic, assign) ETPackageDescription *package;
/** The entity that describes the property's value.

This is the type of the attribute or destination entity.<br />
Whether the property is a relationship or an attribute depends on the returned 
entity. See -isRelationship. */
@property (nonatomic, retain) ETEntityDescription *type;

@property (nonatomic, copy) NSString *valueTransformerName;
@property (nonatomic, retain) ETEntityDescription *persistentType;

/** Returns YES when this property is a relationship to the destination entity
returned by -type, otherwise returns NO when the property is an attribute.

When the destination entity is a primitive, then the property is an attribute 
unless the role is explicitly set to ETRelationshipRole.

isRelationship is derived from type.isPrimitive and role. */
@property (nonatomic, readonly) BOOL isRelationship;
/** Returns YES when the property is an attribute and NO when it is a 
relationship.

isAttribute is derived from isRelationship.

See -isRelationship. */
@property (nonatomic, readonly) BOOL isAttribute;

@property (nonatomic, retain) id role;

/** @taskunit Validation */

- (ETValidationResult *) validateValue: (id)value forKey: (NSString *)key;
/**
 * Pass a block which takes one argument (the value being validated)
 * and returns an ETValidationResult
 */
//- (void) setValidationBlock: (id)aBlock;

@end


/** @group Model and Metamodel

Property Role Description classes.
 
These allow a pluggable, more precise property description. */
@interface ETRoleDescription : NSObject
{
}

@property (nonatomic, readonly) ETPropertyDescription *parent;

- (ETValidationResult *) validateValue: (id)value forKey: (NSString *)key;

@end

/** @group Model and Metamodel */
@interface ETRelationshipRole : ETRoleDescription
{
	@private
	BOOL _mandatory;
	NSString *_deletionRule;
}

@property (nonatomic, assign, getter=isMandatory) BOOL mandatory;
@property (nonatomic, copy) NSString *deletionRule;

@end

/** @group Model and Metamodel */
@interface ETMultiOptionsRole : ETRoleDescription
{
	@private
	NSArray *_allowedOptions;
}

/** The ETKeyValuePair objects that represent the options.
 
-[ETKeyValuePair value] is expected to return the option value (e.g. a NSNumber 
for an enumeration) and -[ETKeyValuePair key] to return the option name.
 
You can use a localized string as the pair key to present the options in the UI. */
@property (nonatomic, copy) NSArray *allowedOptions;

@end

/** @group Model and Metamodel */
@interface ETNumberRole : ETRoleDescription
{
	@private
	NSInteger _minimum;
	NSInteger _maximum;
}

@property (nonatomic, assign) NSInteger minimum;
@property (nonatomic, assign) NSInteger maximum;

@end
