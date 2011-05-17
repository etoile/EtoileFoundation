#import "NSObject+Mixins.h"
#include <objc/runtime.h>

static inline BOOL validateMethodTypes(Method method1, Method method2)
{
	return (strcmp(method_getTypeEncoding(method1), method_getTypeEncoding(method2)) == 0);
}

static inline Method findMethod(Method method, Class aClass, BOOL searchSuper)
{
	const char *selectorName = sel_getName(method_getName(method));
	Class class = aClass;

	while (class != Nil)
	{
		unsigned int methodCount = 0;
		Method *methods = class_copyMethodList(class, &methodCount);

		for (unsigned int i = 0; i < methodCount; i++)
		{
			SEL selectorInUse = method_getName(methods[i]);
			// NOTE: We don't check selector equality, in case multiple 
			// selectors whose type encodings vary, use the same name.
			// For example, if we compare (BOOL)bla vs (id)bla, then the later 
			// is returned and it's the responsability of the caller to validate 
			// method equality based on their type encoding. 
			if(strcmp(selectorName, sel_getName(selectorInUse)) == 0)
			{
				free(methods);
				return class_getInstanceMethod(class, selectorInUse);;
			}
		}
		free(methods);

		class = (searchSuper ? class_getSuperclass(class) : Nil);
	}

	return NULL;
}

static inline BOOL methodTypesMatch(Class aClass, Class aMixin)
{
	unsigned int methodCount = 0;
	Method *methods = class_copyMethodList(aMixin, &methodCount);

	for (unsigned int i = 0; i < methodCount; i++)
	{
		Method newMethod = methods[i];
		Method oldMethod = findMethod(newMethod, aClass, YES);

		/* If there is an existing method with this name, check the types match */
		if (oldMethod != NULL && validateMethodTypes(oldMethod, newMethod) == NO)
		{
			free(methods);
			return NO;
		}
	}
	free(methods);

	return YES;
}

static inline BOOL validateIvarTypes(Ivar ivar1, Ivar ivar2)
{
	return (strcmp(ivar_getTypeEncoding(ivar1), ivar_getTypeEncoding(ivar2)) == 0);
}

static inline BOOL iVarTypesMatch(Class aClass, Class aMixin)
{
	unsigned int mixinIvarCount = 0;
	Ivar *mixinIvars = class_copyIvarList(aMixin, &mixinIvarCount);
	unsigned int classIvarCount = 0;
	Ivar *classIvars = class_copyIvarList(aMixin, &classIvarCount);

	if (mixinIvars != NULL && classIvars != NULL && mixinIvarCount <= classIvarCount)
	{
		/* Look at each ivar in the mixin */
		for (unsigned int i = 0; i < mixinIvarCount; i++)
		{
			/* If the mixin has ivars of a different type to the class */
			if (validateIvarTypes(mixinIvars[i], classIvars[i]) == NO) // FIXME: Should findIvars and not classIvars[i]
			{
				free(mixinIvars);
				free(classIvars);
				return NO;
			}
		}
	}
	free(mixinIvars);
	free(classIvars);

	return YES;
}

static inline void replaceMethodWithMethod(Class aClass, Method aMethod)
{
	SEL selector = method_getName(aMethod);
	IMP imp = method_getImplementation(aMethod);
	const char *typeEncoding = method_getTypeEncoding(aMethod);

	class_replaceMethod(aClass, selector, imp, typeEncoding);
}

static inline void replaceMethods(Class aClass, Method *methods, unsigned int methodCount)
{
	for (unsigned int i = 0; i < methodCount; i++)
	{
		replaceMethodWithMethod(aClass, methods[i]);
	}
}

static void checkSafeComposition(Class class, Class appliedClass)
{
	/* Check that the mixin will never try to access ivars from after the end of the object */
	if (class_getInstanceSize(class) < class_getInstanceSize(appliedClass))
	{
		[NSException raise: @"MixinTooBigException"
		            format: @"Class %@ is smaller than composed class %@. Instance variables access from mixin is unsafe.", class, appliedClass];
	}
	if (!iVarTypesMatch(class, appliedClass))
	{
		[NSException raise: @"MixinIVarTypeMismatchException"
		            format: @"Instance variables of class %@ do not match those of composed class %@. Instance variables access from composed class is unsafe.", class, appliedClass];
	}
	if (!methodTypesMatch(class, appliedClass))
	{
		[NSException raise: @"MixinMethodTypeMismatchException"
		            format: @"Method types of class %@ do not match those of mixin %@.", class, appliedClass];
	}
}

static struct objc_class
{
	struct objc_class         *isa;
	struct objc_class         *super_class;
	const char                *name;
	long                       version;
	unsigned long              info;
	long                       instance_size;
	struct objc_ivar_list     *ivars;
	struct objc_method_list   *methods;
	void                      *dtable;
	struct objc_class         *subclass_list;
	struct objc_class         *sibling_class;
	struct objc_protocol_list *protocols;
	void                      *gc_object_type;
	long                       abi_version;
	int                      **ivar_offsets;
	struct objc_property_list *properties;
};

#pragma clang diagnostic ignored "-Wdeprecated-declarations" /* For class_setSuperclass() */

@implementation NSObject (Mixins)

+ (void) applyMixinFromClass: (Class)aClass
{
	Class class = (Class)self;

	checkSafeComposition(class, aClass);

	Class newSuper = objc_allocateClassPair(class_getSuperclass(class), "test" , 0);

	/* Move ivar and method definitions to the new superclass */
	// TODO: To rewrite that correctly we need class_removeMethod_np() and 
	// class_removeIvar_np()
	newSuper->ivars = class->ivars;
	newSuper->ivar_offsets = class->ivar_offsets;
	class->ivars = NULL;
	class->ivar_offsets = NULL;
	newSuper->methods = class->methods; 
	class->methods = aClass->methods;
	newSuper->properties = class->properties;

	/* Insert into the class hierarchy */
	class_setSuperclass(class, newSuper);

	class_registerClassPair(newSuper);
	objc_update_dtable_for_class(class);
}

+ (void) applyTraitFromClass:(Class)aClass
{
	[self applyTraitFromClass: aClass 
          excludedMethodNames: nil 
           aliasedMethodNames: nil 
	           allowsOverride: NO];
}

+ (void) applyTraitFromClass: (Class)aClass 
         excludedMethodNames: (NSArray *)excludedNames
          aliasedMethodNames: (NSArray *)aliasedNames
              allowsOverride: (BOOL)override
{
	Class class = (Class)self;

	checkSafeComposition(class, aClass);

	/* Check trait composition */
	unsigned int methodCount = 0;
	Method *methods = class_copyMethodList(aClass, &methodCount);

	for (unsigned int i = 0; i < methodCount; i++)
	{
		// Check that the target class doesn't implement the method
		if (findMethod(methods[i], class, NO) == NULL)
		{
			replaceMethodWithMethod(class, methods[i]);
			// TODO: Support composite trait rules
			//[NSException raise: @"TraitMethodExistsException"
			//            format: @"Methods class %@ redefined in %@.", self, aClass];
		}
	}
	free(methods);
}

@end
