#include <objc/objc-api.h>
#import "NSObject+Prototypes.h"
#import <Foundation/Foundation.h>

// Private runtime function for setting up a class dtable
void __objc_update_dispatch_table_for_class(Class);

// Macros for setting the hidden class flag.
// TODO: These should be pushed into the runtime.
#define _CLS_HIDDEN 0x20L
#define CLS_ISHIDDEN(cls) __CLS_ISINFO(cls, _CLS_HIDDEN)
#define CLS_SETHIDDEN(cls) __CLS_SETINFO(cls, _CLS_HIDDEN)

/**
 * The slots dictionary can not contain nil.  This is object used to implement
 * whiteout, so a nil inserted by one object will prevent it from accidentally
 * seeing its prototype's value.
 */
static id NULL_OBJECT_PLACEHOLDER;

/** 
 * A hidden class is a class with some other ivars for implementing properties.
 */
typedef struct objc_hidden_class
{
	/** The real class - allows casting a HiddenClass to a Class. */
	struct objc_class class;
	struct objc_class metaClass;
	/** Reference count for this hidden class. */
	int refCount;
	/** Slots on this hidden class. */
	NSMutableDictionary *slots;
	/** Secondary lookup system. */
	NSMapTable *blockMethods;
	/** The prototype object. */
	id owner;
}* HiddenClass;

/** The number of methods installed by default on any hidden class. */
#define HIDDEN_CLASS_METHODS 3
/**
 * The method list to be linked to in all classes.  Can be cast to a MethodList.
 */ 
static struct 
{
	struct objc_method_list*  method_next;
	int method_count;
	Method method_list[HIDDEN_CLASS_METHODS];
} defaultMethods;
static MethodList defaultClassMethods;
/**
 * This function is equivalent to -release, but for hidden classes.
 */
static void releaseHiddenClass(HiddenClass cls)
{
	// Decrement the reference count and free if it hits 0.
	// Note: __sync_fetch_and_sub returns the old value of the refcount.
	if (1 == __sync_fetch_and_sub(&cls->refCount, 1))
	{
		[cls->slots release];
		NSFreeMapTable(cls->blockMethods);
		// Free method lists
		MethodList_t methods = cls->class.methods;
		while (methods != (MethodList_t)&defaultMethods)
		{
			MethodList_t next = methods->method_next;
			free(methods);
			methods = next;
		}
		// Destroy the dtables.
		sarray_free(cls->class.class_pointer->dtable);
		sarray_free(cls->class.dtable);
		// Free metaclass
		free(cls->class.class_pointer);
		// Free class
		free(cls);
	}
}

static id blockTrampoline(id self, SEL _cmd, ...);

/**
 * Implementation of setValue:forUndefinedKey: for hidden classes.
 */
static void hiddenClassSetValueForUndefinedKey(
		id self, SEL _cmd, id value, NSString *key)
{
	value = [[value retain] autorelease];
	if ([value isKindOfClass:NSClassFromString(@"BlockClosure")])
	{
		SEL sel = sel_get_uid([key UTF8String]);
		[self setMethod:blockTrampoline forSelector:sel];
		NSMapInsert(
				((HiddenClass)self->class_pointer)->blockMethods,
			   	sel_get_name(sel),
				value);
	}
	if (value == nil)
	{
		value = NULL_OBJECT_PLACEHOLDER;
	}
	[(((HiddenClass)self->class_pointer)->slots) setObject: value forKey: key];
}

/**
 * Implementation of valueForUndefinedKey: for hidden classes.
 */
static id hiddenClassValueForUndefinedKey(id self, SEL _cmd, NSString *aKey)
{
	id value = nil;
	for (Class cls=self->class_pointer ; CLS_ISHIDDEN(cls) ;
	     cls=cls->super_class)
	{
		if (nil != (value = [(((HiddenClass)cls)->slots) objectForKey:aKey]))
		{
			break;
		}
	}
	if (value == NULL_OBJECT_PLACEHOLDER)
	{
		value = nil;
	}
	return value;
}

/**
 * Implementation of allocWithZone: for hidde classes.
 */
static id hiddenClassAllocWithZone(id self, SEL _cmd, NSZone *aZone)
{

	Class class = self->class_pointer;
	Super s = {self, class};
	// Walk up the class hierarchy until we find one that isn't hidden
	while (CLS_ISHIDDEN(s.class))
	{
		// If this is a metaclass (and it should be) then get the real hidden
		// class
		HiddenClass hcls = (HiddenClass)s.class;
		if (CLS_ISMETA(s.class))
		{
			hcls = (HiddenClass)
				((char*)hcls-
					((char*)(&((HiddenClass)(nil))->metaClass)));
		}
		// Increment the reference count of all of the hidden classes.
		__sync_fetch_and_add(&hcls->refCount, 1);
		s.class = s.class->super_class;
	}
	// Send [super allocWithZone:] to the first non-hidden class
	return objc_msg_lookup_super(&s, _cmd)(self, _cmd, aZone);
}
/**
 * Implementation of dealloc for hidden classes.  Decrements the reference
 * count for the hidden class.
 */
static void hiddenClassDealloc(id self, SEL _cmd)
{
	Class class = self->class_pointer;
	Super s = {self, class};
	// Walk up the class hierarchy until we find one that isn't hidden
	while (CLS_ISHIDDEN(s.class))
	{
		s.class = s.class->super_class;
	}
	// Send [super dealloc] to the first non-hidden class
	objc_msg_lookup_super(&s, _cmd)(self, _cmd);
	// Self is invalid after this point.
	self = nil;
	// Decrement the reference count of every hidden class in the chain
	for (Class cls = class ; cls != Nil ; cls = class)
	{
		class = cls->super_class;
		if (CLS_ISHIDDEN(cls))
		{
			HiddenClass hcls = (HiddenClass)cls;
			releaseHiddenClass(hcls);
		}
	}
}
/**
 * Runtime library function for updating dispatch table.
 */
extern struct sarray *__objc_uninstalled_dtable;
/**
 * Allocate a hidden class inheriting from an existing class.
 */
struct objc_hidden_class *hiddenClassFromClass(Class cls)
{
	HiddenClass hcls = calloc(1, sizeof(struct objc_hidden_class));
	hcls->refCount = 1;
	Class newClass = &hcls->class;
	// Set up the empty metaclass
	Class metaClass = &hcls->metaClass;
	metaClass->super_class = cls->class_pointer;
	metaClass->info = 2;
	metaClass->class_pointer = newClass;
	CLS_SETHIDDEN(metaClass);
	CLS_SETINITIALIZED(metaClass);
	// Set the metaclass dtable
	metaClass->methods = (MethodList_t)&defaultClassMethods;
	metaClass->dtable = __objc_uninstalled_dtable;
	__objc_update_dispatch_table_for_class(metaClass);
	newClass->class_pointer = metaClass;
	// Note: This name conflict doesn't matter because we are not registering
	// the class with the runtime.  Since it is hidden, it can not be accessed
	// with NSClassFromString or similar.
	newClass->name = "PrototypeHiddenClass";
	newClass->methods = (MethodList_t)&defaultMethods;
	// Set the hidden class flag
	newClass->info = 1;
	CLS_SETHIDDEN(newClass);
	CLS_SETINITIALIZED(newClass);
	newClass->super_class = cls;
	newClass->dtable = __objc_uninstalled_dtable;
	// set up the dtable
	__objc_update_dispatch_table_for_class(newClass);
	// Create the slots 
	hcls->slots = [NSMutableDictionary new];
	hcls->blockMethods = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks,
			NSObjectMapValueCallBacks, 5);
	return hcls;
}
/**
 * Perform a hidden class transform if this object is not already a prototype.
 */
static void hiddenClassTransform(id obj)
{
	Class isa = obj->class_pointer;
	// Don't transform an already transformed class.
	if (CLS_ISHIDDEN(isa) && ((HiddenClass)isa)->owner == obj)
	{
		return;
	}
	// Set the isa pointer to a hidden class inheriting from this one.
	HiddenClass hcls = hiddenClassFromClass(obj->class_pointer);
	// Not retained, or there would be a cycle
	hcls->owner = obj;
	obj->class_pointer = (Class)hcls;
}

/**
 * Module load function, run when the module is loaded.  Initialises the global
 * data.
 */
static void __attribute__((constructor))load(void)
{
	NULL_OBJECT_PLACEHOLDER = [[NSObject alloc] init];
	// Set up the method list.
	defaultMethods.method_next = NULL;
	defaultMethods.method_count = HIDDEN_CLASS_METHODS;
	SEL sel = sel_get_uid("dealloc");
	defaultMethods.method_list[0].method_name = sel;
	defaultMethods.method_list[0].method_types = sel_get_type(sel);
	defaultMethods.method_list[0].method_imp = (IMP)hiddenClassDealloc;
	sel = sel_get_uid("setValue:forUndefinedKey:");
	defaultMethods.method_list[1].method_name = sel;
	defaultMethods.method_list[1].method_types = sel_get_type(sel);
	defaultMethods.method_list[1].method_imp = 
		(IMP)hiddenClassSetValueForUndefinedKey;
	sel = sel_get_uid("valueForUndefinedKey:");
	defaultMethods.method_list[2].method_name = sel;
	defaultMethods.method_list[2].method_types = sel_get_type(sel);
	defaultMethods.method_list[2].method_imp = 
		(IMP)hiddenClassValueForUndefinedKey;
	defaultClassMethods.method_count = 1;
	sel = sel_get_uid("allocWithZone:");
	defaultClassMethods.method_list[0].method_name = sel;
	defaultClassMethods.method_list[0].method_types = sel_get_type(sel);
	defaultClassMethods.method_list[0].method_imp = 
		(IMP)hiddenClassAllocWithZone;
}

@protocol BlockClosure 
- (int32_t) argumentCount;
- value:a1;
- value:a1 value:a2;
- value:a1 value:a2 value:a3;
- value:a1 value:a2 value:a3 value:a4;
- value:a1 value:a2 value:a3 value:a4 value:a5;
@end

static id blockTrampoline(id self, SEL _cmd, ...)
{
	id block = nil;
	for (Class cls=(self->class_pointer) ;
	     block == nil && CLS_ISHIDDEN(cls) ; 
	     cls=cls->super_class)
	{
		block = NSMapGet(((HiddenClass)cls)->blockMethods,
		   sel_get_name(_cmd));
	}
	va_list ap;
	va_start(ap, _cmd);
	switch ([block argumentCount])
	{
		default:
		case 0:
			[NSException raise:NSInvalidArgumentException
			            format:@"Incorrect number of arguments"];
		case 1:
			return [block value:self];
		case 2:
		{
			id arg1 = va_arg(ap, id);
			return [block value:self value:arg1];
		}
		case 3:
		{
			id arg1 = va_arg(ap, id);
			id arg2 = va_arg(ap, id);
			return [block value:self value:arg1 value:arg2];
		}
		case 4:
		{
			id arg1 = va_arg(ap, id);
			id arg2 = va_arg(ap, id);
			id arg3 = va_arg(ap, id);
			return [block value:self value:arg1 value:arg2 value:arg3];
		}
		case 5:
		{
			id arg1 = va_arg(ap, id);
			id arg2 = va_arg(ap, id);
			id arg3 = va_arg(ap, id);
			id arg4 = va_arg(ap, id);
			return [block value:self
			              value:arg1
			              value:arg2
			              value:arg3
			              value:arg4];
		}
	}
	return [block value];
}

@implementation NSObject (Prototypes)
- (void) setMethod:(IMP)aMethod forSelector:(SEL)aSelector
{
	// Ensure that this object has a hidden class
	hiddenClassTransform(self);
	// Create a new method list
	MethodList_t newList = calloc(1, sizeof(MethodList));
	newList->method_count = 1;
	newList->method_list[0].method_name = aSelector;
	newList->method_list[0].method_types = sel_get_type(aSelector);
	newList->method_list[0].method_imp = (IMP)aMethod;
	// Add the list to the class
	newList->method_next = isa->methods;
	isa->methods = newList;
	// Update the dtable.
	__objc_update_dispatch_table_for_class(isa);
}
- (id) cloneWithZone: (NSZone *)zone
{
	id obj = [isa copyWithZone: zone];
	obj->class_pointer = (Class)hiddenClassFromClass(obj->class_pointer);
	return obj;
}
- (BOOL) isPrototype
{
	return CLS_ISHIDDEN(isa);
}
- (id) prototype
{
	id proto = nil;
	Class cls = isa;
	while (CLS_ISHIDDEN(cls) && (self != ((HiddenClass)cls)->owner))
	{
		cls = cls->super_class;
	}
	if (CLS_ISHIDDEN(cls))
	{
		proto = ((HiddenClass)cls)->owner;
	}
	return proto;
}
- (void) becomePrototype
{
	hiddenClassTransform(self);
}
@end
