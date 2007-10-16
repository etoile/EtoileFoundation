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
- (id) clone;
@end

/**
 * Basic implementation of prototypes in Objective-C
 */
@interface ETPrototype : NSObject<ETPrototype> {
	BOOL isPrototype;
	NSMapTable * dtable;
	NSMapTable * otherIvars;
}
@end

#define DEFMETHOD(name, ...) id name(id self, SEL cmd, ## __VA_ARGS__)
