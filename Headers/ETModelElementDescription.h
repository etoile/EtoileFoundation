/** <title>ETModelElementDescription</title>

	<abstract>A model description framework inspired by FAME 
	(http://scg.unibe.ch/wiki/projects/fame)</abstract>
 
	Copyright (C) 2009 Eric Wasylishen

	Author:  Eric Wasylishen <ewasylishen@gmail.com>
	Date:  July 2009
	License:  Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>

@class ETEntityDescription, ETUTI;

/** Asbtract base class for ETEntityDescription and ETPropertyDescription. */
@interface ETModelElementDescription : NSObject
{
	NSString *_name;
	ETUTI *_UTI;
	NSString *_itemIdentifier;
}

/** <override-subclass />
Self-description (aka meta-metamodel).

Must return the same instance all the time. */
+ (ETEntityDescription *) entityDescription;

/** Returns an autoreleased entity or property description.

See also -initWithName:. */
+ (id) descriptionWithName: (NSString *)name;
/** Initializes and returns an entity or property description.

You must only invoke this method on subclasses, otherwise nil is returned.

You should pass the property name in argument for a property description. And   
the class name for an entity description, the only exception is when the entity 
description applies to a prototype rather than a class.

Raises an NSInvalidArgumentException when the name is nil or already in use. */
- (id) initWithName: (NSString *)name;

/* Property getters/setters */

/** Returns the name of the entity or property. */
- (NSString *) name;
/** Sets the name of the entity or property. */
- (void) setName: (NSString *)name;
/** Returns the UTI type of the entity or the property.

For a property description, this is the type of the attribute or destination 
entity. */
- (ETUTI *) type;
/** Sets the UTI type of the entity or property. */
- (void) setType: (ETUTI *)UTI;

/* UI */

/** Returns a hint that precises how the receiver should be rendered. 
e.g. at UI level.

By default, returns nil.

See also -setIdemIdentifier:. */
- (NSString *) itemIdentifier;
/** Sets a hint that precises how the receiver should be rendered.

You can use this hint to identify which object to ouput, every time a new 
representation has to be generated based on the description.

ETModelDescriptionRenderer in EtoileUI uses it to look up a template item that  
will represent the property at the UI level. */
- (void) setItemIdentifier: (NSString *)anIdentifier;

@end
