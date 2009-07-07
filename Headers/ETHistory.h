/*
   ETHistory.h

   Copyright (C) 2008 Truls Becken <truls.becken@gmail.com>
 
   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in
   all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
   THE SOFTWARE.
*/

#import <Foundation/NSArray.h>
#import <Foundation/NSEnumerator.h>

/**
 * ETHistory keeps a history of objects of some kind. After going back
 * in time, it can go forward again towards the most recent object. Adding an
 * object while at a historic point will discard the forward history.
 *
 * It is also possible to give the manager an NSEnumerator to use as a lazy
 * source for the forward history. This way, a collection of objects can be
 * added as a "future", replacing the current forward history.
 */
@interface ETHistory : NSObject
{
	NSMutableArray *history;
	NSEnumerator *future;
	int max_size;
	int index;
}

/**
 * Return a new autoreleased history manager.
 */
+ (id) manager;
/**
 * Initialize the history manager.
 */
- (id) init;
/**
 * Set new current object, discarding the forward history.
 */
- (void) addObject: (id)object;
/**
 * Return the current object.
 */
- (id) currentObject;
/**
 * Go one step back if possible.
 */
- (void) back;
/**
 * Go back, and return the new current object or nil if already at the start.
 */
- (id) previousObject;
/**
 * Return YES if it is possible to go back.
 */
- (BOOL) hasPrevious;
/**
 * After going back, call this to go one step forward again.
 */
- (void) forward;
/**
 * Go forward, and return the new current object or nil if already at the end.
 */
- (id) nextObject;
/**
 * Return YES if it is possible to go forward.
 */
- (BOOL) hasNext;
/**
 * Return an object at a position relative to the current object. Return nil if
 * the index refers to a point before the beginning or after the end of time.
 */
- (id) peek: (int)relativeIndex;
/**
 * Forget the history and discard the future.
 */
- (void) clear;
/**
 * Set an enumerator to use as the forward history, discarding everything after
 * the current object.
 */
- (void) setFuture: (NSEnumerator *)enumerator;
/**
 * Set the maximum number of objects to remember. When more objects than this
 * are added, the oldest ones are forgotten.
 *
 * The default is to remember an unlimited number of objects (max size = 0).
 *
 * Note that max size only limits the number of objects before currentObject.
 * Setting a future and peeking into it may force the history manager to
 * temporarily hold more objects.
 */
- (void) setMaxHistorySize: (int)maxSize;
/**
 * Return the maximum number of objects to remember.
 */
- (int) maxHistorySize;
/**
 * Free resources held by the history manager.
 */
- (void) dealloc;

@end
