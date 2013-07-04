/*
 *  Macros.h
 *
 *  Created by David Chisnall on 02/08/2005.
 *
 */

#import <Foundation/NSAutoreleasePool.h>
#import <EtoileFoundation/EtoileCompatibility.h>

/**
 * Simple macro for safely initialising the superclass.
 */
#define SUPERINIT if((self = [super init]) == nil) {return nil;}
/**
 * Deprecated. You should use the designated initializer rule.
 * 
 * Simple macro for safely initialising the current class.
 */
#define SELFINIT if((self = [self init]) == nil) {return nil;}
/**
 * Macro for creating dealloc methods.
 */
#define DEALLOC(x) - (void) dealloc { x ; [super dealloc]; }

@protocol MakeReleaseSelectorNotFoundErrorGoAway
- (void) release;
@end

/**
 * Cleanup function used for stack-scoped objects.
 */
#if !__has_feature(objc_arc)
__attribute__((unused)) static inline void ETStackAutoRelease(void* object)
{
	[*(id*)object release];
}
#endif
/**
 * Macro used to declare objects with lexical scoping.  The object will be sent
 * a release message when it goes out of scope.  
 *
 * Example:
 *
 * <example>
 * STACK_SCOPED Foo * foo = [[Foo alloc] init];
 * </example>
 */
#if defined(__OBJC_GC__)  || __has_feature(objc_arc)
#	define STACK_SCOPED
#else
#	define STACK_SCOPED __attribute__((cleanup(ETStackAutoRelease))) \
		__attribute__((unused))
#endif

@interface NSLocking
- (void)lock;
- (void)unlock;
@end

/**
 * Cleanup function that releases a lock.
 */
__attribute__((unused)) static inline void ETUnlockObject(void* object)
{
	[*(__unsafe_unretained id*)object unlock];
}
/**
 * Macro that sends a -lock message to the argument immediately, and then an
 * -unlock message when the variable goes out of scope (including if an
 *  exception causes this stack frame to be unwound).
 */
#define LOCK_FOR_SCOPE(x) __attribute__((cleanup(ETUnlockObject))) \
		__attribute__((unused)) id __COUNTER__ ## _lock = x; [x lock]

#if !__has_feature(objc_arc)
/**
 * Cleanup function that releases a lock.
 */
__attribute__((unused)) static inline void ETDrainAutoreleasePool(void* object)
{
	[*(NSAutoreleasePool**)object drain];
}

/**
 * Create a temporary autorelease pool that is destroyed when the scope exits.
 */
#define LOCAL_AUTORELEASE_POOL() \
	__attribute__((cleanup(ETDrainAutoreleasePool))) \
	NSAutoreleasePool *__COUNTER__ ## _pool = [NSAutoreleasePool new];

#endif

/**
 * Macro providing a foreach statement on collections, with IMP caching.
 *
 * You should rather use FOREACH that provides basic typechecking.
 */
#define FOREACHI(collection,object) FOREACH(collection,object,id)

#ifdef __clang__
/**
 * Macro providing a foreach statement on collections, with IMP caching.
 *
 * @param type An element type such as 'NSString *' to typecheck the messages 
 * sent to the elements in the code block.
 */
#	define FOREACH(collection,object,type) for (type object in [collection objectEnumerator])
#else
#	define FOREACH(collection,object,type) FOREACH_WITH_ENUMERATOR_NAME(collection,object,type,object ## enumerator)
#endif

#define FOREACH_WITH_ENUMERATOR_NAME(collection,object,type,enumerator)\
NSEnumerator * enumerator = [collection objectEnumerator];\
FOREACHE(collection,object,type,enumerator)

#ifdef __clang__
/**
 * Macro providing a foreach statement on collections, with IMP caching.
 *
 * @param collection Can be nil, this argument is ignored.
 * @param type An element type such as 'NSString *' to typecheck the messages 
 * sent to the elements in the code block.
 * @param enumerator A custom enumerator object to use to iterate over the 
 * collection.
 */
#	define FOREACHE(collection,object,type,enumerator)\
	for (type object in enumerator)
#else
#	define FOREACHE(collection,object,type,enumerator)\
type object;\
IMP next ## object ## in ## enumerator = \
[enumerator methodForSelector:@selector(nextObject)];\
while(enumerator != nil && (object = next ## object ## in ## enumerator(\
												   enumerator,\
												   @selector(nextObject))))
#endif

/** Shortcut macro to create a NSDictionary. Same as +[NSDictionary dictionaryWithObjectsAndKeys:]. */
#define D(...) ({ \
    id __objects_and_keys[] = {__VA_ARGS__}; \
    size_t __objects_and_keys_count = sizeof(__objects_and_keys) / sizeof(id); \
    if ((__objects_and_keys_count % 2) != 0) \
    { \
	    [NSException raise: NSInvalidArgumentException \
					format: @"D() macro expects an even number of arguments!"]; \
    } \
    size_t __objects_count = __objects_and_keys_count / 2; \
    id __objects[__objects_count]; \
    id __keys[__objects_count]; \
    size_t __objects_iterator; \
    for (__objects_iterator = 0; __objects_iterator < __objects_count; __objects_iterator++) \
    { \
        __objects[__objects_iterator] = __objects_and_keys[2 * __objects_iterator]; \
        __keys[__objects_iterator] = __objects_and_keys[(2 * __objects_iterator) + 1]; \
    } \
    [NSDictionary dictionaryWithObjects: __objects forKeys: __keys count: __objects_count]; \
})
/** Shortcut macro to create a NSArray. Same as +[NSArray dictionaryWithObjects:]. */
#define A(...) ({ \
    id __objects[] = {__VA_ARGS__}; \
    [NSArray arrayWithObjects: __objects \
						count: (sizeof(__objects)/sizeof(id))]; \
})
/** Shortcut macro to create a NSSet. Same as +[NSSet setWithObjects:]. */
#define S(...) ({ \
    id __objects[] = {__VA_ARGS__}; \
    [NSSet setWithObjects: __objects \
					count: (sizeof(__objects)/sizeof(id))]; \
})
/** Shortcut macro to create a NSIndexSet. */
#define INDEXSET(...) ({ \
	NSMutableIndexSet *__result = [NSMutableIndexSet indexSet]; \
	const NSUInteger __indices[] = {__VA_ARGS__}; \
    const size_t __indices_count = sizeof(__indices) / sizeof(NSUInteger); \
	size_t __indices_iterator; \
	for (__indices_iterator = 0; __indices_iterator < __indices_count; __indices_iterator++) \
	{ \
		[__result addIndex: __indices[__indices_iterator]]; \
	} \
	[[[NSIndexSet alloc] initWithIndexSet: __result] autorelease]; \
})

#ifdef DEFINE_STRINGS
#define EMIT_STRING(x) NSString *x = @"" # x;
#endif
#ifndef EMIT_STRING
#define EMIT_STRING(x) extern NSString *x;
#endif

/** Basic assertion macro that just reports the tested condition when it fails.
It is similar to NSParameterAssert but not limited to checking the arguments. */
#define ETAssert(condition)	\
	NSAssert1(condition, @"Failed to satisfy %s", #condition)
/** Same as ETAssert except it gets executed only if you define  
ETDebugAssertionEnabled.

This macro can be used to do more expansive checks that cannot be kept turned 
on in a release version. */
#ifdef ETDebugAssertionEnabled
#define ETDebugAssert(condition) \
	ETAssert(condition)
#else
#define ETDebugAssert(condition) __builtin_unreachable()
#endif
/** Assertion macro to mark code portion that should never be reached. e.g. the 
default case in a switch statement. */
#define ETAssertUnreachable() \
	NSAssert(NO, @"Entered code portion which should never be reached")

/** Exception macro to check whether the given argument respects a condition.<br />
When the condition evaluates to NO, an NSInvalidArgumentException is raised. */
#define INVALIDARG_EXCEPTION_TEST(arg, condition) do { \
	if (NO == (condition)) \
	{ \
		[NSException raise: NSInvalidArgumentException format: @"For %@, %s " \
			"must respect %s", NSStringFromSelector(_cmd), #arg , #condition]; \
	} \
} while (0);
/** Exception macro to check the given argument is not nil, otherwise an 
NSInvalidArgumentException is raised. */
#define NILARG_EXCEPTION_TEST(arg) do { \
	if (nil == arg) \
	{ \
		[NSException raise: NSInvalidArgumentException format: @"For %@, " \
			"%s must not be nil", NSStringFromSelector(_cmd), #arg]; \
	} \
} while(0);
