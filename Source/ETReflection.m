/*
	Mirror-based reflection API for Etoile.
 
	Copyright (C) 2009 Eric Wasylishen
 
	Author:  Eric Wasylishen <ewasylishen@gmail.com>
	Date:  June 2009
	License: Modified BSD (see COPYING)
 */

#import <EtoileFoundation/EtoileFoundation.h>
#import "ETReflection.h"

#ifndef GNUSTEP
#import <objc/runtime.h>
#else
#import <ObjectiveC2/runtime.h>
#endif

@interface ETClassMirror : NSObject <ETClassMirror>
{
	Class _class;
}
+ (id) mirrorWithClass: (Class)class;
- (id) initWithClass: (Class)class;
- (Class) representedClass;
@end

@interface ETObjectMirror : NSObject <ETObjectMirror>
{
	id _object;
}
+ (id) mirrorWithObject: (id)object;
- (id) initWithObject: (id)object;
- (id) representedObject;
@end

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

@interface ETInstanceVariableMirror : NSObject <ETInstanceVariableMirror>
{
	Ivar _ivar;
}
- (id) initWithIvar: (Ivar)ivar;
+ (id) mirrorWithIvar: (Ivar)ivar;
@end

@interface ETProtocolMirror : NSObject <ETProtocolMirror>
{
	Protocol *_protocol;
}
- (id) initWithProtocol: (Protocol *)protocol;
+ (id) mirrorWithProtocol: (Protocol *)protocol;
@end





@implementation ETClassMirror
+ (id) mirrorWithClass: (Class)class
{
	return [[[ETClassMirror alloc] initWithClass: class] autorelease];
}
- (id) initWithClass: (Class)class
{
	SUPERINIT
	if (class == Nil)
	{
		[self release];
		return nil;
	}
	_class = class;
	return self;
}
- (BOOL) isEqual: (id)obj
{
	return [obj isMemberOfClass: [ETClassMirror class]] &&
		[obj representedClass] == _class;
}
- (unsigned int) hash
{
	// FIXME: doing this will cause ETClassMirrors to have hash collisions
	// with strings of the class names.. don't think this is a problem though.
	return [[self name] hash];
}
- (id <ETClassMirror>) superclassMirror
{
	return [ETClassMirror mirrorWithClass: class_getSuperclass(_class)];
}
- (NSArray *) subclassMirrors
{
	NSMutableArray *mirrors = [NSMutableArray array];
	unsigned int classesCount = objc_getClassList(NULL, 0);
	if (classesCount > 0)
	{
		Class *allClasses = malloc(sizeof(Class) * classesCount);
		classesCount = objc_getClassList(allClasses, classesCount);
		for (unsigned int i=0; i<classesCount; i++)
		{
			if (class_getSuperclass(allClasses[i]) == _class)
			{
				[mirrors addObject:
					[ETClassMirror mirrorWithClass: allClasses[i]]];
			}
		}
		free(allClasses);
	}
	return mirrors;
}
- (NSArray *) allSubclassMirrors
{
	NSMutableArray *mirrors = [NSMutableArray array];
	unsigned int classesCount = objc_getClassList(NULL, 0);
	if (classesCount > 0)
	{
		Class *allClasses = malloc(sizeof(Class) * classesCount);
		classesCount = objc_getClassList(allClasses, classesCount);
		for (unsigned int i=0; i<classesCount; i++)
		{
			for (Class cls = allClasses[i]; cls != Nil; cls = class_getSuperclass(cls))
			{
				if (class_getSuperclass(cls) == _class)
				{
					[mirrors addObject:	[ETClassMirror mirrorWithClass: cls]];
				}
			}
		}
		free(allClasses);
	}
	return mirrors;
}
- (NSArray *) adoptedProtocolMirrors
{
	unsigned int protocolsCount;
	Protocol **protocols = class_copyProtocolList(_class, &protocolsCount);
	NSMutableArray *mirrors = [NSMutableArray arrayWithCapacity: protocolsCount];
	for (int i=0; i<protocolsCount; i++)
	{
		[mirrors addObject: [ETProtocolMirror mirrorWithProtocol: protocols[i]]];
	}
	if (protocols != NULL)
	{
		free(protocols);
	}
	return mirrors;
}
- (NSArray *) allAdoptedProtocolMirrors
{
	NSArray *adoptedProtocolMirrors = [self adoptedProtocolMirrors];
	// Using a set to remove duplicates from the result
	NSMutableSet *mirrors = [NSMutableSet setWithArray: adoptedProtocolMirrors];
	FOREACH(adoptedProtocolMirrors, protocol, ETProtocolMirror *)
	{
		[mirrors addObjectsFromArray: [protocol allAncestorProtocolMirrors]];
	}
	return [mirrors allObjects];
}
/** 
 * Returns instance and class methods belonging to this class (but not those inherited
 * from superclasses).
 */
- (NSArray *) methodMirrors
{
	unsigned int instanceMethodsCount, classMethodsCount;
	Method *instanceMethods = class_copyMethodList(_class, &instanceMethodsCount);
	Class metaClass = object_getClass((id)_class);
	Method *classMethods = class_copyMethodList(metaClass, &classMethodsCount);
	NSMutableArray *mirrors = [NSMutableArray arrayWithCapacity: instanceMethodsCount + classMethodsCount];

	for (int i=0; i<instanceMethodsCount; i++)
	{
		[mirrors addObject: [ETMethodMirror mirrorWithMethod: instanceMethods[i] isClassMethod: NO]];
	}
	for (int i=0; i<classMethodsCount; i++)
	{
		[mirrors addObject: [ETMethodMirror mirrorWithMethod: classMethods[i] isClassMethod: YES]];
	}

	if (instanceMethods != NULL)
	{
		free(instanceMethods);
	}
	if (classMethods != NULL)
	{
		free(classMethods);
	}
	return mirrors;
}
- (NSArray *) allMethodMirrors
{
	if ([self superclassMirror] != nil)
	{
		// FIXME: we can do this is a more efficient way
		return [[self methodMirrors] arrayByAddingObjectsFromArray:
			[[self superclassMirror] allMethodMirrors]];
	}
	else
	{
		return [self methodMirrors];
	}
}
- (NSArray *) instanceVariableMirrors
{
	unsigned int ivarsCount;
	Ivar *ivars = class_copyIvarList(_class, &ivarsCount);
	NSMutableArray *mirrors = [NSMutableArray arrayWithCapacity: ivarsCount];
	for (int i=0; i<ivarsCount; i++)
	{
		[mirrors addObject: [ETInstanceVariableMirror mirrorWithIvar: ivars[i]]];
	}
	if (ivars != NULL)
	{
		free(ivars);
	}
	return mirrors;
}
- (NSArray *) allInstanceVariableMirrors
{
	NSMutableArray *mirrors = [NSMutableArray array];
	Class cls = _class;
	while (cls != Nil)
	{
		unsigned int ivarsCount;
		Ivar *ivars = class_copyIvarList(_class, &ivarsCount);
		for (int i=0; i<ivarsCount; i++)
		{
			[mirrors addObject: [ETInstanceVariableMirror mirrorWithIvar: ivars[i]]];
		}
		if (ivars != NULL)
		{
			free(ivars);
		}
		cls = class_getSuperclass(cls);
	}
	return mirrors;
}
- (BOOL) isMetaClass
{
	return class_isMetaClass(_class);
}
// FIXME: The Objective-C 2.0 API has a facility for "class variables", maybe mirror these?
- (NSString *) name
{
	return [NSString stringWithUTF8String: class_getName(_class)];
}
- (Class) representedClass
{
	return _class;
}
- (ETUTI *) type
{
	return [ETUTI typeWithClass: _class];
}
- (NSString *) description
{
	return [NSString stringWithFormat:
			@"ETClassMirror on (%@). Superclass: (%@)",
			_class, [self superclassMirror]];
}

/* Collection Protocol */

- (BOOL) isOrdered
{
	return NO;
}
- (BOOL) isEmpty
{
	return [[self contentArray] count] == 0;
}
- (id) content;
{
	return [self contentArray];
}
- (NSArray *) contentArray;
{
	return [[self instanceVariableMirrors] arrayByAddingObjectsFromArray: 
			[self allMethodMirrors]];
}
- (NSEnumerator *) objectEnumerator
{
	return [[self contentArray] objectEnumerator];
}
- (unsigned int) count
{
	return [[self contentArray] count];
}

/* Property-value coding */

- (NSArray *) properties
{
	return [[super properties] arrayByAddingObjectsFromArray: 
			A(@"name")];
}
@end





@implementation ETObjectMirror
+ (id) mirrorWithObject: (id)object
{
	return [[[ETObjectMirror alloc] initWithObject: object] autorelease];
}
- (id) initWithObject: (id)object
{
	SUPERINIT
	if (object == nil)
	{
		[self release];
		return nil;
	}
	_object = object;
	return self;
}
- (BOOL) isEqual: (id)obj
{
	return [obj isMemberOfClass: [ETObjectMirror class]] &&
		[obj representedObject] == _object;
}
- (NSUInteger) hash
{
	// NOTE: The cast prevents a compiler warning about pointer truncation on
	// 64bit systems.
	return (uintptr_t) _object;
}
- (id <ETClassMirror>) classMirror
{
	return [ETClassMirror mirrorWithClass: object_getClass(_object)];
}
- (id <ETClassMirror>) superclassMirror
{
	return [[self classMirror] superclassMirror];
}
- (id <ETObjectMirror>) prototypeMirror
{
	// FIXME: this assumes object is an NSObject subclass
	// and we are using ETPrototype
	if ([self isPrototype])
	{
		return [ETObjectMirror mirrorWithObject: [_object prototype]];
	}
	else
	{
		return nil;
	}
}
- (NSArray *) instanceVariableMirrors
{
	// FIXME: Should these ivar mirrors reflect the contents of this object's ivars/be editable?
	return [[self classMirror] instanceVariableMirrors];
}
- (NSArray *) allInstanceVariableMirrors
{
	// FIXME: Should these ivar mirrors reflect the contents of this object's ivars/be editable?
	return [[self classMirror] allInstanceVariableMirrors];
}
- (NSArray *) methodMirrors
{
	// FIXME: If this is a prototype object, return any methods added to this object
	return [NSArray array];
}
- (NSArray *) allMethodMirrors
{
	// FIXME: If this is a prototype object, return any methods added to this object
	// as well as any methods added to this object's prototypes.
	return [NSArray array];
}
- (NSArray *) slotMirrors
{
	return [[self methodMirrors] arrayByAddingObjectsFromArray:
		[self instanceVariableMirrors]];
}
- (NSArray *) allSlotMirrors
{
	return [[self allMethodMirrors] arrayByAddingObjectsFromArray:
		[self allInstanceVariableMirrors]];
}
- (NSString *) name
{
	// FIXME: What should the name of an object be?
	return [[self classMirror] name];
}
- (id) representedObject
{
	return _object;
}
- (BOOL) isPrototype
{
	// FIXME: this assumes object is an NSObject subclass
	// and we are using ETPrototype
	// FIXME: Check without calling a method on _object?
	return [_object isPrototype];
}
- (ETUTI *) type
{
	return [[self classMirror] type];
}
- (NSString *) description
{
	return [NSString stringWithFormat:
			@"ETObjectMirror on %@\nClass mirror: %@",
			_object, [self classMirror]];
}

/* Collection Protocol */

- (BOOL) isOrdered
{
	return NO;
}
- (BOOL) isEmpty
{
	return [[self contentArray] count] == 0;
}
- (id) content;
{
	return [self contentArray];
}
- (NSArray *) contentArray;
{
	return [self allSlotMirrors];
}
- (NSEnumerator *) objectEnumerator
{
	return [[self contentArray] objectEnumerator];
}
- (unsigned int) count
{
	return [[self contentArray] count];
}

/* Property-value coding */

- (NSArray *) properties
{
	return [[super properties] arrayByAddingObjectsFromArray: 
			A(@"isPrototype", @"representedObject")];
}

@end




@implementation ETProtocolMirror
+ (id) mirrorWithProtocol: (Protocol *)protocol
{
	return [[[ETProtocolMirror alloc] initWithProtocol: protocol] autorelease];
}
- (id) initWithProtocol: (Protocol *)protocol
{
	SUPERINIT
	_protocol = protocol;
	return self;
}
- (BOOL) isEqual: (id)obj
{
	return [obj isMemberOfClass: [ETProtocolMirror class]] && 
		[[obj name] isEqualToString: [self name]];
}
- (unsigned int) hash
{
	return [[self name] hash];
}
- (NSString *) name
{
	return [NSString stringWithUTF8String: protocol_getName(_protocol)];
}
- (NSArray *) ancestorProtocolMirrors
{
	unsigned int protocolsCount;
	Protocol **protocols = protocol_copyProtocolList(_protocol, &protocolsCount);
	NSMutableArray *mirrors = [NSMutableArray arrayWithCapacity: protocolsCount];
	for (int i=0; i<protocolsCount; i++)
	{
		[mirrors addObject: [ETProtocolMirror mirrorWithProtocol: protocols[i]]];
	}
	if (protocols != NULL)
	{
		free(protocols);
	}
	return mirrors;
}
- (NSArray *) allAncestorProtocolMirrors
{
	NSArray *ancestorProtocolMirrors = [self ancestorProtocolMirrors];
	// Using a set to remove duplicates from the result
	NSMutableSet *mirrors = [NSMutableSet setWithArray: ancestorProtocolMirrors];
	FOREACH(ancestorProtocolMirrors, ancestor, ETProtocolMirror *)
	{
		[mirrors addObjectsFromArray: [ancestor allAncestorProtocolMirrors]];
	}
	return [mirrors allObjects];
}
- (NSArray *) methodMirrors
{
	// TODO: Fetch non-required methods from the protocol description
	unsigned int instanceMethodsCount, classMethodsCount;
	struct objc_method_description *instanceMethods = 
		protocol_copyMethodDescriptionList(_protocol, YES, YES, &instanceMethodsCount);
	struct objc_method_description *classMethods = 
		protocol_copyMethodDescriptionList(_protocol, YES, NO, &classMethodsCount);
	NSMutableArray *mirrors = [NSMutableArray arrayWithCapacity: instanceMethodsCount + classMethodsCount];

	for (int i=0; i<instanceMethodsCount; i++)
	{
		[mirrors addObject: [ETMethodDescriptionMirror mirrorWithMethodName: sel_getName(instanceMethods[i].name)
															  isClassMethod: NO]];
	}
	for (int i=0; i<classMethodsCount; i++)
	{
		[mirrors addObject: [ETMethodDescriptionMirror mirrorWithMethodName: sel_getName(classMethods[i].name)
															  isClassMethod: YES]];
	}

	if (instanceMethods != NULL)
	{
		free(instanceMethods);
	}
	if (classMethods != NULL)
	{
		free(classMethods);
	}
	return mirrors;
}
- (NSArray *) allMethodMirrors
{
	NSArray *ancestorProtocolMirrors = [self ancestorProtocolMirrors];
	NSMutableArray *mirrors = [[self methodMirrors] mutableCopy];
	FOREACH(ancestorProtocolMirrors, ancestor, ETProtocolMirror *)
	{
		[mirrors addObjectsFromArray: [ancestor allMethodMirrors]];
	}
	return mirrors;
}
- (ETUTI *) type
{
	return [ETUTI typeWithString: @"org.etoile.objc.protocol"];
}

/* Collection Protocol */

- (BOOL) isOrdered
{
	return NO;
}
- (BOOL) isEmpty
{
	return [[self contentArray] count] == 0;
}
- (id) content;
{
	return [self contentArray];
}
- (NSArray *) contentArray;
{
	return [self allMethodMirrors];
}
- (NSEnumerator *) objectEnumerator
{
	return [[self contentArray] objectEnumerator];
}
- (unsigned int) count
{
	return [[self contentArray] count];
}


/* Property-value coding */

- (NSArray *) properties
{
	return [[super properties] arrayByAddingObjectsFromArray: 
			A(@"name")];
}
@end


@implementation ETMethodMirror
+ (id) mirrorWithMethod: (Method)method isClassMethod: (BOOL)isClassMethod
{
	return [[[ETMethodMirror alloc] initWithMethod: method
	                                 isClassMethod: isClassMethod] autorelease];
}
- (id) initWithMethod: (Method)method isClassMethod: (BOOL)isClassMethod
{
	SUPERINIT
	_method = method;
	_isClassMethod = isClassMethod;
	return self;
}

- (NSString *) name
{
	return [NSString stringWithUTF8String: sel_getName(method_getName(_method))];	
}
- (NSArray *) properties
{
	return [[super properties] arrayByAddingObjectsFromArray: 
			A(@"name", "isClassMethod")];
}
- (BOOL) isClassMethod
{
	return _isClassMethod;
}
- (ETUTI *) type
{
	// FIXME: is there any point to having a org.etoile.method UTI? Probably not..?
	return nil;
}
@end


@implementation ETMethodDescriptionMirror
+ (id) mirrorWithMethodName: (const char *)name
              isClassMethod: (BOOL)isClassMethod
{
	return [[ETMethodMirror alloc] initWithMethodName:name
                                        isClassMethod:isClassMethod];
}
- (id) initWithMethodName: (const char *)name isClassMethod: (BOOL)isClassMethod
{
	SUPERINIT
	_name = [[NSString alloc] initWithUTF8String: name];
	_isClassMethod = isClassMethod;
	return self;
}
- (void) dealloc
{
	[_name release];
	[super dealloc];
}
- (NSString *) name
{
	return _name;
}
- (NSArray *) properties
{
	return [[super properties] arrayByAddingObjectsFromArray: 
			A(@"name", "isClassMethod")];
}
- (BOOL) isClassMethod
{
	return _isClassMethod;
}
- (ETUTI *) type
{
	// FIXME: is there any point to having a org.etoile.method UTI? Probably not..?
	return nil;
}
@end



@implementation ETInstanceVariableMirror
- (id) initWithIvar: (Ivar)ivar
{
	SUPERINIT;
	_ivar = ivar;
	return self;
}
+ (id) mirrorWithIvar: (Ivar)ivar
{
	return [[[ETInstanceVariable alloc] initWithIvar: ivar] autorelease];
}
- (NSString *) name
{
	return [NSString stringWithUTF8String: ivar_getName(_ivar)];
}
- (NSArray *) properties
{
	return [[super properties] arrayByAddingObjectsFromArray: 
			A(@"name")];
}
- (ETUTI *) type
{
	// FIXME: map ivar type to a UTI
	return [ETUTI typeWithClass: [NSObject class]];
}
@end



@implementation ETReflection

+ (id <ETObjectMirror>) reflectObject: (id)anObject
{
	return [ETObjectMirror mirrorWithObject: anObject];
}
+ (id <ETClassMirror>) reflectClass: (Class)aClass
{
	return [ETClassMirror mirrorWithClass: aClass];
}
+ (id <ETClassMirror>) reflectClassWithName: (NSString *)className
{
	id class = objc_getClass([className UTF8String]);
	if (class != nil)
	{
		return [ETClassMirror mirrorWithClass: (Class)class];
	}
	return nil;
}
+ (id <ETProtocolMirror>) reflectProtocolWithName: (NSString *)protocolName
{
	Protocol *protocol = objc_getProtocol([protocolName UTF8String]);
	if (protocol != nil)
	{
		return [ETProtocolMirror mirrorWithProtocol: protocol];
	}
	return nil;
}

@end

