/**
	Copyright (C) 2013 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  May 2013
	License: Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <EtoileFoundation/ETViewpoint.h>

/** @group Viewpoints
@abstract A proxy giving access to a model property as a mutable object.
 
ETMutableObjectViewpoint turns an attribute or to-one relationship property 
belonging to a represented object, into a mutable object proxy that updates the 
model property with a new immutable object in reaction to -setValue:forProperty:.
 
ETMutableObjectViewpoint doesn't work as a mutable collection proxy for a 
to-many relationship property, you must use ETCollectionViewpoint instead.
 
Using a mutable object as ETMutableObjectViewpoint value doesn't bring a lot of 
benefits, but is well supported and works transparently.

For supporting editing a mutable object class, ETMutableObjectViewpoint must be 
subclassed. For example, for editing NSSortDescriptor, you must implement a 
new subclass such as ETMutableSortDescriptorViewpoint (this one is provided by 
EtoileUI though).
 
This viewpoint uses Key-Value-Observing to detect any property changes on the 
represented object. */
@interface ETMutableObjectViewpoint : NSObject <ETPropertyViewpoint>
{
	@private
	id _representedObject;
	id _name;
	BOOL _usesKeyValueCodingForAccessingValueProperties;
	@protected
	BOOL _isSettingValue;
}

/** @taskunit Initialization */

+ (id) viewpointWithName: (NSString *)key representedObject: (id)object;

- (id) initWithName: (NSString *)key representedObject: (id)object;

/** @taskunit Represented Property */

/** The property name of the original object value in the represented object.
 
The object value bound to the property can be a collection. For customizing 
the collection interaction through the viewpoint, see ETCollectionViewpoint. */
@property (nonatomic, readonly) NSString *name;

/** @taskunit Controlling Represented Object Access */

/** The object to which the property belongs to. */
@property (nonatomic, retain) id representedObject;
@property (nonatomic, assign) BOOL usesKeyValueCodingForAccessingValueProperties;

/** @taskunit Reading and Writing the value */

/** The object value of the represented property. */
@property (nonatomic, retain) id value;

/** @taskunit Property Value Coding */

/** Returns a value bound to a property of the object -value.
 
 This method accesses properties of the represented property. */
- (id) valueForProperty: (NSString *)key;
/** Returns a value bound to a property of the object -value.
 
 This method accesses properties of the represented property. */
- (BOOL) setValue: (id)value forProperty: (NSString *)key;

/** @taskunit Subclassing */

@property (nonatomic, readonly) NSString *observedKeyPath;
- (void) setRepresentedObject: (id)object
           oldObservedKeyPath: (NSString *)oldObservedKeyPath
           newObservedKeyPath: (NSString *)newObservedKeyPath;
- (void) startObserveRepresentedObject: (id)anObject forKeyPath: (NSString *)aKeyPath;
- (void) stopObserveRepresentedObject: (id)anObject forKeyPath: (NSString *)aKeyPath;

@end
