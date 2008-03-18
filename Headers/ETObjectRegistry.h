/*
	ETObjectRegistry.h
	
	Cascading Object Registry which allows to compute objects state and 
	behavior in a late bound way
 
	Copyright (C) 2007 Quentin Mathe
 
	Author:  Quentin Mathe <qmathe@club-internet.fr>
	Date:  September 2007
 
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
#import <EtoileFoundation/ETPropertyValueCoding.h>
#import <EtoileFoundation/ETCollection.h>

// TODO: Break this class in ETObject root class and ETObjectRegistry subclass
// to allow reusing the prototype-system support.
// May be this class would be better named ETAspectRegistry?

@protocol ETPrototype
/** Returns a clone object of the receiver. The receiver plays the role of
	prototype for the new instance. 
	Instance clones are mutable by default unlike instance copies. */
- (id) cloneWithZone: (NSZone *)zone;
- (void) setPrototype: (id)parent;
- (id) prototype;
@end

/** ETObjectRegistry class provides a prototype-system which allows to infer
	both state and behaviors of Etoile objects based on other objects. State
	and behaviors inference only happens per request.
	
	ETObjectRegistry provides an interface to the Cascading Object Registries 
	concept. Every object aspects which needs to be kept automatically in sync 
	with other objects can be put in an object registry. The object registries
	are by nature organized in a tree structure which allows to look up for an
	aspect in a more broad registry when the local registry bound the object
	cannot provide a value directly. This mechanism is very close to CSS 
	(Cascading Style Sheets) resolution and overriding rules, that's why 
	ETObjectRegistry instances create Cascading Object Registries or Object
	Registry Tree.
	
	Each lookup in the Object Registry Tree can result in a lookup chain 
	moving up through towards the root registry.
	
	To bind an object to an object registry...
	[myCircle setObjectRegistry: polygonRegistry]
	
	To bind only a special kind of object registry...
	[[myCircle objectRegistry] setStyleRegistry: [polygonRegistry styleRegistry]]
	
	Typical uses of this class includes styles, layouts, filters, object 
	palettes etc. Further uses could be developed like system shared resources,
	constraint-based computations, item animations and anything which rely 
	heavily on external state or behaviors to be shared with other objects.
	
	The current implementation is self-sufficient, but in future the underlying
	mechanism will surely use CoreObject when it is available on the host system.
	
	This class is heavily used in EtoileUI framework. */
@interface ETObjectRegistry : NSObject <ETPropertyValueCoding, ETPrototype, ETCollection>
{
	ETObjectRegistry *_parent;
	NSMutableDictionary *_properties;
	Class _propertyClass;
}

+ (id) rootRegistry;

- (id) initWithRegistry: (ETObjectRegistry *)registry;
- (ETObjectRegistry *) parentRegistry;
- (void) setParentRegistry: (ETObjectRegistry *)registry;
- (id) clone;

/* Registry Tracking */

- (BOOL) isRegistryGroup;
- (id) registryForKey: (NSString *)property propertyClass: (Class)class;

/* Runtime Type Checking */

- (Class) propertyClass;
- (void) setPropertyClass: (Class)class;

/* Property Value Coding */

- (NSArray *) properties;
- (id) valueForProperty: (NSString *)key;
- (BOOL) setValue: (id)value forProperty: (NSString *)key;

- (NSArray *) parentProperties;
- (NSArray *) allProperties;

/* Collection Protocol */

- (BOOL) isOrdered;
- (BOOL) isEmpty;
- (id) content;
- (NSArray *) contentArray;

@end
