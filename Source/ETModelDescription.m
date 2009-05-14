/*
	Copyright (C) 2008 Quentin Mathe

	Author:  Quentin Mathe <qmathe@club-internet.fr>
	Date:  August 2008
	License:  Modified BSD (see COPYING)
 */

#import "ETModelDescription.h"
#import "NSObject+Etoile.h"
#import "Macros.h"
#import "ETCompatibility.h"


@implementation ETModelDescription

static NSMutableDictionary *modelDescriptions = nil;

/** Initializes ETModelDescription class by scanning every classes currently 
available at runtime and registering the associated model description they might 
provide through +modelDescription. */
+ (void) initialize
{
	if (self == [ETModelDescription class])
	{
		modelDescriptions = [[NSMutableDictionary alloc] initWithCapacity: 500];
		FOREACH([NSObject allSubclasses], subclass, Class)
		{
			if ([subclass respondsToSelector: @selector(modelDescription)])
				[self registerModelDescription: [subclass modelDescription]];
		}
	}
}

/** Registers the given model description for various EtoileUI facilities that 
allow to change the UI at runtime, such as an inspector.

This also results in the publishing of the model description in the default 
aspect repository (not yet implemented). */
+ (void) registerModelDescription: (ETModelDescription *)aDescription
{
	[modelDescriptions setObject: aDescription forKey: [aDescription modelClassName]];
	// TODO: Make a class instance available as an aspect in the aspect repository.
}

/** Returns all the model description directly available for EtoileUI facilities 
that allow to transform the UI at runtime. */
+ (NSSet *) registeredModelDescriptions
{
	return [NSSet setWithArray: [modelDescriptions allValues]];
}

// TODO: +registeredModelDescriptionForType: or xxxForObject:...
+ (ETModelDescription *) registeredModelDescriptionForClass: (Class)aClass
{
	return [modelDescriptions objectForKey: NSStringFromClass(aClass)];
}

+ (ETModelDescription *) modelDescription
{
	NSArray *childDescriptions = A(STR_DESC(@"name"), STR_DESC(@"modelClassName"), 
		STR_DESC(@"label"), BOOL_DESC(@"readOnly"));

	return [ETEntityDescription descriptionWithPropertyDescriptions: childDescriptions
		type: NSStringFromClass(self)]; // FIXME: Should be -type or -UTI
}

+ (id) descriptionWithName: (NSString *)aName 
{
	return [self descriptionWithName: aName type: nil label: aName];
}

+ (id) descriptionWithName: (NSString *)aName type: (ETUTI *)anUTI label: (NSString *)aLabel
{
	return AUTORELEASE([[self alloc] initWithName: aName type: anUTI label: aLabel]);
}

// TODO: Probably provide a more exhaustive initializer with validationPredicates,
// priority, 
- (id) initWithName: (NSString *)aName type: (ETUTI *)anUTI label: (NSString *)aLabel
{
	SUPERINIT
	[self setName: aName];
	[self setModelType: anUTI];
	[self setLabel: aLabel];
	return self;
}

DEALLOC(DESTROY(_name); DESTROY(_modelType); DESTROY(_label); DESTROY(_groupName))

/** Returns the property name described by the receiver. */
- (NSString *) name
{
	return _name;
}

/** Sets the property name described by the receiver. */
- (void) setName: (NSString *)aName
{
	ASSIGN(_name, aName);
}

- (ETUTI *) modelType
{
	return _modelType;
}

- (void) setModelType: (ETUTI *)anUTI
{
	ASSIGN(_modelType, anUTI);
}

- (NSString *) modelClassName
{
	// TODO: Should be [[self modelType] className];
	return [self modelType];
}

- (void) setModelClassName: (NSString *)aClassName
{
	// TODO: Should be [[self setModelType: [ETUTI UTIWithClassName: aClassName]];
	[self setModelType: aClassName];
}

/** Returns whether the description element is read-only.

By default, returns NO.

For a property description, this means the value of the property can be 
retrieved, but not set in the model object described by the receiver. */
- (BOOL) isReadOnly
{
	return _readOnly;
}

/** Sets whether the description element is read-only. */
- (void) setReadOnly: (BOOL)flag
{
	_readOnly = flag;
}

/* Rendering */

- (void) setLayoutItemIdentifier: (NSString *)anIdentifier
{
	ASSIGN(_itemIdentifier, anIdentifier);
}

- (NSString *) layoutItemIdentifier
{
	return _itemIdentifier;
}

- (void) setLabel: (NSString *)aLabel
{
	ASSIGN(_label, aLabel);
}

- (NSString *) label
{
	return _label;
}

- (void) setGroupName: (NSString *)aName
{
	ASSIGN(_groupName, aName);
}

- (NSString *) groupName
{
	return _groupName;
}

@end

@implementation ETEntityDescription

+ (id) descriptionWithPropertyDescriptions: (NSArray *)descriptions type: (ETUTI *)anUTI
{
	return AUTORELEASE([[self alloc] initWithPropertyDescriptions: descriptions type: anUTI]);
}

- (id) initWithPropertyDescriptions: (NSArray *)descriptions type: (ETUTI *)anUTI
{
	self = [super initWithName: nil type: anUTI label: nil];
	if (self == nil)
		return nil;

	_propertyDescriptions = [[NSMutableDictionary alloc] init];
	FOREACH(descriptions, description, ETModelDescription *)
	{
		[self addPropertyDescription: description];
	}
	return self;
}

- (void) addPropertyDescription: (ETModelDescription *)aDescription
{
	[_propertyDescriptions setObject: aDescription forKey: [aDescription name]];
}

- (NSArray *) propertyDescriptions
{
	return AUTORELEASE([_propertyDescriptions copy]);
}

/** Returns an enumerator for -propertyDescriptions. */
- (NSEnumerator *) objectEnumerator
{
	return [_propertyDescriptions objectEnumerator];
}

@end

@implementation ETAttributeDescription

@end

@implementation ETBooleanDescription

@end

@implementation ETNumberDescription

+ (id) descriptionWithName: (NSString *)aName 
                      type: (ETUTI *)anUTI 
                     label: (NSString *)aLabel 
                  minValue: (double)aMin 
                  maxValue: (double)aMax
{
    return AUTORELEASE([[self alloc] initWithName: aName type: anUTI 
        label: aLabel minValue: aMin maxValue: aMax]);
}

- (id) initWithName: (NSString *)aName 
               type: (ETUTI *)anUTI 
              label: (NSString *)aLabel 
           minValue: (double)aMin 
           maxValue: (double)aMax
{
    self = [super initWithName: aName type: anUTI label: aLabel];
    if (self == nil)
        return nil;

    [self setMaxValue: aMax];
    [self setMinValue: aMin];
    return self;
}

- (double) maxValue
{
	return _maxValue;
}

- (void) setMaxValue: (double)aValue
{
	_maxValue = aValue;
}

- (double) minValue
{
	return _minValue;
}

- (void) setMinValue: (double)aValue
{
	_minValue = aValue;
}

@end

@implementation ETStringDescription

@end


