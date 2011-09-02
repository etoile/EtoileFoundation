#import <Foundation/NSObject.h>
#ifdef GNUSTEP
#import "objc/blocks_runtime.h"
#define BLOCK_CLASS_NAME "_NSBlock"
#else
#import <objc/runtime.h>
#define BLOCK_CLASS_NAME "NSBlock"
#endif

// Define __has_feature() for compilers that don't support it.
#ifndef __has_feature
#define __has_feature(x) 0
#endif

@interface ETBlock
{
	id isa;
}
@end

@implementation ETBlock
+ (void)load
{
	unsigned int methodCount;
	Method *methods = 
		class_copyMethodList(objc_getClass("ETBlock"), &methodCount);
	id blockClass = objc_lookUpClass(BLOCK_CLASS_NAME);
	for (Method *m = methods ; NULL!=*m ; m++)
	{
		class_addMethod(blockClass, method_getName(*m),
			method_getImplementation(*m), method_getTypeEncoding(*m));
	}
}
- (BOOL)isBlock
{
	return YES;
}

#if __has_feature(blocks)
- (id) value
{
	return ((id(^)(void))self)();
}
- (id) value: (id)anObject
{
	return ((id(^)(id))self)(anObject);
}
- (id) value: (id)anObject value: (id)obj2
{
	return ((id(^)(id,id))self)(anObject, obj2);
}
- (id) value: (id)anObject value: (id)obj2 value: (id)obj3
{
	return ((id(^)(id,id,id))self)(anObject, obj2, obj3);
}
#else
#warning Compiling without blocks enabled is not recommended.
#endif
@end

