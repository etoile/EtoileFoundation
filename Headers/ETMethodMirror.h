/**
    Copyright (C) 2009 Eric Wasylishen
 
    Date:  June 2009
    License: Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#import <EtoileFoundation/ETReflection.h>
#import <EtoileFoundation/runtime.h>

/** @group Reflection 
@abstract Mirror class that represents an Objective-C method.*/
@interface ETMethodMirror : NSObject <ETMethodMirror>
{
    @private
    Method _method;
    BOOL _isClassMethod;
}
+ (id) mirrorWithMethod: (Method)method isClassMethod: (BOOL)isClassMethod;
- (id) initWithMethod: (Method)method isClassMethod: (BOOL)isClassMethod;
@end

/**
 * @group Reflection 
 * @abstract Mirror class that represents an Objective-C method, used to 
 * mirror a method when we only know its name.
 */
@interface ETMethodDescriptionMirror : NSObject <ETMethodMirror>
{
    @private
    NSString *_name;
    BOOL _isClassMethod;
}
+ (id) mirrorWithMethodName: (const char *)name isClassMethod: (BOOL)isClassMethod;
- (id) initWithMethodName: (const char *)name isClassMethod: (BOOL)isClassMethod;
@end

