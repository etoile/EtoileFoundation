/**
    Copyright (C) 2009 Eric Wasylishen
 
    Date:  June 2009
    License: Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#import <EtoileFoundation/ETReflection.h>
#import <EtoileFoundation/runtime.h>

/** @group Reflection
@abstract Mirror class that represents an Objective-C class. */
@interface ETClassMirror : NSObject <ETClassMirror>
{
    @private
    Class _class;
}
+ (id) mirrorWithClass: (Class)class;
- (id) initWithClass: (Class)class;
- (Class) representedClass;

@end

