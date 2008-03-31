#import <Foundation/Foundation.h>

/**
 * The Threaded category adds methods to NSObject
 * for creating object graphs in another thread.
 */
@interface NSObject (Threaded)
/**
 * Create an instance of the object in a new thread
 * with an associated run loop.
 */
+ (id) threadedNew;
/**
 * Returns a trampoline object that can be used to 
 * execute a method on the called object in a new thread.
 */
- (id) inNewThread;
@end
