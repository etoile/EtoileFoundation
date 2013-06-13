/**
	Copyright (C) 2013 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  May 2013
	License: Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#import <EtoileFoundation/ETCollection.h>
#import <EtoileFoundation/ETMutableObjectViewpoint.h>

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
@interface ETCollectionViewpoint : ETMutableObjectViewpoint <ETKeyedCollection, ETCollectionMutation>
{

}

- (BOOL) isIndexValuePairCollection;

/** @taskunit Controlling Represented Object Access */

/** Returns the represented property collection.
 
This is the primitive method to access the underlying collection. 
ETCollectionViewpoint never accesses the collection in another way. You must
do the same in any ETCollectionViewpoint subclasses or categories.

Can be overriden, but -setContent: must be overriden too. */
- (id <ETCollection>) content;
/** Sets the represented property collection.
 
This is is the primitive method to access the underlying collection.
ETCollectionViewpoint never accesses the collection in another way. You must
do the same in any ETCollectionViewpoint subclasses or categories.
 
Can be overriden, but -content must be overriden too. */
- (void) setContent: (id <ETCollection>)aContent;
/** Posts an ETSourceDidUpdateNotification which can be intercepted by all
the objects that observes the represented object. */
- (void) didUpdate;

@end

