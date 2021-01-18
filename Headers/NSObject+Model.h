/**
    Copyright (C) 2007 Quentin Mathe
 
    Date:  December 2007
    License:  Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#import <EtoileFoundation/ETPropertyValueCoding.h>

@class ETEntityDescription;
@protocol ETKeyedCollection;

/** @group Model Additions
@abstract NSObject additions providing basic management of model objects. */
@interface NSObject (ETModel)

/** @taskunit Providing the Metamodel */

+ (ETEntityDescription *) newEntityDescription;
+ (ETEntityDescription *) newBasicEntityDescription;

/** @taskunit Common Representations */

- (id) objectValue;
@property (nonatomic, readonly) NSString *stringValue;

- (BOOL) isCommonObjectValue;
- (BOOL) isString;
- (BOOL) isNumber;

/** @taskunit Basic Properties */

- (NSString *) displayName;
/* NSObject+EtoileUI offers also the following basic property
  - (NSImage *) icon; */

- (NSString *) primitiveDescription;
- (NSString *) descriptionWithOptions: (NSMutableDictionary *)options;

/** @taskunit KVO Syntactic Sugar (Unstable API) */

- (NSSet *) observableKeyPaths;

/** @taskunit Collection and Mutability */

+ (Class) mutableClass;

- (BOOL) isMutable;
- (BOOL) isCollection;
- (BOOL) isMutableCollection;
- (BOOL) isPrimitiveCollection;
- (BOOL) isGroup;

- (id) insertionKeyForCollection: (id <ETKeyedCollection>)aCollection;

@end

/** An array of key paths to indicate the values -descriptionWithOptions: 
should report.

Default value is nil. */
extern NSString * const kETDescriptionOptionValuesForKeyPaths;
/** Key-Value-Coding key to indicate a value to be treated as a recursive  
collection. Each element will be sent -descriptionWithOptions: to report every 
descendant description.

Default value is nil.  */
extern NSString * const kETDescriptionOptionTraversalKey;
/** String used as the base indentation for properties in -descriptionWithOptions:.

For an empty string, all properties are output on the same line.<br />
For other indentation e.g. a tab, each property is output on a distinct line.

Default value is an empty string. */
extern NSString * const kETDescriptionOptionPropertyIndent;
/** Selector string to indicate which method should be called to print a short 
object description.

If the receiver doesn't respond to this selector, then -description is used.

Default value is 'description'. */
extern NSString * const kETDescriptionOptionShortDescriptionSelector;
/** Integer number object to indicate the depth at which -descriptionWithOptions: 
should stop to traverse collections with kETDescriptionOptionTraversalKey.

Default value is 20. */
extern NSString * const kETDescriptionOptionMaxDepth;

/** Posts this notification to let other objects know about collection mutation   
in your model object. 

For example, EtoileUI uses this notification to reload the UI transparently. 
See -[ETLayoutItemGroup setRepresentedObject:]. */
extern NSString * const ETCollectionDidUpdateNotification;

/* Basic Common Value Classes */

/** @group Model Additions */
@interface NSString (ETModel)
- (BOOL) isCommonObjectValue;
@end

/** @group Model Additions */
@interface NSNumber (ETModel)
- (BOOL) isCommonObjectValue;
@end

/** @group Model Additions */
@interface NSDate (ETModel)
- (BOOL) isCommonObjectValue;
@end
