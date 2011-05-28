#import "NSObject+Mixins.h"
#import "ETCollection+HOM.h"
#import "Macros.h"
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

static inline void replaceMethodWithMethod(Class aClass, Method aMethod, const char *customMethodName)
{
	SEL selector = method_getName(aMethod);
	IMP imp = method_getImplementation(aMethod);
	const char *typeEncoding = method_getTypeEncoding(aMethod);

	if (customMethodName != NULL)
	{
		selector = sel_registerName(customMethodName);
	}

	class_replaceMethod(aClass, selector, imp, typeEncoding);
}

// TODO: Probably remove
static inline void replaceMethods(Class aClass, Method *methods, unsigned int methodCount)
{
	for (unsigned int i = 0; i < methodCount; i++)
	{
		replaceMethodWithMethod(aClass, methods[i], NULL);
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

static NSSet *methodNamesForClass(Class aClass)
{
	unsigned int methodCount;
	Method *methods = class_copyMethodList(aClass, &methodCount);
	NSMutableSet *methodNames = [NSMutableSet setWithCapacity: methodCount];

	for (int i = 0; i < methodCount; i++)
	{
		const char *name = sel_getName(method_getName(methods[i]));
		[methodNames addObject: [NSString stringWithUTF8String: name]];
	}
	free(methods);

	return methodNames;
}

@interface NSObject (Private)
+ (NSMutableArray *) traitApplications;
@end

@interface ETTraitApplication : NSObject
{
	Class trait;
	NSSet *excludedMethodNames;
	NSDictionary *aliasedMethodNames;
	NSMapTable *overridenMethods;
}

@property (retain, nonatomic) Class trait;
@property (retain, nonatomic) NSSet *excludedMethodNames;
@property (retain, nonatomic) NSDictionary *aliasedMethodNames;
@property (retain, nonatomic) NSMapTable *overridenMethods;
@property (readonly, nonatomic) NSSet *methodNames;
@property (readonly, nonatomic) NSSet *appliedMethodNames;

@end

@implementation ETTraitApplication

@synthesize trait, excludedMethodNames, aliasedMethodNames, overridenMethods;

- (id) initWithTrait: (Class)aTrait
{
	SUPERINIT;
	ASSIGN(trait, aTrait);
	excludedMethodNames = [[NSSet alloc] init];
	aliasedMethodNames = [[NSDictionary alloc] init];
	overridenMethods = [[NSMapTable alloc] init];
	return self;
}

- (void) dealloc
{
	DESTROY(trait);
	DESTROY(excludedMethodNames);
	DESTROY(aliasedMethodNames);
	DESTROY(overridenMethods);
	[super dealloc];
}

- (NSSet *) methodNames
{
	return methodNamesForClass(trait);
}

- (NSSet *) appliedMethodNames
{
	NSMutableSet *methodNames = [NSMutableSet set];

	for (NSString *name in [self methodNames])
	{
		if ([excludedMethodNames containsObject: name])
			continue;

		NSString *aliasedName = [aliasedMethodNames objectForKey: name];

		[methodNames addObject: (aliasedName != nil ? aliasedName : name)];
	}

	return methodNames;
}

@end

static void applyTrait(Class class, ETTraitApplication *aTraitApplication)
{
	NSSet *traitMethodNames = [aTraitApplication appliedMethodNames];
	NSSet *excludedNames = [aTraitApplication excludedMethodNames];
	NSDictionary *aliasedNames = [aTraitApplication aliasedMethodNames];
	unsigned int methodCount = 0;
	Method *methods = class_copyMethodList([aTraitApplication trait], &methodCount);

	for (unsigned int i = 0; i < methodCount; i++)
	{
		NSString *methodName = [NSString stringWithUTF8String: sel_getName(method_getName(methods[i]))];

		if ([traitMethodNames containsObject: methodName] == NO)
		{
			/* A trait method can be excluded */
			if ([excludedNames containsObject: methodName])
					continue;

			/* A trait method can be aliased */
			methodName = [aliasedNames objectForKey: methodName];
			assert(methodName != nil);
		}

		/* A trait method cannot override a method in the target class */
		if (findMethod(methods[i], class, NO) == NULL)
		{
			replaceMethodWithMethod(class, methods[i], [methodName UTF8String]);
		}
	}
	free(methods);
}

static NSSet *intersectionSet(NSSet *set, NSSet *otherSet)
{
	NSSet *newSet = [NSMutableSet setWithSet: set];
	[newSet intersectsSet: otherSet];
	return newSet;
}

static void checkTraitApplication(Class aClass, ETTraitApplication *aTraitApplication)
{
	NSSet *traitMethodNames = [aTraitApplication appliedMethodNames];
	NSSet *methodNames = methodNamesForClass(aClass);

	for (ETTraitApplication *traitApp in [aClass traitApplications])
	{
		methodNames = [traitApp appliedMethodNames];

		if ([traitMethodNames intersectsSet: methodNames])
		{
			[NSException raise: @"ETTraitApplicationException"
			            format: @"Trait methods %@ from %@ already exist in trait %@ previously applied to class %@.", 
			                    intersectionSet(traitMethodNames, methodNames), 
			                    [aTraitApplication trait], [traitApp trait], aClass];
		}
	}
}

@implementation NSObject (Mixins)

static NSMapTable *traitApplicationsByClass = nil;

+ (void) load
{
	ASSIGN(traitApplicationsByClass, [NSMapTable mapTableWithWeakToStrongObjects]);
}

+ (NSMutableArray *) traitApplications
{
	NSMutableArray *traitApplications = [traitApplicationsByClass objectForKey: self];

	if (traitApplications == nil)
	{
		traitApplications = [NSMutableArray array];
		[traitApplicationsByClass setObject: traitApplications forKey: self];
	}

	return traitApplications;
}

+ (void) applyTraitFromClass: (Class)aClass 
         excludedMethodNames: (NSSet *)excludedNames
          aliasedMethodNames: (NSDictionary *)aliasedNames
        overridenMethodNames: (NSSet *)overridenNames
{
 	ETTraitApplication *traitApplication = AUTORELEASE([[ETTraitApplication alloc] initWithTrait: aClass]);

	[traitApplication setExcludedMethodNames: excludedNames];
	[traitApplication setAliasedMethodNames: aliasedNames];
	// TODO: Track overriden methods (aka mixin-style composition)
	// [traitApplication setOverridenMethods: overridenMethods];

	checkSafeComposition(self, aClass);
	checkTraitApplication(self, traitApplication);
	applyTrait(self, traitApplication);
}

+ (void) applyTraitFromClass:(Class)aClass
{
	[self applyTraitFromClass: aClass 
          excludedMethodNames: nil 
           aliasedMethodNames: nil 
	           allowsOverride: NO];
}

+ (void) applyTraitFromClass: (Class)aClass 
         excludedMethodNames: (NSSet *)excludedNames
          aliasedMethodNames: (NSDictionary *)aliasedNames
{
	[self applyTraitFromClass: aClass 
          excludedMethodNames: excludedNames
           aliasedMethodNames: aliasedNames
	           allowsOverride: NO];
}

+ (void) applyTraitFromClass: (Class)aClass 
         excludedMethodNames: (NSSet *)excludedNames
          aliasedMethodNames: (NSDictionary *)aliasedNames
              allowsOverride: (BOOL)override
{
	NSSet *overridenNames = [NSSet set];

	if (override)
	{
		/* All methods in the target class can be replaced by trait methods */
		overridenNames = methodNamesForClass(aClass);
	}

	[self applyTraitFromClass: aClass 
          excludedMethodNames: excludedNames
           aliasedMethodNames: aliasedNames
	     overridenMethodNames: overridenNames];
}

@end
