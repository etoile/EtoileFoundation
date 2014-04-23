/**
	Copyright (C) 2007 Quentin Mathe
 
	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  September 2007
	License: Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>

/** 
 * @group Collection Additions
 * @abstract Additions to NSDictionary. 
 */
@interface NSDictionary (Etoile)
- (BOOL) containsKey: (NSString *)aKey;
@end

/**
 * @group Collection Additions
 * @abstract Extension to NSMutableDictionary for a common case where each key 
 * may map to several values.
 */
@interface NSMutableDictionary (DictionaryOfLists)
/**
 * Adds an object for the specific key.  If there is no value for this key, it
 * is added.  If there is an existing value and it is a mutable array, then
 * the object is added to the array.  If it is not a mutable array, the
 * existing object and the new object are both added to a new array, which is
 * set for this key in the dictionary.
 */
- (void)addObject: anObject forKey: aKey;
@end
