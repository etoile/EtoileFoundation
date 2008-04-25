/*
 *  Macros.h
 *
 *  Created by David Chisnall on 02/08/2005.
 *
 */

/**
 * Simple macro for safely initialising the superclass.
 */
#define SUPERINIT if((self = [super init]) == nil) {return nil;}
/**
 * Simple macro for safely initialising the current class.
 */
#define SELFINIT if((self = [self init]) == nil) {return nil;}
/**
 * Macro for creating dealloc methods.
 */
#define DEALLOC(x) - (void) dealloc { x ; [super dealloc]; }

/**
 * Cleanup function used for stack-scoped objects.
 */
static void ETStackAutoRelease(void* object)
{
	[*(id*)object release];
}
/**
 * Macro used to declare objects with lexical scoping.  The object will be sent
 * a release message when it goes out of scope.  
 *
 * Example:
 *
 * STACK Foo * foo = [[Foo alloc] init];
 */
#define STACK __attribute__((cleanup(ETStackAutoRelease))) 

/**
 * Set of macros providing a for each statement on collections, with IMP
 * caching.
 */
#define FOREACHI(collection,object) FOREACH(collection,object,id)

#define FOREACH(collection,object,type) FOREACHE(collection,object,type,object ## enumerator)

#define FOREACHE(collection,object,type,enumerator)\
NSEnumerator * enumerator = [collection objectEnumerator];\
type object;\
IMP next ## object ## in ## enumerator = \
[enumerator methodForSelector:@selector(nextObject)];\
while(enumerator != nil && (object = next ## object ## in ## enumerator(\
												   enumerator,\
												   @selector(nextObject))))

#define D(...) [NSDictionary dictionaryWithObjectsAndKeys:__VA_ARGS__ , nil]
#define A(...) [NSArray arrayWithObjects:__VA_ARGS__ , nil]
