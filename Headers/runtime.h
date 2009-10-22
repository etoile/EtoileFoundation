/**
 * Includes the Objective-C 2.0 runtime library functions. On OS X this means
 * including objc/runtime.h, and for the (old) GNU runtime it means importing
 * runtime.h from the ObjectiveC2 compatability framework.
 *
 * FIXME: This ifdef will need to be changed to support David's new GNU runtime
 */

#ifndef GNUSTEP
#import <objc/runtime.h>
#else
#import <ObjectiveC2/runtime.h>
#endif
