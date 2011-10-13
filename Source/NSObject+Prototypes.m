#import "NSObject+Prototypes.h"
#import <objc/runtime.h>
// Prototypes are only supported with the GNUstep runtime currently.
#ifdef __GNUSTEP_RUNTIME__
#import <objc/blocks_runtime.h>
#import <objc/capabilities.h>
#ifdef OBJC_CAP_PROTOTYPES
#import <Foundation/Foundation.h>

@implementation NSObject (Prototypes)
+ (BOOL)addInstanceMethod: (SEL)aSelector fromBlock: (id)aBlock
{
	IMP imp = imp_implementationWithBlock(aBlock);
	if (0 == imp) { return NO; }
	char *encoding = block_copyIMPTypeEncoding_np(aBlock);
	class_replaceMethod(self, aSelector, imp, encoding);
	free(encoding);
	return YES;
}
+ (BOOL)addClassMethod: (SEL)aSelector fromBlock: (id)aBlock
{
	return [object_getClass(self) addInstanceMethod: aSelector fromBlock: aBlock];
}
- (BOOL)addMethod: (SEL)aSelector fromBlock: (id)aBlock
{
	IMP imp = imp_implementationWithBlock(aBlock);
	if (0 == imp) { return NO; }
	char *encoding = block_copyIMPTypeEncoding_np(aBlock);
	if (NULL == encoding) { return NO; }
	object_replaceMethod_np(self, aSelector, imp, encoding);
	free(encoding);
	return YES;
}
- (void)setMethod: (IMP)aMethod forSelector: (SEL)aSelector
{
	object_replaceMethod_np(self, aSelector, aMethod, sel_getType_np(aSelector));
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
	if ([aValue isKindOfClass: blockClass] )
	{
		IMP imp = imp_implementationWithBlock(aValue);
		if (0 != imp)
		{
			char *encoding = block_copyIMPTypeEncoding_np(aValue);
			if (NULL != encoding)
			{
				object_replaceMethod_np(self, sel, imp, encoding);
				free(encoding);
			}
		}
	}
}
- (id) slotValueForKey:(NSString *)aKey
{
	return objc_getAssociatedObject(self, (void*)sel_getName(NSSelectorFromString(aKey)));
}
@end
#endif // OBJC_CAP_PROTOTYPES
#endif // __GNUSTEP_RUNTIME__
