#import <Foundation/NSObject.h>

/** @group Language Extensions */
@interface NSObject (Prototypes)
/**
 * Adds the specified method to this instance.  Objects modified in this way get
 * a hidden dictionary for non-indexed instance variables, allowing them to use
 * KVC to set arbitrary objects on self.
 */
- (void) setMethod:(IMP)aMethod forSelector:(SEL)aSelector;
/**
 * Returns a clone of the object.  The clone will inherit all methods and
 * associated objects.  To copy instance variables, you must override this
 * method.
 */
- (id) clone;
/**
 * Returns YES if this object inherits from another object.
 */
- (BOOL) isPrototype;
/**
 * Returns the prototype for this object, or nil if this object does not have
 * one.
 */
- (id) prototype;
/**
 * Does the same as valueForKey:, except when this object is a prototype and
 * a block closure is associated with the supplied key. The block closure is
 * then returned without being invoked.
 */
- (id) slotValueForKey:(NSString *)aKey;
@end
