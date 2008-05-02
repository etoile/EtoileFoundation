#include <objc/objc-api.h>
//Check if a patched GNU libobjc is installed.
#ifdef CLS_SETOBJECTMESSAGEDISPATCH
#import "ETPrototype.h"

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
		IMP method = (IMP)NSMapGet(ivars->dtable, sel_get_name(aSelector));
		if(method == NULL && (ivars->prototype) != NULL)
		{
			return [self messageLookupForObject:(ivars->prototype) selector:aSelector];
		}
		return method;
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
- (id) cloneWithZone: (NSZone *)zone
{
	id obj = [[[self class] allocWithZone: zone] init];
	[obj setPrototype: self];
	return obj;
}

- (id) prototype
{
	return prototype;
}

- (void) setPrototype: (id)proto
{
	ASSIGN(prototype, proto);
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
- (id)valueForUndefinedKey:(NSString *)aKey
{
	if(otherIvars == NULL)
	{
		return NULL;
	}
	id val = NSMapGet(otherIvars, aKey);
	if(val == NULL && prototype != NULL)
	{
		return [prototype valueForUndefinedKey:aKey];
	}
	return NULL;
}
- (void) dealloc
{
	NSFreeMapTable(dtable);
	NSFreeMapTable(otherIvars);
	DESTROY(prototype);
	[super dealloc];
}
@end
#else
#warning Your Objective-C runtime is not compatible with prototypes.
#endif
