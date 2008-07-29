#import <Foundation/Foundation.h>

/**
 * Not actually needed, but it gets rid of a warning when we call -foo since it
 * is not ever used as a method.
 */
@protocol foo
- (void) foo;
@end 

@protocol ETPrototype
/**
 * Adds the specified method to this instance.
 */
- (void) setMethod:(IMP)aMethod forSelector:(SEL)aSelector;
/** 
  * Returns a clone object of the receiver. The receiver plays the role of
  * prototype for the new instance. 
  * Instance clones are mutable by default unlike instance copies. 
  */
- (id) cloneWithZone: (NSZone *)zone;
- (id) prototype;
- (void) setPrototype: (id)proto;
@end

#ifdef CUSTOM_RUNTIME

/**
 * Basic implementation of prototypes in Objective-C
 */
@interface ETPrototype : NSObject<ETPrototype> {
	id prototype;
	BOOL isPrototype;
	NSMapTable * dtable;
	NSMapTable * otherIvars;
}
@end

#define DEFMETHOD(name, ...) id name(id self, SEL cmd, ## __VA_ARGS__)

#endif
