/**
    Copyright (C) 2009 Eric Wasylishen

    Date:  July 2009
    License:  Modified BSD (see COPYING)
 */

#import <EtoileFoundation/ETPropertyValueCoding.h>

@class ETEntityDescription;

/** @group Metamodel
@abstract Model object under the metamodel control.

WARNING: This class is under development and must be ignored.

Very simple implementation of an adaptive model object that is causally
connected to its description. This means that changes to the entity description 
immediately take effect in the instance of ETAdaptiveModelObject.

Causal connection is ensured through the implementation of -valueForProperty: 
and -setValue:forProperty:. */
@interface ETAdaptiveModelObject : NSObject
{
    @private
    NSMutableDictionary *_properties;
    ETEntityDescription *_description;
}

/** @taskunit Property Value Coding */

/** Returns the property value if the property is declared in the metamodel 
(aka entity description). */
- (id) valueForProperty: (NSString *)key;
/** Sets the property value and returns YES when the property is declared in 
the metamodel and it allows the value to be set. In all other cases, does 
nothing and returns NO. */ 
- (BOOL) setValue: (id)value forProperty: (NSString *)key;

@end
