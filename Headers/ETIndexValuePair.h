/**
    Copyright (C) 2013 Quentin Mathe

    Date:  June 2013
    License: Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#import <EtoileFoundation/ETViewpoint.h>

@protocol ETCollection;

/** @group Viewpoints
@abstract An index/value association.

ETIndexValuePair doesn't support subclassing.

Note: this class is deprecated and will be removed in a next release. */
@interface ETIndexValuePair : NSObject <ETViewpoint>
{
    @private
    id _representedObject;
    NSUInteger _index;
    id _value;
}

/** @taskunit Initialization */

- (id) initWithIndex: (NSUInteger)index
               value: (id)aValue
   representedObject: (id <ETCollection>)object;

/** @taskunit Type Querying */

- (BOOL) isIndexValuePair;

/** @taskunit Observing Changes From Other Objects */

- (NSSet *) observableKeyPaths;

/** @taskunit Controlling the Represented Element */

@property (nonatomic, retain) id representedObject;
@property (nonatomic, assign) NSUInteger index;

/** @taskunit Accessing the Represented Element */

- (id) value;
- (void) setValue: (id)objectValue;

@end

/** @group Viewpoints
@abstract ETIndexValuePair-related extensions to NSObject. */
@interface NSObject (ETIndexValuePair)
/** Returns whether the receiver is an index-value pair.
 
By default, returns NO.
 
See also -[ETIndexValuePair isIndexValuePair]. */
- (BOOL) isIndexValuePair;
@end
