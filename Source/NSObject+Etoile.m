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

#import <EtoileFoundation/NSObject+Etoile.h>
#import <EtoileFoundation/ETPrototype.h>
#import <EtoileFoundation/EtoileCompatibility.h>

@interface NSObject (PrivateEtoile)
- (ETInstanceVariable *) instanceVariableForName: (NSString *)ivarName;
@end


@implementation NSObject (Etoile) //<ETInspectableObject>

/** Returns a cloned instance of the receiver by calling -cloneWithZone: 
	declared by ETPrototype protocol. 
	If the receiver doesn't implement -cloneWithZone:, an exception is raised. */
- (id) clone
{
	return [(id)self cloneWithZone: NSDefaultMallocZone()];
}

/** Returns whether the receiver is a prototype object that conforms to 
	ETPrototype protocol.
	A prototype object can be cloned and can declare new methods unlike usual
	instances that returns NO. */
- (BOOL) isPrototype
{
	return ([self conformsToProtocol: @protocol(ETPrototype)]);
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
	
	return [self className];
}

/** Returns the type name which is the last component of type string returned 
	by the UTI object. This type name doesn't include the class prefix.
	This method is a shortcut for [[self type] typeName]. */
- (NSString *) typeName
{
	unsigned int prefixLength = [[[self class] typePrefix] length];
	
	return [[self type] substringFromIndex: prefixLength];
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
	
	#ifdef GNUSTEP_RUNTIME_COMPATIBILITY
	GSIVar ivar = GSObjCGetInstanceVariableDefinition([self class], ivarName);
	ASSIGN(ivarObject->_possessor, self);
	ivarObject->_ivar = ivar;
	#else
	
	#endif
	
	return AUTORELEASE(ivarObject);
}

- (NSArray *) instanceVariableNames
{
	#ifdef GNUSTEP_RUNTIME_COMPATIBILITY
	return GSObjCVariableNames(self);
	#else
	return nil;
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
	return nil;
}

#if 0
- (NSArray *) protocols
{
	NSMutableArray *protocols = [NSMutableArray array];
	NSEnumerator *e = [[self protocolNames] objectEnumerator];
	NSString *protocolName = nil;
	
	while ((protocolName = [e nextObject]) != nil)
	{
		[protocols addObject: [self protocolForName: protocolName]];
	}
	
	// FIXME: Return immutable array
	return protocols;
}
#endif

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
	#else
	
	#endif
		
	return [NSString stringWithCString: ivarName];
}

// FIXME: Replace by ETUTI class later
- (ETUTI *) type
{
	const char *ivarType = NULL;
	
	#ifdef GNUSTEP_RUNTIME_COMPATIBILITY
	ivarType = _ivar->ivar_type;
	#else
	
	#endif
		
	return [NSString stringWithCString: ivarType];
}

- (NSString *) typeName
{
	return [self type];
}

- (id) value
{
	id ivarValue = nil;
	
	#ifdef GNUSTEP_RUNTIME_COMPATIBILITY
	const char *ivarType = _ivar->ivar_type;
	int ivarOffset = _ivar->ivar_offset;
	
	// FIXME: More type support
	if(ivarType[0] == '@')
		GSObjCGetVariable([self possessor], ivarOffset, sizeof(id), (void **)&ivarValue);
	#else
	
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

- (NSString *) name
{
	return nil;
	//return [NSString stringWithCString: [_protocol name]];
}

- (ETUTI *) type
{
	return [self name];
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
