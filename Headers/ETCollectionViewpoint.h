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
@abstract A proxy giving access to a model property as a mutable collection.
 
ETCollectionViewpoint turns a collection property belonging to a represented 
object into a immutable or mutable collection proxy that implements the 
collection protocols.
 
Using it as an immutable collection proxy doesn't bring a lot of benefits. 
However ETCollectionViewpoint can use Key-Value-Coding accessors to support 
mutating the collection without implementing ETCollection and ETCollectionMutation 
on the represented object (for the property that holds the collection).<br />
A model object usually implements collection protocols providing access to its
dominant/main collection aspect, but the represent object doesn't support 
these protocols to access other collections exposed as properties. 
ETCollectionViewpoint exposes these other collections as the main collection is 
usually exposed. */
@interface ETCollectionViewpoint : NSObject <ETKeyedCollection, ETCollectionMutation, NSCopying>
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
/** Posts an ETSourceDidUpdateNotification which can be intercepted by all
the objects that observes the represented object. */
- (void) didUpdate;

/** @taskunit Property Value Coding */

@property (nonatomic, readonly) NSArray *propertyNames;

- (id) valueForProperty: (NSString *)key;
- (BOOL) setValue: (id)value forProperty: (NSString *)key;

@end

