#import "NSObject+Prototypes.h"
#import <objc/runtime.h>
// Prototypes are only supported with the GNUstep runtime currently.
#ifdef __GNUSTEP_RUNTIME__
#import <objc/blocks_runtime.h>
#import <objc/capabilities.h>
#ifdef OBJC_CAP_PROTOTYPES
#import <Foundation/Foundation.h>


static id blockTrampoline(id self, SEL _cmd, ...)
{
	// FIXME: It's a lot of effort, but ideally we should generate a proper
	// static trampoline for this with either libffi or some magic assembly
	// code (doing that on x86, ARM, and x86-64 would probably be enough).
	id(^block)(id, ...) = objc_getAssociatedObject(self, (void*)sel_getName(_cmd));
	if (NULL == block) { return nil; }
	va_list ap;
	va_start(ap, _cmd);
	id arg1 = va_arg(ap, id);
	id arg2 = va_arg(ap, id);
	id arg3 = va_arg(ap, id);
	id arg4 = va_arg(ap, id);
	va_end(ap);
	return block(self, _cmd, arg1, arg2, arg3, arg4);
}

@implementation NSObject (Prototypes)
- (void)setMethod: (IMP)aMethod forSelector: (SEL)aSelector
{
	object_addMethod_np(self, aSelector, aMethod, sel_getType_np(aSelector));
}
- (id) clone
{
	return object_clone_np(self);
}
- (BOOL) isPrototype
{
	return object_getPrototype_np(self) != nil;
}
- (id) prototype
{
	return object_getPrototype_np(self);
}
- (void)setValue: (id)aValue forUndefinedKey: (NSString*)aKey
{
	SEL sel = NSSelectorFromString(aKey);
	objc_setAssociatedObject(self, 
	                         (void*)sel_getName(sel),
	                         aValue,
	                         OBJC_ASSOCIATION_RETAIN);
	static id blockClass;
	if (Nil == blockClass)
	{
		blockClass = objc_lookUpClass("_NSBlock");
	}
	if ([aValue isKindOfClass: blockClass])
	{
		object_addMethod_np(self, sel, blockTrampoline, block_getType_np(aValue));
	}
}
- (id) slotValueForKey:(NSString *)aKey
{
	return objc_getAssociatedObject(self, (void*)sel_getName(NSSelectorFromString(aKey)));
}
@end
#endif // OBJC_CAP_PROTOTYPES
#endif // __GNUSTEP_RUNTIME__
