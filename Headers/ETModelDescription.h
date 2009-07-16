/*
	Copyright (C) 2008 Quentin Mathe

	Author:  Quentin Mathe <qmathe@club-internet.fr>
	Date:  August 2008
	License:  Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#if 0
// WARNING: Do not use, this is an API sketch to provide a metamodel that can 
// be used to describe Objective-C model objects/classes a la Magritte.

#define ETUTI NSString

#define BOOL_DESC(key) [ETBooleanDescription descriptionWithName: key]
#define STR_DESC(key) [ETStringDescription descriptionWithName: key]
#define NB_DESC(key, min, max) \
[ETNumberDescription descriptionWithName: key \
                                    type: nil \
                                   label: key \
                                minValue: min \
                                maxValue: max]

// ETPropertyDescription? or ETModelElementDescription?
@interface ETModelDescription : NSObject 
{
	NSString *_name;
	ETUTI *_modelType;
	NSString *_itemIdentifier;
	NSString *_label;
	NSString *_groupName;
	BOOL _readOnly;
}

+ (void) registerModelDescription: (ETModelDescription *)aDescription;
+ (ETModelDescription *) registeredModelDescriptionForClass: (Class)aClass;

+ (ETModelDescription *) modelDescription;

+ (id) descriptionWithName: (NSString *)aName;
+ (id) descriptionWithName: (NSString *)aName type: (ETUTI *)anUTI label: (NSString *)aLabel;

- (id) initWithName: (NSString *)aName type: (ETUTI *)anUTI label: (NSString *)aLabel;

/* Model */

- (void) setName: (NSString *)aName;
- (NSString *) name;

- (ETUTI *) modelType;
- (void) setModelType: (ETUTI *)anUTI;
- (NSString *) modelClassName;
- (void) setModelClassName: (NSString *)aClassName;

- (void) setReadOnly: (BOOL)flag;
- (BOOL) isReadOnly;

/* Renderering */

- (NSString *) layoutItemIdentifier;
- (void) setLayoutItemIdentifier: (NSString *)anIdentifier;
- (void) setLabel: (NSString *)aLabel;
- (NSString *) label;
- (void) setGroupName: (NSString *)aName;
- (NSString *) groupName;

#if 0
/* Factory Methods */

+ booleanDescription:
+ stringDescription:
+ numberDescription:
+ durationDescription:



/* Property Accessors */

- (void) setLabel: (NSString *)label;
- (NSString *) label;
- (void) setValidationRule: (ETValidationRule *)rule;
- (ETValidationRule *) validationRule;
- (void) setVisible: (BOOL)flag;
- (BOOL) isVisible;
- (void) setLayoutPriority: (int)priority;
- (int) layoutPriority;
- (void) setDocumentation: (NSString *)doc;
- (NSString *) documentation;

/* Validation */

- (void) validate: (id)object error: (NSError **)error;
- (BOOL) shouldValidate; // validateRequired

/* Rendering */

- (BOOL) renderWithRenderer: (id)renderer;

#endif

@end

// ETModelDescription?
@interface ETEntityDescription : ETModelDescription // <ETCollection>
{
	NSMutableDictionary *_propertyDescriptions;
}

+ (id) descriptionWithPropertyDescriptions: (NSArray *)descriptions type: (ETUTI *)anUTI;

/*+ (BOOL) isAbstract;

+ (NSString *) label;
+ (NSString *) layoutItemIdentifier;

- (NSArray *) allElementDescriptions; */

- (id) initWithPropertyDescriptions: (NSArray *)descriptions type: (ETUTI *)anUTI;

- (void) addPropertyDescription: (ETModelDescription *)aDescription;
- (NSArray *) propertyDescriptions;

- (NSEnumerator *) objectEnumerator;

@end

@interface ETAttributeDescription : ETModelDescription
{

}

@end

@interface ETBooleanDescription : ETAttributeDescription
{

}

@end

@interface ETNumberDescription : ETAttributeDescription
{
	double _maxValue;
	double _minValue;
}

+ (id) descriptionWithName: (NSString *)aName 
                      type: (ETUTI *)anUTI 
                     label: (NSString *)aLabel 
                  minValue: (double)aValue 
                  maxValue: (double)aValue;

- (id) initWithName: (NSString *)aName 
               type: (ETUTI *)anUTI 
              label: (NSString *)aLabel 
           minValue: (double)aMin 
           maxValue: (double)aMax;

- (double) maxValue;
- (void) setMaxValue: (double)aValue;
- (double) minValue;
- (void) setMinValue: (double)aValue;

@end


@interface ETStringDescription : ETAttributeDescription
{

}

@end
#endif