/**
	<abstract>Property Value Coding protocol used by CoreObject and 
	EtoileUI provides a unified API to implement access, mutation, 
	delegation and late-binding of properties.</abstract>

	Copyright (C) 2007 Quentin Mathe

	Author:  Quentin Mathe <qmathe@club-internet.fr>
	Date:  December 2007
	License:  Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>

/** @group Model and Metamodel

Property-Value Coding allows to access properties of objects in a uniform manner, 
while still supporting Key-Value Coding.
 
Key-Value Coding is similar but tends to be overriden in many subclasses. As a 
result, <code>-[NSDictionary valueForKey: @"count"]</code> doesn't return the 
count value, but attemps to look a value using 
[NSDictionary objectForKey: @"count"]. So Key-Value Coding doesn't constitute 
a mechanism versatile enough to introspect or access object properties. 
In addition, -valueForKey: doesn't accept invalid key unlike -valueForProperty:. 
This is important for presenting unrelated objects in a table UI (mapping
properties to columns) where each object has its own property set. More 
generally this matters for manipulating properties of unrelated objects using 
the same code.

ETPropertyValueCoding protocol is usually adopted by root object classes such as 
NSObject and overriden in subclasses. See NSObject(Model).
 
The basic behavior of the Property-Value-Coding is implemented in 
NSObject(ETModelAdditions), but few classes such as ETMutableObjectViewpoint and 
ETLayoutItem in EtoileUI overrides the NSObject semantic for -valueForProperty: 
and -setValue:forProperty:. */
@protocol ETPropertyValueCoding
/** Can be overriden to return YES in order to support exposing properties, in 
case -valueForProperty: and -setValue:forProperty: access another object and 
not the receiver.

This method is used by ETMutableObjectViewpoint to determine whether the 
receiver represented property can be accessed through -valueForProperty: or 
-valueForKey:.
 
By default, returns NO.
 
If -valueForProperty: and -setValue:forProperty: don't access a represented 
object, there is not need to override this method to return YES in subclasses. 
You usually never need to override this method unless you adopt 
ETPropertyViewpoint protocol. */
- (BOOL) requiresKeyValueCodingForAccessingProperties;
/** Returns the names of the properties exposed by the receiver through 
-valueForProperty: and -setValue:forProperty:, or -valueForKey: and 
-setValue:forKey: if -requiresKeyValueCodingForAccessingProperties returns YES.
 
See also -[NSObject propertyNames]. */
- (NSArray *) propertyNames;
/** Returns the value of the property.
 
If the property doesn't exist, returns nil but must not raise an exception.

The method precise semantic is under the control of the class implementing the 
protocol. For example, the property can belong to another object than the 
receiver.

See also -[NSObject valueForProperty:] and -[ETPropertyViewpoint valueForProperty:].*/
- (id) valueForProperty: (NSString *)key;
/** Sets the value of the property and returns YES if the value was successfully 
set.

If the property doesn't exist, returns NO but must not raise an exception.

The method precise semantic is under the control of the class implementing the
protocol.
 
See also -[NSObject setValue:forProperty:] and 
-[ETPropertyViewpoint setValue:forProperty:]. */
- (BOOL) setValue: (id)value forProperty: (NSString *)key;
@end


/** @group Model and Metamodel */
@interface NSDictionary (ETPropertyValueCoding)
- (NSArray *) propertyNames;
- (id) valueForProperty: (NSString *)key;
- (BOOL) setValue: (id)value forProperty: (NSString *)key;
@end

/** @group Model and Metamodel */
@interface NSMutableDictionary (ETMutablePropertyValueCoding)
- (BOOL) setValue: (id)value forProperty: (NSString *)key;
@end
