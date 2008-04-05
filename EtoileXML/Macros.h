/*
 *  Macros.h
 *  Jabber
 *
 *  Created by David Chisnall on 02/08/2005.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#define SUPERINIT if((self = [super init]) == nil) {return nil;}
#define SELFINIT if((self = [self init]) == nil) {return nil;}

#define FOREACHI(collection,object) FOREACH(collection,object,id)

#define FOREACH(collection,object,type) FOREACHE(collection,object,type,object ## enumerator)
/*
#define FOREACHE(collection,object,type,enumerator)\
NSEnumerator * enumerator = [collection objectEnumerator];\
type object;\
while((object = [enumerator	nextObject]))
*/

#define AUTORELEASED(x) [[[x alloc] init] autorelease]
#define RETAINED(x) [[x alloc] init]

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
