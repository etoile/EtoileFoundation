/*
	NSObject+Etoile.m
	
	NSObject additions like basic metamodel.
 
	Copyright (C) 2007 Quentin Mathe
 
	Author:  Quentin Mathe <qmathe@club-internet.fr>
	Date:  August 2007
 
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:

	* Redistributions of source code must retain the above copyright notice,
	  this list of conditions and the following disclaimer.
	* Redistributions in binary form must reproduce the above copyright notice,
	  this list of conditions and the following disclaimer in the documentation
	  and/or other materials provided with the distribution.
	* Neither the name of the Etoile project nor the names of its contributors
	  may be used to endorse or promote products derived from this software
	  without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
	THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NSObject+Etoile.h"
#import "EtoileCompatibility.h"
#import "ETUTI.h"
#import "Macros.h"


@interface NSObject (PrivateEtoile)
- (ETInstanceVariable *) instanceVariableForName: (NSString *)ivarName;
@end

/** Returns the superclass of the class passed in parameter. */
static inline Class ETGetSuperclass(Class aClass)
{
#if defined(GNU_RUNTIME)
	if (CLS_ISRESOLV(aClass))
	{
		return aClass->super_class;
	}
	else
	{
		return objc_lookup_class((char*)aClass->super_class);
	}
#elif defined(GNUSTEP_RUNTIME_COMPATIBILITY)
	return GSObjCSuper(aClass);
#elif defined(NEXT_RUNTIME_2)
	return class_getSuperclass(aClass);
#else /* NEXT_RUNTIME 1 */
	return aClass->superclass;
#endif
}

/** Returns YES if subclass inherits directly or inherits from aClass.
	Unlike +[NSObject isSubclassOfClass:] returns no if subclass and aClass are 
	equal. */
static inline BOOL ETIsSubclassOfClass(Class subclass, Class aClass)
{
	Class parentClass = subclass;

	while (parentClass != nil)
	{
		parentClass = ETGetSuperclass(parentClass);
		if (parentClass == aClass)
			return YES;
    } 

	return NO;
}

@implementation NSObject (Etoile) //<ETInspectableObject>

/** Returns all descendant subclasses of the receiver class. 
    The returned array doesn't include the receiver class. */
+ (NSArray *) allSubclasses
{
	#if 0
	//#ifdef GNUSTEP_RUNTIME_COMPATIBILITY
	/* Fast because it uses the sibling class facility of GNU runtime
	   NOTE: Not used, because it is broken for classes that have not yet 
	   received their first message. */
	return GSObjCAllSubclassesOfClass(self);

	#elif defined(GNU_RUNTIME)
	NSMutableArray *subclasses = [NSMutableArray arrayWithCapacity: 300];
	void *state = NULL;
	Class nextClass = Nil;
	while(Nil != (nextClass = objc_next_class(&state)))
	{
		if (ETIsSubclassOfClass(nextClass, self))
		 {
			[subclasses addObject: nextClass];
		}
	}
	return subclasses;

	#else /* NEXT_RUNTIME and NEXT_RUNTIME_2 */	
	NSMutableArray *subclasses = [NSMutableArray arrayWithCapacity: 300];
	Class *allClasses = NULL;
	int numberOfClasses;

	allClasses = NULL;
	numberOfClasses = objc_getClassList(NULL, 0);

	if (numberOfClasses > 0)
	{
		allClasses = malloc(sizeof(Class) * numberOfClasses);
		numberOfClasses = objc_getClassList(allClasses, numberOfClasses);
		for (int i = 0; i < numberOfClasses; i++)
		{
			if (ETIsSubclassOfClass(allClasses[i], self))
			 {
				[subclasses addObject: allClasses[i]];
			}
		}
		free(allClasses);
	}

	return subclasses;
	#endif
}

/** Returns all subclasses which inherit directly from the receiver class. 
    Subclasses that belongs to the class hierarchy of the receiver class but 
	whose superclasses aren't equal to it, are excluded.
    The returned array doesn't include the receiver class. */
+ (NSArray *) directSubclasses
{
	#ifdef GNUSTEP_RUNTIME_COMPATIBILITY
	return GSObjCDirectSubclassesOfClass(self);

	#else /* NEXT_RUNTIME and NEXT_RUNTIME_2 */
	NSMutableArray *subclasses = [NSMutableArray arrayWithCapacity: 30];
	Class *allClasses = NULL;
	int numberOfClasses;
	 
	allClasses = NULL;
	numberOfClasses = objc_getClassList(NULL, 0);
	 
	if (numberOfClasses > 0)
	{
		allClasses = malloc(sizeof(Class) * numberOfClasses);
		numberOfClasses = objc_getClassList(allClasses, numberOfClasses);
		for (int i = 0; i < numberOfClasses; i++)
		{
			if (ETGetSuperclass(allClasses[i]) == self)
			{
				[subclasses addObject: allClasses[i]];
			}
		}
		free(allClasses);
	}
	
	return subclasses;
	#endif
}

/** Returns a object representing the receiver. Useful when sucblasses override
    root class methods and make them unavailable to introspection. For example,
	ETProtocol represents a protocol but overrides methods like -type, typeName
	-name, -protocols and -protocolNames of NSObject, thereby you can know the 
	properties of the represented protocol, but you cannot access the 
	identically named properties which describes ETProtocol instance itself. */
- (id) metaObject
{
	return nil;
}

/** Returns the uniform type identifier of the object. The UTI object encodes 
	the type of the object in term of namespaces and multiple inheritance. 
	By default, the UTI object is shared by all instances by being built from 
	the class name. If you need to introduce type at instance level, you can
	do it by overriding this method. */
- (ETUTI *) type
{
	return [ETUTI typeWithClass: [self class]];
}

/** Returns the type name which is the last component of type string returned 
	by the UTI object. This type name doesn't include the class prefix.
	This method is a shortcut for [[self type] typeName]. */
- (NSString *) typeName
{
	return nil;
}

/** Returns the type prefix, usually the prefix part of the type name returned
	by -className.
	You must override this method in your subclass to indicate the prefix of 
	your new class name. Take note the prefix will logically apply to every 
	subsequent subclasses inheriting from the class that redefines 
	-typePrefix. */
+ (NSString *) typePrefix
{
	return @"NS";
}

/** Returns both methods and instance variables for the receiver by default */
/*- (NSArray *) slotNames;
- (id) valueForSlot: (NSString *)slot;
- (void) setValue: (id)value forSlot: (NSString *)slot;*/

- (id) valueForInstanceVariable: (NSString *)ivarName
{
	return [[self instanceVariableForName: ivarName] value];
}

- (void) setValue: (id)value forInstanceVariable: (NSString *)ivarName
{
	[[self instanceVariableForName: ivarName] setValue: value];
}

- (ETMethod *) methodForName: (NSString *)name
{
	// BOOL searchInstanceMethods, BOOL searchSuperClasses
	ETMethod *methodObject = [[ETMethod alloc] init];
	
	#ifdef GNUSTEP_RUNTIME_COMPATIBILITY
	GSMethod method = GSGetMethod([self class], NSSelectorFromString(name), YES, YES);
	methodObject->_method = method;
	#else
	
	#endif
	
	return AUTORELEASE(methodObject);
}

- (void) setMethod: (id)value forName: (NSString *)name
{

}

- (NSArray *) instanceVariables
{
	NSMutableArray *ivars = [NSMutableArray array];
	NSEnumerator *e = [[self instanceVariableNames] objectEnumerator];
	NSString *ivarName = nil;
	
	while ((ivarName = [e nextObject]) != nil)
	{
		[ivars addObject: [self instanceVariableForName: ivarName]];
	}
	
	// FIXME: Return immutable array
	return ivars;
}

- (ETInstanceVariable *) instanceVariableForName: (NSString *)ivarName
{
	ETInstanceVariable *ivarObject = [[ETInstanceVariable alloc] init];
	ASSIGN(ivarObject->_possessor, self);

	#ifdef GNUSTEP_RUNTIME_COMPATIBILITY
	GSIVar ivar = GSObjCGetInstanceVariableDefinition([self class], ivarName);
	ivarObject->_ivar = ivar;

	#elif defined(NEXT_RUNTIME_2)
	Ivar ivar = object_getInstanceVariable(self, [ivarName UTF8String], NULL);
	ivarObject->_ivar = ivar;	
	#endif
	
	return AUTORELEASE(ivarObject);
}

- (NSArray *) instanceVariableNames
{
	#ifdef GNUSTEP_RUNTIME_COMPATIBILITY
	return GSObjCVariableNames(self);	

	#elif defined(NEXT_RUNTIME_2)
	NSMutableArray *ivars = [NSMutableArray array];
	Class class = [self class];

	while (class != nil)
	{
		unsigned int nbOfIvars = 0;
		Ivar *ivarList = class_copyIvarList(class, &nbOfIvars);

		for (int i = 0; i < nbOfIvars; i++)
		{
			[ivars addObject: [NSString stringWithUTF8String: ivar_getName(ivarList[i])]];
		}

		class = ETGetSuperclass(class);
	}
	
	return ivars;
	#endif
}

- (NSDictionary *) instancesVariableValues
{
	NSArray *ivarValues = [[self instanceVariables] valueForKey: @"value"];
	NSArray *ivarNames = [[self instanceVariables] valueForKey: @"name"];
	NSDictionary *ivarValueByName =[NSDictionary dictionaryWithObjects: ivarValues forKeys: ivarNames];
	
	return ivarValueByName;
}

- (NSDictionary *) instancesVariableTypes
{
	NSArray *ivarTypes = [[self instanceVariables] valueForKey: @"type"];
	NSArray *ivarNames = [[self instanceVariables] valueForKey: @"name"];
	NSDictionary *ivarTypeByName =[NSDictionary dictionaryWithObjects: ivarTypes forKeys: ivarNames];
	
	return ivarTypeByName;
}

- (id) typeForInstanceVariable: (NSString *)ivarName
{
	return [[self instanceVariableForName: ivarName] type];
}

- (NSArray *) protocolNames
{
	NSMutableArray *protocolNames = [NSMutableArray array];
	FOREACH([self protocols], protocol, Protocol *)
	{
		[protocolNames addObject: [NSString stringWithUTF8String: [protocol name]]];
	}
	return protocolNames;
}

// FIXME: Not sure if this is the right interpretation for -protocols,
//        currently it returns all protocols explicitly conformed to by the
//        object's class, or its superclass, or superclasses's class, etc.,
//        but not the ancestor protocols of those protocols.
//        
//        We also need a -allProtocols method which adds all the ancestors 
//        to the protocols returned by this method.
- (NSArray *) protocols
{
	#if defined(GNU_RUNTIME)
	NSMutableArray *protocols = [NSMutableArray array];

	Class class = [self class];
	while (YES)
	{
		[protocols addObjectsFromArray: [ETClass protocolsForClass: class]];
		if (class == [NSObject class])
			break;
		class = ETGetSuperclass(class);
	}

	// FIXME: Return immutable array
	return protocols;
	#else
	return nil;
	#endif
}

- (NSArray *) methods
{
	NSMutableArray *methods = [NSMutableArray array];
	NSEnumerator *e = [[self methodNames] objectEnumerator];
	NSString *methodName = nil;
	
	while ((methodName = [e nextObject]) != nil)
	{
		[methods addObject: [self methodForName: methodName]];
	}
	
	// FIXME: Return immutable array
	return methods;
}

- (NSArray *) methodNames
{
	#ifdef GNUSTEP_RUNTIME_COMPATIBILITY
	return GSObjCMethodNames(self);
	#else
	return nil;
	#endif
}

#if 0
- (NSArray *) instanceMethods;
- (NSArray *) instanceMethodNames;
- (NSArray *) classMethods;
- (NSArray *) classMethodNames;

- (void) addMethod: (ETMethod *)method;
- (void) removeMethod: (ETMethod *)method;
/** Method swizzling */
- (void) replaceMethod: (ETMethod *)method byMethod: (ETMethod *)method;

/** Low level methods used to implement method list edition */
- (void) bindMethod: (ETMethod *) toSelector: (SEL)selector;
- (void) bindSelector: (SEL) toMethod: (ETMethod *)method;
#endif

@end

@implementation ETInstanceVariable

- (id) possessor
{
	return _possessor;
}

- (NSString *) name
{
	const char *ivarName = NULL;
	
	#ifdef GNUSTEP_RUNTIME_COMPATIBILITY
	ivarName = _ivar->ivar_name;
	#elif defined(NEXT_RUNTIME_2)
	ivarName = ivar_getName(_ivar);
	#endif
		
	return [NSString stringWithCString: ivarName];
}

- (ETUTI *) type
{
	// TODO: Implement
	return nil;
}

- (NSString *) typeName
{
	const char *ivarType = NULL;
	
	#ifdef GNUSTEP_RUNTIME_COMPATIBILITY
	ivarType = _ivar->ivar_type;
	#elif defined(NEXT_RUNTIME_2)
	ivarType = ivar_getTypeEncoding(_ivar);
	#endif

	if (ivarType[0] == '@')
	{
		return NSStringFromClass([[self value] class]);
	}
	else
	{
		return [NSString stringWithCString: ivarType];
	}
}

- (id) value
{
	id ivarValue = nil;
	const char *ivarType = NULL;

	#ifdef GNUSTEP_RUNTIME_COMPATIBILITY
	ivarType = _ivar->ivar_type;
	int ivarOffset = _ivar->ivar_offset;
	
	// TODO: More type support
	if(ivarType[0] == '@')
		GSObjCGetVariable(_possessor, ivarOffset, sizeof(id), (void **)&ivarValue);

	#elif defined(NEXT_RUNTIME_2)
	ivarType = ivar_getTypeEncoding(_ivar);

	// TODO: More type support
	if(ivarType[0] == '@')
		ivarValue = object_getIvar(_possessor, _ivar);
	#endif
			
	return ivarValue;
}

/** Pass NSValue to set primitive types */
- (void) setValue: (id)value
{
	#ifdef GNUSTEP_RUNTIME_COMPATIBILITY
	const char *ivarType = _ivar->ivar_type;
	int ivarOffset = _ivar->ivar_offset;
	
	// FIXME: More type support
	if(strcmp(ivarType, "@"))
		GSObjCSetVariable([self possessor], ivarOffset, sizeof(id), (void **)&value);
	#else
	
	#endif
}

@end

@implementation ETMethod 

/*- (BOOL) isInstanceMethod
{
	
}

- (BOOL) isClassMethod
{

}*/

- (NSString *) name
{
	return NSStringFromSelector([self selector]);
}

- (SEL) selector
{
	#ifdef GNUSTEP_RUNTIME_COMPATIBILITY
	return _method->method_name;
	#else
	return NULL;
	#endif
}

- (NSMethodSignature *) methodSignature
{
	// FIXME: Build sig with member char *method_types of GSMethod
	return nil;
}

@end

/** A Protocol counterpart for Foundation and NSObject root class */
@implementation ETProtocol

/** Returns an ObjC runtime protocol object for the given protocol name. */
+ (Protocol *) protocolForName: (NSString *)name
{
#ifdef GNUSTEP_RUNTIME_COMPATIBILITY
	return GSProtocolFromName([name UTF8String]);
#else
	return nil;
#endif
}

- (NSString *) name
{
	return nil;
	//return [NSString stringWithCString: [_protocol name]];
}

- (ETUTI *) type
{
	return nil;
}

- (NSString *) typeName
{
	return [self name];
}

// FIXME: Add methods like -allAncestorProtocols -allAncestorProtocolNames

/* Overriden NSObject methods to return eventual protocols adopted by the 
   represented protcol */
- (NSArray *) protocolNames
{	
	//return [[self protocols] valueForKey: @"name"];
	return nil;
}

- (NSArray *) protocols
{
	/*Class pClass = [_protocol class];
	struct objc_protocol_list pIterator = pClass->objc_protocols;
	NSMutableArray *protocols = [NSMutableArray array];
	
	do 
	{
		Protocol *p = (Protocol *)pIterator->List;
		ETProtocol *protocol = [[ETProtocol alloc] init];
		
		protocol->_protocol = p;
		[protocols addObject: protocol];
		RELEASE(protocol)
		pIterator = pIterator->next;
		
	} while (pInterator->next != NULL)

	return AUTORELEASE(protocols);*/
	return nil;
}

@end

@implementation ETClass
+ (NSArray *) protocolsForClass: (Class)aClass
{
#if defined(GNU_RUNTIME)
	if (aClass == Nil)
	{
		return nil;
	}
	NSMutableArray *protocols = [NSMutableArray array];

	for (struct objc_protocol_list* iter = aClass->protocols; iter != NULL; iter = iter->next)
	{
		for (size_t i = 0; i < iter->count; i++)
		{
			Protocol *protocol = iter->list[i];
			[protocols addObject: protocol];
		}
	}
	return protocols;
#else
#warning +protocolsForClass not supported on your ObjC runtime.
	return nil;
#endif
}
@end
