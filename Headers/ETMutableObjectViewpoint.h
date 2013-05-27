/**
	Copyright (C) 2013 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  May 2013
	License: Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <EtoileFoundation/ETCollection.h>

/** @group Viewpoints
 
Immutable object class that wants to support editing or mutation through a 
ETMutableObjectViewpoint must implement this protocol. */
@protocol ETViewpointMutation
/** Returns the ETMutableObjectViewpoint subclass used to mutate the receiver 
instances.

Must not return Nil. */
+ (Class) mutableViewpointClass;
@end

/** @group Viewpoints
@abstract A proxy giving access to a model property as a mutable object.
 
ETMutableObjectViewpoint turns an attribute or to-one relationship property 
belonging to a represented object, into a mutable object proxy that updates the 
model property with a new immutable object in reaction to -setValue:forProperty:.
 
ETMutableObjectViewpoint doesn't work as a mutable collection proxy for a 
to-many relationship property, you must use ETCollectionViewpoint instead.
 
Using a mutable object as ETMutableObjectViewpoint represented object doesn't 
bring a lot of benefits, but is well supported and works transparently. 

For supporting editing a mutable object class, ETMutableObjectViewpoint must be 
subclassed. For example, for editing NSSortDescriptor, you must implement a 
new subclass such as ETMutableSortDescriptorViewpoint (this one is provided by 
EtoileUI though).
 
This viewpoint uses Key-Value-Observing to detect any property changes on the 
represented object. */
@interface ETMutableObjectViewpoint : NSObject <NSCopying>
{
	@private
	id _representedObject;
	id _name;
}

/** @taskunit Initialization */

+ (id) viewpointWithName: (NSString *)key representedObject: (id)object;

- (id) initWithName: (NSString *)key representedObject: (id)object;

/** @taskunit Represented Property */

/** The property name of the original collection in the represented object. */
@property (nonatomic, readonly) NSString *name;

/** @taskunit Controlling Represented Object Access */

@property (nonatomic, retain) id representedObject;

/** @taskunit Reading and Writing the value */

- (id) value;
- (void) setValue: (id)objectValue;

/** @taskunit Property Value Coding */

@property (nonatomic, readonly) NSArray *propertyNames;

- (id) valueForProperty: (NSString *)key;
- (BOOL) setValue: (id)value forProperty: (NSString *)key;

@end
