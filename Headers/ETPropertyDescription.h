/**
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
 * @abstract Description of an entity's property.
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
	NSString *_oppositeName;
	NSString *_ownerName;
	NSString *_packageName;
	NSString *_typeName;
	NSString *_persistentTypeName;
}


/** @taskunit Metamodel Description */


/** Self-description (aka meta-metamodel). */
+ (ETEntityDescription *) newEntityDescription;


/** @taskunit Initialization */


/** Returns an autoreleased property description.

The given name and type must not be nil, otherwise an NSInvalidArgumentException 
is raised. */
+ (ETPropertyDescription *) descriptionWithName: (NSString *)aName 
                                           type: (ETEntityDescription *)aType;


/** @taskunit Querying Type and Role */


/** Returns YES. */
@property (nonatomic, readonly) BOOL isPropertyDescription;
/** The entity that describes the property's value.

This is the type of the attribute or destination entity.<br />
Whether the property is a relationship or an attribute depends on the returned
entity. See -isRelationship. */
@property (nonatomic, retain) ETEntityDescription *type;
/** Returns 'Property (type of the value)'.

If -type returns a valid entity description, the parenthesis contains the 
entity name in the returned string. */
@property (nonatomic, readonly) NSString *typeDescription;
@property (nonatomic, retain) id role;
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
@property (nonatomic, assign, getter=isReadOnly) BOOL readOnly;
/** Can be self, if the relationship is reflexive. For example, a "spouse" 
property or a "cousins" property that belong to a "person" entity.<br />
For reflexive relationships, one-to-one or many-to-many are the only valid 
cardinality. */
@property (nonatomic, assign) ETPropertyDescription *opposite;


/** @taskunit Owning Entity and Package */


@property (nonatomic, assign) ETEntityDescription *owner;
@property (nonatomic, assign) ETPackageDescription *package;


/** @taskunit Persistency */


@property (nonatomic, assign, getter=isPersistent) BOOL persistent;
@property (nonatomic, assign, getter=isIndexed) BOOL indexed;
@property (nonatomic, copy) NSString *valueTransformerName;
@property (nonatomic, retain) ETEntityDescription *persistentType;
@property (nonatomic, retain) id commitDescriptor;


/** @taskunit Late-bound References */


/** 
 * The full name of the relationship opposite property (the package name as a 
 * prefix is optional for the anonymous package).
 *
 * -[ETModelDescriptionRepository resolveNamedObjectReferences] sets -opposite 
 * based on the opposite name. Once resolved, -oppositeName returns nil.
 *
 * This property doesn't appear in the meta-metamodel, see +newEntityDescription.
 *
 * You should use this setter inside +[NSObject newEntityDescription].
 */
@property (nonatomic, copy) NSString *oppositeName;
/** 
 * The name of the package to which this entity belongs to.
 *
 * -[ETModelDescriptionRepository resolveNamedObjectReferences] sets -owner 
 * based on the owner name. Once resolved, -ownerName returns nil.
 *
 * This property doesn't appear in the meta-metamodel, see +newEntityDescription.
 *
 * You should use this setter inside +[NSObject newEntityDescription]. 
 */
@property (nonatomic, copy) NSString *ownerName;
/** 
 * The name of the package to which this property belongs to (as an extension).
 *
 * -[ETModelDescriptionRepository resolveNamedObjectReferences] sets -package   
 * based on the package name. Once resolved, -packageName returns nil.
 *
 * You should use this setter inside +[NSObject newEntityDescription].
 *
 * This property doesn't appear in the meta-metamodel, see +newEntityDescription.
 */
@property (nonatomic, copy) NSString *packageName;
/** 
 * The name of the entity that describes the property's value.
 *
 * -[ETModelDescriptionRepository resolveNamedObjectReferences] sets -type  
 * based on the type name. Once resolved, -typeName returns nil.
 *
 * You should use this setter inside +[NSObject newEntityDescription].
 *
 * This property doesn't appear in the meta-metamodel, see +newEntityDescription.
 */
@property (nonatomic, copy) NSString *typeName;
/** 
 * The name of the entity that describes the property's persistent value.
 *
 * -[ETModelDescriptionRepository resolveNamedObjectReferences] sets 
 * -persistentType based on the persistent type name. Once resolved, 
 * -persistentTypeName returns nil.
 *
 * You should use this setter inside +[NSObject newEntityDescription].
 *
 * This property doesn't appear in the meta-metamodel, see +newEntityDescription.
 */
@property (nonatomic, copy) NSString *persistentTypeName;


/** @taskunit Model Presentation */


@property (nonatomic, assign) BOOL showsItemDetails;
@property (nonatomic, copy) NSArray *detailedPropertyNames;


/** @taskunit Validation */


- (ETValidationResult *) validateValue: (id)value forKey: (NSString *)key;
/**
 * Pass a block which takes one argument (the value being validated)
 * and returns an ETValidationResult
 */
//- (void) setValidationBlock: (id)aBlock;

@end
