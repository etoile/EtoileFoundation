/*
    Copyright (C) 2009 Eric Wasylishen, Quentin Mathe

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
#import "ETRoleDescription.h"
#import "ETUTI.h"
#import "ETValidationResult.h"
#import "NSObject+Model.h"
#import "Macros.h"
#import "EtoileCompatibility.h"


@implementation ETPropertyDescription

@synthesize derived = _derived, multivalued = _multivalued, ordered = _ordered, keyed = _keyed;
@synthesize persistent = _persistent, readOnly = _readOnly;
@synthesize opposite = _opposite, owner = _owner, package = _package, type = _type, role = _role;
@synthesize oppositeName = _oppositeName, ownerName = _ownerName, packageName = _packageName;
@synthesize typeName = _typeName, persistentTypeName = _persistentTypeName;
@synthesize showsItemDetails = _showsItemDetails, detailedPropertyNames = _detailedPropertyNames;
@synthesize commitDescriptor = _commitDescriptor, indexed = _indexed,
    valueTransformerName = _valueTransformerName;

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

+ (ETPropertyDescription *) descriptionWithName: (NSString *)aName 
                                       typeName: (NSString *)aTypeName
{
    ETPropertyDescription *desc = AUTORELEASE([[self alloc] initWithName: aName]);
    NILARG_EXCEPTION_TEST(aTypeName);
    [desc setTypeName: aTypeName];
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
    DESTROY(_oppositeName);
    DESTROY(_ownerName);
    DESTROY(_packageName);
    DESTROY(_typeName);
    DESTROY(_persistentTypeName);
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
    if (_opposite != nil)
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
    if ([_owner isFrozen] && !_isFrozen)
    {
        ETAssert(!_persistent);
        [NSException raise: NSGenericException
                    format: @"A transient property %@ cannot become persistent "
                             "once its owner has been frozen (marked as immutable)", self];
    }
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
    _showsItemDetails = showsItemDetails;
}

- (void)setDetailedPropertyNames: (NSArray *)detailedPropertyNames
{
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
    // TODO: Remove once all code used -setOppositeName:
    if ([opposite isString])
    {
        [self setOppositeName: (id)opposite];
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
    // TODO: Remove once all code used -setOwnerName:
    if ([owner isString])
    {
        [self setOwnerName: (id)owner];
        return;
    }

    NSParameterAssert((_owner != nil && owner == nil) || (_owner == nil && owner != nil));

    _owner = owner;

    if ([self opposite] != nil)
    {
        [[self opposite] setType: owner];
    }
}

- (void) setPackage: (ETPackageDescription *)aPackage
{
    [self checkNotFrozen];
    // TODO: Remove once all code used -setPackageName:
    if ([aPackage isString])
    {
        [self setPackageName: (id)aPackage];
        return;
    }

    _package = aPackage;
}

- (void) setType: (ETEntityDescription *)anEntityDescription
{
    [self checkNotFrozen];
    // TODO: Remove once all code used -setTypeName:
    if ([anEntityDescription isString])
    {
        [self setTypeName: (id)anEntityDescription];
        return;
    }

    ASSIGN(_type, anEntityDescription);
}

- (void)setValueTransformerName: (NSString *)aTransformerName
{
    [self checkNotFrozen];
    ASSIGNCOPY(_valueTransformerName, aTransformerName);
}

- (ETEntityDescription *) persistentType
{
    return (_persistentType != nil ? _persistentType : _type);
}

- (void) setPersistentType: (ETEntityDescription *)anEntityDescription
{
    [self checkNotFrozen];
    // TODO: Remove once all code used -setPersistentTypeName:
    if ([anEntityDescription isString])
    {
        [self setPersistentTypeName: (id)anEntityDescription];
        return;
    }

    ASSIGN(_persistentType, anEntityDescription);
}

- (BOOL)isPersistentRelationship
{
    return _persistent && !self.persistentType.isPrimitive;
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
    if ([self oppositeName] != nil)
    {
        [warnings addObject: [self warningWithMessage: @"Failed to resolve opposite"]];
    }
    if ([self opposite] != nil && [[[self opposite] opposite] isEqual: self] == NO) 
    {
        [warnings addObject: [self warningWithMessage: 
            @"Opposites must refer to each other"]];
    }
    if ([self typeName] != nil)
    {
        [warnings addObject: [self warningWithMessage: @"Failed to resolve type"]];
    }
    if ([self type] == nil)
    {
        [warnings addObject: [self warningWithMessage: @"Miss a type"]];
    }
    if ([self persistentTypeName] != nil)
    {
        [warnings addObject: [self warningWithMessage: @"Failed to resolve type"]];
    }
    if ([self ownerName] != nil)
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
    if ([self packageName] != nil)
    {
        [warnings addObject: [self warningWithMessage: @"Failed to resolve package"]];
    }
    if ([self isDerived] && [self isReadOnly] == NO)
    {
        [warnings addObject: [self warningWithMessage: @"Derived implies read only"]];
    }
    if ([self isDerived] && [self isPersistent])
    {
        [warnings addObject: [self warningWithMessage: @"Derived implies not persistent"]];
    }

    // TODO: The constraints that follow are CoreObject related, and shouldn't
    // be intermingled with the core metamodel constraints.

    if ([[self opposite] isPersistent] && [self isContainer] && [self isDerived] == NO)
    {
        [warnings addObject: [self warningWithMessage:
            @"If opposite is persistent, container implies derived in CoreObject"]];
    }
    if ([self isPersistent] && [self opposite] != nil && [[self opposite] isPersistent])
    {
        [warnings addObject: [self warningWithMessage: 
            @"Persistent implies non persistent opposite in CoreObject"]];
    }
    if ([self isPersistent] && [self opposite] != nil && [[self opposite] isDerived] == NO)
    {
        [warnings addObject: [self warningWithMessage: 
            @"Persistent implies derived opposite in CoreObject"]];
    }
    if ([[self opposite] isPersistent] && [self isOrdered])
    {
        [warnings addObject: [self warningWithMessage: 
            @"If opposite is persistent, derived implies not ordered in CoreObject"]];
    }
    if ([self isPersistent] && [self isKeyed] && [self opposite] != nil)
    {
        [warnings addObject: [self warningWithMessage: 
            @"Persistent keyed implies no opposite in CoreObject"]];
    }
    if ([[self opposite] isPersistent]
        && ETGetInstanceVariableValueForKey(self, NULL, [self name]))
    {
        [warnings addObject: [self warningWithMessage: 
            @"If opposite is persistent, name must match no ivar in CoreObject"]];
    }
}

- (void)makeFrozen
{
    if (_isFrozen || (!_persistent && ![[self opposite] isPersistent]))
        return;

    _isFrozen = YES;
    
    [[self opposite] makeFrozen];
    [[self owner] makeFrozen];
}

@end
