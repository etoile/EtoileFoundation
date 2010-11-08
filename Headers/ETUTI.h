/*
        ETUTI.h
        
        Copyright (C) 2009 Eric Wasylishen
 
        Author:  Eric Wasylishen <ewasylishen@gmail.com>
        Date:  January 2009
 
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

/**
 * ETUTI objects represent Uniform Type Identifiers (UTIs), strings written
 * in reverse-DNS notation (e.g. "org.etoile.group") which are used to
 * describe data type. UTIs support multiple inheritance to indicate that 
 * certain types are refinements of one or more parent types.
 *
 * The ETUTI implementation also integrates with the Objective-C runtime.
 * UTI's can be automatically generated for a given class,
 * which are given the form "org.etoile-project.objc.class.ClassName".
 *
 * EtoileFoundation provides a built-in UTI library and some class bindings 
 * (UTI supertypes to which ObjC classes conforms to). See UTIDefinitions.plist
 * and ClassBindings.plist in the EtoileFoundation framework resources.
 *
 * Additional UTIs and class bindings can be provided in third-party 
 * applications. At launch time, ETUTI loads any UTIDefinitions.plist and 
 * ClassBindings.plist present in the main bundle and merges the content into 
 * its runtime UTI database. You cannot redefine a UTI built into 
 * EtoileFoundation UTIDefinitions.plist.
 */
@interface ETUTI : NSObject <NSCopying>
{
	@private	
	NSString *string;
	NSString *description;
	NSArray *supertypes;	// array of ETUTUI instances
	NSDictionary *typeTags;
}
/**
 * Returns an ETUTI object for the given UTI string (e.g. "public.audio").
 * The given UTI string must either:
 * <list>
 *     <item>be in the UTIDefinitions.plist file</item>
 *     <item>or have been registered with the 
 *           registertypeWithString:description:supertypes: method</item>
 *     <item>or be a UTI of the form "org.etoile-project.objc.class.ClassName" 
 *           where ClassName is a valid Objective-C class</item>
 * </list>
 * Otherwise, nil is returned.
 */
+ (ETUTI *) typeWithString: (NSString *)aString;
/**
 * Returns an ETUTI object representing the type of the file located at the
 * specified local path.
 */
+ (ETUTI *) typeWithPath: (NSString *)aPath;
+ (ETUTI *) typeWithFileExtension: (NSString *)anExtension;
+ (ETUTI *) typeWithMIMEType: (NSString *)aMIME;
/**
 * Returns an ETUTI object representing the given class. Calling
 * -supertypes will return a UTI representing the superclass of the class,
 * in addition to any supertypes specified for the class in
 * UTIDefinitions.plist.
 *
 * Note that it is not necessary to list
 * Objective-C classes in UTIDefinitons.plist; ETUTI objects 
 * for ObjC classes are created dynamically, but UTIDefinitions.plist
 * can be used to add supplemental supertypes.
  */
+ (ETUTI *) typeWithClass: (Class)aClass;
/**
 * Registers a UTI in the UTI database. UTIs registered with this method
 * are not currently persisted.
 *
 * A type tag dictionary can be passed to express how the UTI is mapped to 
 * other type identification models. EUTI currently supports two other type  
 * identification models: file extensions and MIME types. All MIME types and 
 * file extensions belongs to two tag classes (encoded as UTI), respectively 
 * kETUTITagClassMIMEType and kETUTITagClassFileExtension. Finally each entry 
 * in a type tag dictionary must be an array. Here is an example of a valid 
 * type tag dictionary:
 *
 * <example>
 * [NSDictionary dictionaryWithObjectsAndKeys: 
 * 	[NSArray arrayWithObject: @"image/tiff"], kETUTITagClassMIMEType,
 * 	[NSArray arrayWithObjects: @"tif", @"tiff", nil], kETUTITagClassFileExtension, nil]
 * </example>
 *
 * See also -fileExtensions and -MIMETypes.
 */
+ (ETUTI *) registerTypeWithString: (NSString *)aString
                       description: (NSString *)description
                  supertypeStrings: (NSArray *)supertypeNames
                          typeTags: (NSDictionary *)tags;
/**
 * Returns a "transient" or anonymous ETUTI object based on the given UTI 
 * string representations as supertypes.
 *
 * Useful in combination with conformsToUTI: for checking whether an unknown
 * UTI conforms to any UTI in a set (the supertypes specified for the 
 * transient UTI.)
 */
+ (ETUTI *) transientTypeWithSupertypeStrings: (NSArray *)supertypeNames;
/**
 * Returns a "transient" or anonymous ETUTI object based on the given UTI 
 * objects as supertypes.
 *
 * See also +transientTypeWithSupertypeStrings:
 */
+ (ETUTI *) transientTypeWithSupertypes: (NSArray *)supertypes;

/**
 * Returns the string representation of the UTI (e.g. "public.audio")
 */
- (NSString *) stringValue;
/** 
 * Returns the ObjC class the UTI represents, or Nil if the UTI does not 
 * represent a class registered in the runtime.
 *
 * See also +typeWithClass:.
 */
- (Class) classValue;
/**
 * Returns an array of file extensions (if any) which refer to the same
 * data type as the receiver.
 */
- (NSArray *) fileExtensions;
/**
 * Returns an array of MIME types which refer to the same data type as the 
 * receiver.
 */
- (NSArray *) MIMETypes;
/**
 * Returns a natural language description of the receiver.
 */
- (NSString *) typeDescription;
/**
 * Returns the UTI objects which are immediate supertypes of the receiver.
 */
- (NSArray *) supertypes;
/**
 * Returns all known UTI objects which are supertypes of the receiver (all UTIs 
 * which the receiver conforms to.)
 */
- (NSArray *) allSupertypes;
/**
 * Returns the UTI objects which have the receiver as an immediate supertype.
 */
- (NSArray *) subtypes;
/**
 * Returns all known UTI objects which conform to the receiver.
 */
- (NSArray *) allSubtypes;

/**
 * Tests whether or not the receiver conforms to aType (i.e. aType is a 
 * supertype of the receiver, possibly many levels away.)
 */
- (BOOL) conformsToType: (ETUTI *)aType;

@end


/** Key to identify the MIME type string array in a type tag dictionary. */
extern NSString * const kETUTITagClassMIMEType;
/** Key to identify the file extension array in a type tag dictionary. */
extern NSString * const kETUTITagClassFileExtension;
