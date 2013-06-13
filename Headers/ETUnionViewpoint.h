/**
	Copyright (C) 2013 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  May 2013
	License: Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#import <EtoileFoundation/ETCollectionViewpoint.h>

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
@interface ETUnionViewpoint : ETCollectionViewpoint
{
	NSString *_contentKeyPath;
}

+ (id) mixedValueMarker;

@property (nonatomic, retain) NSString *contentKeyPath;
@property (nonatomic, readonly) BOOL isCollectionUnion;

@end

