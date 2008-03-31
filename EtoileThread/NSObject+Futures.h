#import <Foundation/Foundation.h>

/**
 * The Futures category adds a method to NSObject
 * for determining whether an object is a future.
 */
@interface NSObject (Futures)
/**
 * Returns YES if the caller is a future, no otherwise.
 */
- (BOOL) isFuture;
@end
