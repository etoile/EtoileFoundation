#import "ETPrototype.h"
#include <objc/objc-api.h>

typedef struct { @defs(ETPrototype) }* ETPrototype_t;
@implementation ETPrototype
- (id) init
{
	if(nil == (self = [super init]))
	{
		return nil;
	}
	//Note: This is a hack; selectors with the same name return the same
	//C string from the runtime, so we can do a pointer comparison on them
	dtable = NSCreateMapTable(
			NSNonOwnedPointerMapKeyCallBacks,
			NSNonOwnedPointerMapValueCallBacks,
			5);
	return self;
}
/**
 * Set this class as having a custom method lookup mechanism.
 */
+ (void) initialize
{
	CLS_SETOBJECTMESSAGEDISPATCH((Class)self);
	[super initialize];
}
/**
 * Message lookup function.  Looks for method in the dtable ivar.
 */
+ (IMP) messageLookupForObject:(id)anObject selector:(SEL)aSelector
{
	ETPrototype_t ivars = (ETPrototype_t) anObject;
	/* Avoid map lookup if there are no methods added yet. */
	if(ivars->isPrototype)
	{
		return NSMapGet(ivars->dtable, sel_get_name(aSelector));
	}
	return NULL;
}
/**
 * Add a new method.
 */
- (void) setMethod:(IMP)aMethod forSelector:(SEL)aSelector
{
	isPrototype = YES;
	NSMapInsert(dtable, sel_get_name(aSelector), (void*)aMethod);
}
- (id)copyWithZone:(NSZone *)zone
{
	ETPrototype * copy = (ETPrototype*) NSCopyObject(self, 0, zone);
	((ETPrototype_t)copy)->dtable = NSCopyMapTableWithZone(dtable, zone);
	((ETPrototype_t)copy)->otherIvars = NSCopyMapTableWithZone(otherIvars, zone);
	return copy;
}
- (id) clone
{
	return [self copyWithZone:NULL];
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
	if(otherIvars == NULL)
	{
		otherIvars = NSCreateMapTable(
				NSObjectMapKeyCallBacks,
				NSObjectMapValueCallBacks,
				5);
	}
	NSMapInsert(otherIvars, key, value);
}
- (id)valueForUndefinedKey:(NSString *)key
{
	if(otherIvars == NULL)
	{
		return NULL;
	}
	return NSMapGet(otherIvars, key);
}
- (void) dealloc
{
	NSFreeMapTable(dtable);
	NSFreeMapTable(otherIvars);
	[super dealloc];
}
@end
