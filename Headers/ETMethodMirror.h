/*
	Mirror-based reflection API for Etoile.
 
	Copyright (C) 2009 Eric Wasylishen
 
	Author:  Eric Wasylishen <ewasylishen@gmail.com>
	Date:  June 2009
	License: Modified BSD (see COPYING)
 */

#import <EtoileFoundation/EtoileFoundation.h>
#import "ETReflection.h"
#import "ETInstanceVariableMirror.h"
#ifndef GNUSTEP
#import <objc/runtime.h>
#else
#import <ObjectiveC2/runtime.h>
#endif

@interface ETMethodMirror : NSObject <ETMethodMirror>
{
	Method _method;
	BOOL _isClassMethod;
}
+ (id) mirrorWithMethod: (Method)method isClassMethod: (BOOL)isClassMethod;
- (id) initWithMethod: (Method)method isClassMethod: (BOOL)isClassMethod;
@end

/**
 * Used to mirror a method when we only know its name
 */
@interface ETMethodDescriptionMirror : NSObject <ETMethodMirror>
{
	NSString *_name;
	BOOL _isClassMethod;
}
+ (id) mirrorWithMethodName: (const char *)name isClassMethod: (BOOL)isClassMethod;
- (id) initWithMethodName: (const char *)name isClassMethod: (BOOL)isClassMethod;
@end

