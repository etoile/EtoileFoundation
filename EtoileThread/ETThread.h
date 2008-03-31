#import <Foundation/Foundation.h>
#include <pthread.h>

/**
 * The ETThread class provides a wrapper around basic POSIX threading 
 * functionality.  This extends NSThread by allowing a thread to wait
 * for another to terminate, and for an exit value to be returned.
 */
@interface ETThread : NSObject {
	pthread_t thread;
@public
	NSAutoreleasePool * pool;
}
/**
 * Similar to NSThread's method of the same name.  Creates a new thread and
 * invokes [aTarget aSelector:anArgument].  Unlike the NSThread implementation,
 * this creates an NSAutoreleasePool before performing the selector and then
 * frees it afterwards.  This method can thus be used on any side-effect-free
 * method, without modification.
 */
+ (id) detachNewThreadSelector:(SEL)aSelector toTarget:(id)aTarget withObject:(id)anArgument;
/**
 * Returns an ETThread representing the current thread.  The behaviour for this
 * method is undefined if called from a thread not created by an ETThread.
 */
+ (ETThread*) currentThread;
/**
 * Blocks execution in the caller until the thread exits.  If the method used 
 * to create the thread returns a value, or the thread is terminated with
 * -exitWithValue: then this method will give the returned value.
 */
- (id) waitForTermination;
/**
 * Returns YES if the receiver represents the callers thread, NO otherwise.
 */
- (BOOL) isCurrentThread;
/**
 * Causes immediate termination of the thread and returns the specified value.
 * This method can only be called from the thread represented by the receiver
 * and will silently fail otherwise.  
 */
- (void) exitWithValue:(id)aValue;
/**
 * Causes immediate termination of the receiver's thread.
 */
- (void) kill;
@end
