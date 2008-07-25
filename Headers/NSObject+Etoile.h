/*
	NSObject+etoile.h
	
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

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

/* Runtime Checks */
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5
#define NEXT_RUNTIME_2
#endif
#ifndef NEXT_RUNTIME_2
#define GNUSTEP_RUNTIME_COMPATIBILITY
#endif
#ifdef GNUSTEP_RUNTIME_COMPATIBILITY
#import <GNUstepBase/GSObjCRuntime.h>
#endif

#define ETUTI NSString

@class ETMethod;

/** Protocol which can be adopted by other object hierachy than NSObject rooted hierarchy */
@protocol ETInspectableObject

@end

/** Utility metamodel for GNUstep/Cocoa Objective-C */

@interface NSObject (Etoile) //<ETInspectableObject>

- (id) clone;
- (BOOL) isPrototype;

/** Returns a object representing the receiver. Useful when sucblasses override
    root class methods and make them unavailable to introspection. For example,
	ETProtocol represents a protocol but overrides methods like -type, typeName
	-name, -protocols and -protocolNames of NSObject, thereby you can know the 
	properties of the represented protocol, but you cannot access the 
	identically named properties which describes ETProtocol instance itself. */
- (id) metaObject;

- (ETUTI *) type;
- (NSString *) typeName;
+ (NSString *) typePrefix;

/** Returns both methods and instance variables for the receiver by default */
/*- (NSArray *) slotNames;
- (id) valueForSlot: (NSString *)slot;
- (void) setValue: (id)value forSlot: (NSString *)slot;*/
- (id) valueForInstanceVariable: (NSString *)ivar;
- (void) setValue: (id)value forInstanceVariable: (NSString *)ivar;
- (ETMethod *) methodForName: (NSString *)name;
- (void) setMethod: (id)value forName: (NSString *)namme;

- (NSArray *) instanceVariables;
- (NSArray *) instanceVariableNames;
- (NSDictionary *) instancesVariableValues;
- (NSDictionary *) instancesVariableTypes;
- (id) typeForInstanceVariable: (NSString *)ivar;

- (NSArray *) protocolNames;
//- (NSArray *) protocols;

- (NSArray *) methods;
- (NSArray *) methodNames;
/*- (NSArray *) instanceMethods;
- (NSArray *) instanceMethodNames;
- (NSArray *) classMethods;
- (NSArray *) classMethodNames;

- (void) addMethod: (ETMethod *)method;
- (void) removeMethod: (ETMethod *)method;*/
/** Method swizzling */
/*- (void) replaceMethod: (ETMethod *)method byMethod: (ETMethod *)method;*/

/** Low level methods used to implement method list edition */
/*- (void) bindMethod: (ETMethod *) toSelector: (SEL)selector;
- (void) bindSelector: (SEL) toMethod: (ETMethod *)method;*/

@end

@interface ETInstanceVariable : NSObject 
{
	@public
	id _possessor;
#ifdef GNUSTEP_RUNTIME_COMPATIBILITY
	GSIVar _ivar;
#endif
}

- (id) possessor;

- (NSString *) name;
// FIXME: Replace by ETUTI class later
- (ETUTI *) type;
- (NSString *) typeName;
- (id) value;
/** Pass NSValue to set primitive types */
- (void) setValue: (id)value;

@end

@interface ETMethod : NSObject 
{
	@public
#ifdef GNUSTEP_RUNTIME_COMPATIBILITY
	GSMethod _method;
#endif
}

/*- (BOOL) isInstanceMethod;
- (BOOL) isClassMethod;*/

- (NSString *) name;
- (SEL) selector;
- (NSMethodSignature *) methodSignature;

@end

/** A Protocol counterpart for Foundation and NSObject root class */
@interface ETProtocol : NSObject 
{
	@public
	Protocol *_protocol;
}

+ (Protocol *) protocolForName: (NSString *)name;

- (NSString *) name;
- (ETUTI *) type;
- (NSString *) typeName;

/* Overriden NSObject methods to return eventual protocols adopted by the 
   represented protcol */
- (NSArray *) protocolNames;
- (NSArray *) protocols;

@end
