#import <Foundation/NSObject.h>
#include <pthread.h>
/**
 * The ETObjectPipe class encapsulates a connection between two filters. 
 *
 * Conceptually, the pipe provides an asynchronous request-response mechanism
 * between two threads.  The pipe is partially thread-safe.  Each end must only
 * be held by one thread, unless protected externally by a lock.  One end sends
 * requests and receives replies, the other receives requests and sends
 * replies.
 *
 * Every request must have corresponding reply sent, although this may be nil.
 * The intended use for this is to allow a small set of buffers to be recycled
 * between a cooperating pair of filters.  
 */
@interface ETObjectPipe : NSObject {
	/** The ring buffer. */
	id *queue;
	/** Producer free-running counter. */
	uint32_t requestProducer;
	uint32_t requestConsumer;
	/** Consumer free-running counter. */
	uint32_t replyProducer;
	uint32_t replyConsumer;
	/** 
	 * Condition variable used to signal a transition from locked to lockless
	 * mode.
	 */
	pthread_cond_t conditionVariable;
	/** Mutex used to protect the condition variable. */
	pthread_mutex_t mutex;
	/** Flag used to interrupt the object in locked mode */
	volatile BOOL disconnect;
}
/**
 * Insert anObject into the ring buffer as a request.
 */
- (void)sendRequest: (id)anObject;
/**
 * Retrieve the next request from the ring buffer.
 */
- (id)nextRequest;
/**
 * Insert a reply into the ring buffer.
 */
- (void)sendReply: (id)anObject;
/**
 * Retrieve the next reply from the buffer.
 */
- (id)nextReply;
@end
