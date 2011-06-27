/**
	<abstract>Objective-C Trait</abstract>

	Copyright (C) 2007 David Chisnall

	Author:  David Chisnall,
	         Quentin Mathe <quentin.mathe@gmail.com>
	Date:  October 2007
	License:  Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#import <EtoileFoundation/Macros.h>

/** @group Language Extensions

Adds traits to Objective-C, to support class composition, in addition to 
inheritance. Traits allow methods to be added to another class.

The trait support in EtoileFoundation is based on:

<list> 
<item>http://scg.unibe.ch/archive/papers/Scha03aTraits.pdf (original and short one)</item>
<item>http://scg.unibe.ch/archive/papers/Duca06bTOPLASTraits.pdf (most recent and quite lengthy)</item>
</list>

To get an introduction to the trait model and its various rules, you should 
read the short paper listed above.

@section Objective-C Trait Overview and Restrictions

The trait API supports both trait operators (exclusion, aliasing) and composite 
trait (a trait with subtraits). However there are two important restrictions:

<list>
<item>the super keyword must not be used in a trait method</item>
<item>instances variables must not be accessed directly but only through accessors</item>
</list>

If these restrictions are ignored, the code may compile, but will surely result 
in a buggy behavior at runtime.

With the current implementation, the limitations below should be kept in mind:

<list>
<item>trait applications don't take in account class methods</item>
<item>no mechanism to declare and check non-trait methods required by trait 
methods (so you get a runtime exception instead)</item>
</list>

@section Basic example and Terminology

To apply a trait, the basic API is +applyTraitFromClass:, and we use the 
terminology below:

<deflist>
<term>trait class</term><desc>the class which represents a trait and whose 
methods are called trait methods. The superclass methods are ignored if the 
class is used as a trait</desc>
<term>target class</term><desc>the class to which a trait class is applied to</desc>
<term>trait application</term><desc>a trait use that involves a trait class, a target 
class and operator-related arguments</desc>
</deflist>

For example:

<example>
// Traits should be applied as early as possible usually, that's why we use +initialize
+ (void) initialize
{
	if (self != [MyClass class])
		return;

	[aTargetClass applyTraitFromClass: aTraitClass];
}
</example>

@section Detailed Examples

Here is a more complex example that applies two subtraits (BasicTrait and 
ComplexTrait) to another trait (CompositeTrait), then the resulting is applied 
to the target class (the receiver's class).

<example>
	// -wanderWhere: from Basic method will be renamed -lost: in CompositeTrait
	[[CompositeTrait class] applyTraitFromClass: [BasicTrait class]
	                        excludedMethodNames: S(@"isOrdered")
	                         aliasedMethodNames: D(@"lost:", @"wanderWhere:")];

	[[CompositeTrait class] applyTraitFromClass: [ComplexTrait class]];

	[[self class] applyTraitFromClass: [CompositeTrait class]];
</example>

As a concrete example, collection protocols are now implemented by most classes 
in Étoilé frameworks through two new ETCollectionTrait and ETMutableCollectionTrait.

@section Trait Validation

Trait applications are memorized to support composite traits and multiple trait 
applications to the same target class. Each time a trait is applied, it gets 
validated against the trait tree already bound to the target class. This ensures 
operators, overriding rule and flattening property will remain valid in the new 
trait tree. Unlike Squeak trait support, a trait can be applied at any time. 

@section Mixin-style Application

In addition, it's possible to apply a trait without the overriding rule (that 
states target class overrides trait methods), which means methods in the target 
class can be replaced by methods from a trait.

<example>
	// With YES, we allow the trait to override/replace methods in the target class
	[[self class] applyTraitFromClass: [BasicTrait class]
	              excludedMethodNames: S(@"isOrdered")
	               aliasedMethodNames: D(@"lost:", @"wanderWhere:")
	                   allowsOverride: YES];
</example>

Trait applications are commutative, so the ordering in which you apply traits 
doesn't matter… but when this mixin-style composition is used, traits are not 
commutative and the ordering matters. That's why we'd rather discourage its use. */
@interface NSObject (Trait)
/**
 * Apply aClass to this class as a trait.
 *
 * Raises exceptions if the trait application cannot be validated.
 */
+ (void) applyTraitFromClass:(Class)aClass;
/**
 * Apply aClass to this class as a trait, without the trait methods listed 
 * in excludedNames, and by renaming the trait methods with the name values 
 * provided in the aliasedNames dictionary (where keys should be the existing 
 * trait method names).
 *
 * Raises exceptions if the trait application cannot be validated.
 */
+ (void) applyTraitFromClass: (Class)aClass 
         excludedMethodNames: (NSSet *)excludedNames
          aliasedMethodNames: (NSDictionary *)aliasedNames;
/** 
 * Does the same than +applyTraitFromClass:excludedMethodNames:aliasedMethodNames: 
 * but allows to replace methods in the target class with trait methods if YES 
 * is passed as the last argument. 
 *
 * By default, the trait overriding rule states that trait methods cannot 
 * replace methods that belongs to the target class, but only hide methods 
 * declared in superclasses and inherited by the target class.
 *
 * If YES is passed and there are other traits applied to the target class, 
 * the ordering use to apply traits cannot be ignored anymore.
 *
 * Raises exceptions if the trait application cannot be validated.
 */
+ (void) applyTraitFromClass: (Class)aClass 
         excludedMethodNames: (NSSet *)excludedNames
          aliasedMethodNames: (NSDictionary *)aliasedNames
              allowsOverride: (BOOL)override;
@end

/** Exception thrown by NSObject(Trait). */
EMIT_STRING(ETTraitInvalidSizeException)
/** Exception thrown by NSObject(Trait). */
EMIT_STRING(ETTraitIVarTypeMismatchException)
/** Exception thrown by NSObject(Trait). */
EMIT_STRING(ETTraitMethodTypeMismatchException)
/** Exception thrown by NSObject(Trait). */
EMIT_STRING(ETTraitApplicationException)
