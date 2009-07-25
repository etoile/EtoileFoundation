/** <title>ETInstanceVariableMirror</title>

	<abstract>Mirror class that represents an Objective-C instance 
	variable.</abstract>

	Copyright (C) 2009 Eric Wasylishen
 
	Author:  Eric Wasylishen <ewasylishen@gmail.com>
	Date:  June 2009
	License: Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#import <EtoileFoundation/ETReflection.h>
#ifndef GNUSTEP
#import <objc/runtime.h>
#else
#import <ObjectiveC2/runtime.h>
#endif


@interface ETInstanceVariableMirror : NSObject <ETInstanceVariableMirror>
{
	Ivar _ivar;
}
- (id) initWithIvar: (Ivar)ivar;
+ (id) mirrorWithIvar: (Ivar)ivar;
@end
