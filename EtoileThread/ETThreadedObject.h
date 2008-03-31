#import <Foundation/Foundation.h>
#import "ETThread.h"
#include <pthread.h>

#define QUEUE_SIZE 256
#define QUEUE_MASK 0xff

/**
 * The ETThreadedObject class represents an object which has its
 * own thread and run loop.  Messages that return either an object
 * or void will, when sent to this object, return asynchronously.
 *
 * For methods returning an object, an [ETThreadProxyReturn] will
 * be returned immediately.  Messages passed to this object will
 * block until the real return value is ready.
 *
 * In general, methods in this class should not be called directly.
 * Instead, the [NSObject(Threaded)+threadedNew] method should be 
 * used.
 */
@interface ETThreadedObject : NSProxy{
	/**
	 * Proxied object.
	 */
	id object;
	/** 
	 * The condition variable and mutex are only used when the queue is empty.
	 * If the message queue is kept fed then the class moves to a lockless
	 * model for communication.
	 */
	pthread_cond_t conditionVariable;
	pthread_mutex_t mutex;
	/**
	 * Lockless ring buffer and free-running counters.
	 */
	id invocations[QUEUE_SIZE];
	unsigned long producer;
	unsigned long consumer;
	id proxy;
	BOOL terminate;
	ETThread * thread;
}
/**
 * Create a threaded instance of aClass
 */
- (id) initWithClass:(Class) aClass;
/**
 * Create a thread and run loop for anObject
 */
- (id) initWithObject:(id) anObject;
/**
 * Method encapsulating the run loop.  Should not be called directly
 */
- (void) runloop:(id)sender;
@end
