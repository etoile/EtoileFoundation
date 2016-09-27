/**
    Copyright (C) 2007 Quentin Mathe
 
    Date:  September 2007
    License: Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>

/** 
 * @group Collection Additions
 * @abstract Additions to NSDictionary. 
 */
@interface NSDictionary (Etoile)
/** 
 * Returns whether the dictionary contains the given key among -allKeys. 
 */
- (BOOL) containsKey: (id <NSCopying>)aKey;
/**
 * Returns an immutable dictionary that contains the entries of the given 
 * dictionary merged with the receiver entries.
 *
 * If both dictionaries contains the same key, the value from the dictionary
 * argument prevails.
 */
- (NSDictionary *)dictionaryByAddingEntriesFromDictionary: (NSDictionary *)aDict;
/**
 * Returns an immutable dictionary that contains the subset of the receiver
 * entries corresponding to the given keys.
 *
 * If the given keys are not a subset of the receiver keys, raises a 
 * NSInvalidArgumentException.
 *
 * This method is not the same than -[NSObject dictionaryWithValuesForKeys:] 
 * which requires keys to be NSString objects (at least on Mac OS X 10.10).
 */
- (NSDictionary *)subdictionaryForKeys: (NSArray *)keys;
@end

#ifdef GNUSTEP
/**
 * @group Collection Additions
 * @abstract Extension to NSMutableDictionary for a common case where each key 
 * may map to several values.
 */
@interface NSMutableDictionary (Etoile)
/**
 * Adds an object for the specific key.  If there is no value for this key, it
 * is added.  If there is an existing value and it is a mutable array, then
 * the object is added to the array.  If it is not a mutable array, the
 * existing object and the new object are both added to a new array, which is
 * set for this key in the dictionary.
 */
- (void)addObject: anObject forKey: aKey;
@end
#endif
