/**
	<abstract>A viewpoint protocol to represent an object property.</abstract>

	Copyright (C) 2007 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  December 2007
	License:  Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>

/** @group Viewpoints
 
A property viewpoint is an adaptor-like object that represents an object
property and handles reading and writing the property value through -value and
-setValue. */
@protocol ETPropertyViewpoint // FIXME: <NSCopying>
/** Returns a new autoreleased property viewpoint that represents the property
identified by the given name in object. */
+ (id) viewpointWithName: (NSString *)key representedObject: (id)object;
/** Returns the object to which the property belongs to. */
- (id) representedObject;
/** Sets the object to which the property belongs to. */
- (void) setRepresentedObject: (id)object;
/** Returns the name used to declared property in the represented object. */
- (NSString *) name;
/** Returns the object value of the represented property. */
- (id) value;
/** Sets the object value of the represented property. */
- (void) setValue: (id)objectValue;
/** Returns the property names exposed through by the viewpoint for -value 
(the property object value). */
- (NSArray *) propertyNames;
/** Returns a value bound to a property of the object -value.

This method accesses properties of the represented property. */
- (id) valueForProperty: (NSString *)key;
/** Sets the value bound to a property of the object -value.
 
This method accesses properties of the represented property. */
- (BOOL) setValue: (id)value forProperty: (NSString *)key;
@end
