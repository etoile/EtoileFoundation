/**
    Copyright (C) 2009 Eric Wasylishen, Quentin Mathe

    Date:  July 2009
    License:  Modified BSD (see COPYING)
 */

#import <EtoileFoundation/ETPropertyValueCoding.h>
#import <EtoileFoundation/ETCollection.h>
#import <EtoileFoundation/ETModelElementDescription.h>

@class ETUTI, ETEntityDescription, ETPackageDescription, ETValidationResult;
@class ETRoleDescription;

/**
 * @group Metamodel
 * @abstract Description of an entity's property.
 *
 * A property description represents either an attribute or a relationship 
 * that belongs to an entity. Whether a property represents an attribute or 
 * relationships depends on the -type (the entity description for the propery 
 * value).
 *
 * For a primitive type (see -[ETEntityDescription isPrimitive]), the property 
 * is an attribute. For a non-primitive type, it is a relationship. For more 
 * explanations, -isAttribute and -isRelationship.
 *
 * @section Conceptual Model
 *
 * For a Metamodel overview, see ETModelElementDescription.
 *
 * @section Model Description
 *
 * ETPropertyDescription provides a large number of properties to describe 
 * the model, these properties can be split into three categories:
 *
 * <deflist>
 * <term>Model Specification</term><desc>Properties to describe new and existing 
 * model and metamodel (the FAME-based metamodel)</desc>
 * <term>Persistency Specification</term><desc>Properties to describe persistent 
 * model and persistency rules (can be leveraged or not by a Persistency 
 * framework e.g. CoreObject)</desc>
 * <term>Model Presentation Specification</term><desc>Properties to describe 
 * model presentation in the UI, and model-driven generation (can be leveraged 
 * or not by a UI or Model Generation framework)</desc>
 * </deflist>
 *
 * The Model Specification properties must be edited to get working metamodel.
 *
 * Both Persistency and Model Presentation Specifications are optional. These 
 * additional specifications are usually generic enough to be reused by 
 * Persistency and UI frameworks other than CoreObject and EtoileUI.
 *
 * Warning: For now, CoreObject validation rules are hardcoded into 
 * -[ETPropertyDescription checkConstraints:], and this limits the possibility 
 * to reuse the Persistency Specification without CoreObject.
 *
 * Additional properties or specification can be added by subclassing 
 * ETPropertyDescription. In the future, we will probably support extending 
 * the metamodel dynamically at run-time too.
 *
 * @section Role and Validation
 *
 * A role can be set to provide validation rules that describe attribute or 
 * relationship constraints in a particular metamodel. The role must be 
 * compatible with the current -type. For example, when -isRelationship is NO, 
 * setting a ETRelationshipRole will cause a warning in -checkConstraints. 
 *
 * The validation is delegated to the role by -validateValue:forKey:.
 *
 * @section Multivalues
 *
 * Both attributes and relationships can be univalued or multivalued. A 
 * multivalued relationship is a too-many relationship, while a univalued 
 * relationship is a to-one relationship. A multivalued attribute is a 
 * value object collection (multivalued relationships are entity object 
 * collections).
 *
 * @section Late-Bound References
 *
 * For easily creating property descriptions that refer to each other or 
 * entity descriptions, without worrying about the dependencies accross all 
 * the model element descriptions, ETPropertyDescriptions includes properties 
 * such as -setOppositeName: or -setTypeName: that can be used to refer to 
 * other ETModelElementDescription objects by their -name or -fullName.  
 *
 * When all these related descriptions are added to a repository with 
 * -[ETModelDescriptionRepository addUnresolvedDescription:], 
 * -[ETModelDescriptionRepository resolveNamedObjectReferences] can be called 
 * to resolve the name references to their real objects. 
 *
 * For example, the -opposite is set based on the ETPropertyDescription object 
 * returned by -[ETModelDescriptionRepository descriptionForName:] for 
 * -oppositeName.
 *
 * For properties descriptions added to entity descriptions returned by 
 * +[NSObject newEntityDescription], all these model element descriptions are 
 * collected and resolved in the main repository. For other repositories or 
 * entity descriptions created outside of +[NSObject newEntityDescription], 
 * you must call -[ETModelDescriptionRepository resolveNamedObjectReferences]  
 * manually.
 *
 * @section Freezing
 *
 * If -isPersistent returns NO and the opposite is not persistent either, the 
 * property description won't be frozen when the owner is, and mutating the 
 * property description state will remain possible (except turning it into a 
 * persistent property description).
 *
 * If -isFrozen is YES, the property description is largely immutable, only 
 * the properties declared in Model Presentation remains mutable (to support 
 * customizing the UI generation for persistent objects at run-time).
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
/** Returns an autoreleased property description.

The given name and type name must not be nil, otherwise an 
NSInvalidArgumentException is raised. */
+ (ETPropertyDescription *) descriptionWithName: (NSString *)aName 
                                       typeName: (NSString *)aTypeName;

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
 *
 * <deflist>
 * <term>isContainer</term><desc>is a child property and the to-one relationship 
 * to the parent</desc>
 * <term>isComposite</term><desc>is a parent property and the to-many 
 * relationship to the children</desc>
 * </deflist>
 *
 * isContainer is derived, it is automatically YES when for a one-to-many
 * relationship.
 *
 * For CoreObject, a container property is derived, so it must not be set as persistent. 
 */
@property (nonatomic, readonly) BOOL isContainer;
/**
 * A derived property can be read-only or not. For example, a setter can exist 
 * without any associated state, that converts the given value and calls another 
 * setter bound to a non-derived property.
 */
@property (nonatomic, assign, getter=isDerived) BOOL derived;
/**
 * Whether this property represents a multivalue or not.
 *
 * A multivalue can be either a collection containing value objects (if -type 
 * returns a primitive entity) or a to-many relationship (unidirectional or 
 * bidirectional).
 *
 * If set to NO, the property represents either an attribute or a to-one 
 * relationship (unidirectional or bidirectional).
 *
 * See also -opposite, -isRelationship, isAttribute, isOrdered and -isKeyed.
 */
@property (nonatomic, assign, getter=isMultivalued) BOOL multivalued;
/**
 * Whether this property represents an ordered multivalue or not.
 *
 * An ordered multivalue can be either an ordered collection containing value 
 * objects (if -type returns a primitive entity) or an ordered relationship 
 * (unidirectional or bidirectional).
 *
 * See also -isMultivalued and -isKeyed.
 */
@property (nonatomic, assign, getter=isOrdered) BOOL ordered;
/**
 * Whether this property represents a keyed multivalue or not.
 *
 * A keyed multivalue can be either a keyed collection containing value objects 
 * (if -type returns a primitive entity) or a keyed relationship.
 *
 * If keyed is set to YES, multivalued must be set to YES too.
 *
 * Keyed multivalues can be ordered or not, although in Objective-C, the 
 * built-in keyed collections such NSDictionary are unordered.
 *
 * For CoreObject, -opposite must be nil since keyed bidirectional relationships 
 * are not supported.
 *
 * See also -isMultivalued and -isOrdered.
 */
@property (nonatomic, assign, getter=isKeyed) BOOL keyed;

/**
 * Read-only properties can be persistent, for set-once properties. Useful for 
 * properties of immutable objects, for which the value is set initially by 
 * passing it to the initializer.
 *
 * See -isDerived.
 */
@property (nonatomic, assign, getter=isReadOnly) BOOL readOnly;
/** Can be self, if the relationship is reflexive. For example, a "spouse" 
property or a "cousins" property that belong to a "person" entity.<br />
For reflexive relationships, one-to-one or many-to-many are the only valid 
cardinality. */
@property (nonatomic, assign) ETPropertyDescription *opposite;


/** @taskunit Owning Entity and Package */


/**
 * The entity to which the property belongs to.
 */
@property (nonatomic, assign) ETEntityDescription *owner;
/**
 * The package to which the property belongs to.
 *
 * Take note that a property can belong to another package than its owning 
 * entity. This means the property is an extension (e.g. a property declared in 
 * an Objective-C category).
 */
@property (nonatomic, assign) ETPackageDescription *package;


/** @taskunit Persistency */


/**
 * Whether this property is persistent or transient.
 *
 * Interpreting this property is up to a Persistency framework.
 *
 * If the owner is frozen, any attempt to set this property raises an exception.
 */
@property (nonatomic, assign, getter=isPersistent) BOOL persistent;
/**
 * Whether this property value should be indexed in a search index.
 *
 * Interpreting this property is up to an Search framework.
 */
@property (nonatomic, assign, getter=isIndexed) BOOL indexed;
/**
 * The serialization transformer to convert the property value from -type to 
 * -persistentType.
 *
 * A Persistency framework can use the returned name to look up a serialization 
 * transformer and convert the property value into a new value whose type is 
 * supported by the serialization format (known as -persistenType).
 */
@property (nonatomic, copy) NSString *valueTransformerName;
/**
 * The type used in the persistent storage to represent the property value.
 *
 * By default, returns -type.
 *
 * For a property value handed to a serialization transformer, this must be set 
 * to the type of the returned value.
 */
@property (nonatomic, retain) ETEntityDescription *persistentType;
/**
 * An object providing the commit metadata to be saved each time the property 
 * value is updated (usually in response to the user editing).
 *
 * The metamodel doesn't define a type for this object, this is the 
 * responsability of the Persistency framework. For example, CoreObject provides 
 * a COCommitDescriptor class to fullfil this role.
 *
 * The Persistency framework can look up the metamodel to retrieve this 
 * descriptor on every save that concerns the given property.
 */
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
/**
 * Returns YES when the property is persistent and its persistent type is not 
 * a primitive.
 *
 * See -isPersistent and -persistentType.
 */
@property (nonatomic, readonly) BOOL isPersistentRelationship;


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


/** @taskunit Internal */


/**
 * <override-subclass />
 * Marks the receiver as frozen. From this point, if -isPersistent returns YES 
 * and the owner is frozen, the receiver is immutable and any attempt to mutate
 * it will cause an exception to be thrown.
 */
- (void) makeFrozen;

@end
