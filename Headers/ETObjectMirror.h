/**
    Copyright (C) 2009 Eric Wasylishen
 
    Date:  June 2009
    License: Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#import <EtoileFoundation/ETReflection.h>
#import <EtoileFoundation/runtime.h>

/** @group Reflection
@abstract Mirror class that represents an Objective-C object. */
@interface ETObjectMirror : NSObject <ETObjectMirror>
{
    @private
    id _object;
}
+ (id) mirrorWithObject: (id)object;
- (id) initWithObject: (id)object;
- (id) representedObject;
@end

