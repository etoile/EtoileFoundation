/*
    Copyright (C) 2009 Niels Grewe

    Date:  June 2009
    License:  Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#import "ETCollection.h"
#import "ETCollection+HOM.h"
#import "NSInvocation+Etoile.h"
#import "NSObject+Etoile.h"
#import "Macros.h"
#import "runtime.h"
#import "EtoileCompatibility.h"

// Define the maximum number of arguments a function can take. (C99 allows up to
// 127 arguments.)
#define MAX_ARGS 127

typedef id (*Value1Function)(id, SEL, id);
typedef id (*Value2Function)(id, SEL, id, id);
typedef id (*ObjectAtIndexFunction)(id, SEL, NSUInteger);
typedef void (*MapPlaceObjectFunction)(id, SEL, id, id<ETCollectionMutation> *, id, NSUInteger, NSArray *, id);
typedef void (*FilterPlaceObjectFunction)(id, SEL, id, NSUInteger, id<ETCollectionMutation> *, BOOL, id);

/*
 * Private protocols to collate verbose, often used protocol-combinations.
 */
@protocol ETCollectionObject <NSObject, ETCollection>
@end

@protocol ETMutableCollectionObject <ETCollectionObject, ETCollectionMutation>
@end

/*
 * Make collection classes adopt those protocols
 */
@interface NSArray (ETHOMPrivate) <ETCollectionObject>
@end

@interface NSDictionary (ETHOMPrivate) <ETCollectionObject>
@end

@interface NSSet (ETHOMPrivate) <ETCollectionObject>
@end

@interface NSIndexSet (ETHOMPrivate) <ETCollectionObject>
@end

@interface NSMutableArray (ETHOMPrivate) <ETMutableCollectionObject>
@end

@interface NSMutableDictionary (ETHOMPrivate) <ETMutableCollectionObject>
@end

@interface NSMutableSet (ETHOMPrivate) <ETMutableCollectionObject>
@end

@interface NSMutableIndexSet (ETHOMPrivate) <ETMutableCollectionObject>
@end

/*
 * Informal protocol for turning collections into arrays.
 */
@interface NSObject (ETHOMArraysFromCollections)
- (NSArray*)collectionArray;
@end


/*
 * Informal protocol for the block invocation methods to invoke Smalltalk and C
 * blocks transparently.
 */
@interface NSObject(ETHOMInvokeBlocks)
- (id)value: (id)anArgument;
- (id)value: (id)anArgument value: (id)anotherArgument;
@end

/*
 * The ETEachProxy wraps collection objects for the HOM code to iterate over
 * their elements if the proxy is passed as an argument.
 */
@interface ETEachProxy : NSProxy
{
    id<ETCollectionObject> collection;
    NSArray *contents;
    NSUInteger counter;
    NSUInteger maxElements;
    ObjectAtIndexFunction objectAtIndex;
}
- (id)nextObjectFromContents;
@end

/* Structures */

// Structure to wrap the char array that is used as a bitfield to mark
// argument-slots that have ETEachProxies set.
typedef struct
{
    char fields[16];
} argField_t;

// A structure to encapsulate the information the recursive mapping function
// needs.
typedef struct
{
    __unsafe_unretained id<ETCollection> source;
    __unsafe_unretained id<ETCollectionMutation> target;
    __unsafe_unretained NSMutableArray *alreadyMapped;
    __unsafe_unretained id mapInfo;
    MapPlaceObjectFunction elementHandler;
    SEL handlerSelector;
    __unsafe_unretained NSNull *theNull;
    NSUInteger objIndex;
    BOOL modifiesSelf;
} ETMapContext;

@implementation ETEachProxy: NSProxy
- (id)initWithOriginal: (id<ETCollectionObject>)aCollection
{
    ASSIGN(collection,aCollection);
    contents = [[(NSObject*)collection collectionArray] retain];
    counter = 0;
    maxElements = [contents count];
    objectAtIndex = (ObjectAtIndexFunction)[contents methodForSelector: @selector(objectAtIndex:)];
    return self;
}

- (void)dealloc
{
    [collection release];
    [contents release];
    [super dealloc];
}

/*- (id)forwardingTargetForSelector: (SEL)aSelector
{
    return collection;
}
*/

- (BOOL)respondsToSelector: (SEL)aSelector
{
    if (sel_isEqual(@selector(nextObjectFromContents), aSelector))
    {
        return YES;
    }
    return [collection respondsToSelector: aSelector];
}

- (NSMethodSignature*)methodSignatureForSelector: (SEL)aSelector
{
    if ([collection respondsToSelector: aSelector])
    {
        return [(NSObject*)collection methodSignatureForSelector: aSelector];
    }
    return nil;
}

- (void)forwardInvocation: (NSInvocation*)anInvocation
{
    if ([collection respondsToSelector: [anInvocation selector]])
    {
        [anInvocation invokeWithTarget: collection];
    }
}

- (id)nextObjectFromContents
{
    id object = nil;
    if (counter < maxElements)
    {
        object = objectAtIndex(contents, @selector(objectAtIndex:), counter);
        counter++;
    }
    else
    {
        // Reset the counter for the next;
        counter = 0;
    }
    return object;
}
@end

@implementation NSObject (ETEachHOM)
- (id)each
{
    if ([self conformsToProtocol: @protocol(ETCollection)])
    {
        return [[[ETEachProxy alloc] initWithOriginal: (id)self] autorelease];
    }
    return self;
}
@end

/*
 * Helper method to obtain a list of the argument slots in the invocation that
 * contain an ETEachProxy.
 */
static inline argField_t eachedArgumentsFromInvocation(NSInvocation *inv)
{
    NSMethodSignature *sig = [inv methodSignature];
    NSUInteger argCount = [sig numberOfArguments];
    /*
     * We need a char[16] to hold 128bits, since C99 allows 127 arguments and
     * initialize to zero:
     */
    argField_t argField;
    memset(&(argField.fields[0]),'\0',16);
    BOOL hasProxy = NO;

    /* No method arguments (only self and _cmd as invisible arguments) */
    BOOL isUnaryInvocation = (argCount < 3);

    if (isUnaryInvocation)
    {
        return argField;
    }

    for (int i = 2; i < argCount; i++)
    {
        // Consider only object arguments:
        const char *argType = [sig getArgumentTypeAtIndex: i];
        if ((0 == strcmp(@encode(id), argType))
          || (0 == strcmp(@encode(Class), argType)))
        {
            id arg;
            [inv getArgument: &arg atIndex: i];
            if ([arg respondsToSelector: @selector(nextObjectFromContents)])
            {
                // We need to skip to the next field of the char array every 8
                // bits. The integer division/modulo operations calculate just
                // the right offset for that.
                int index = i / 8;
                argField.fields[index] = (argField.fields[index] | (1 << (i % 8)));
                hasProxy = YES;
            }
        }
    }

    if (hasProxy)
    {
        // Use the first bit as a marker to signify that the invocation has
        // proxied-arguments.
        argField.fields[0] = argField.fields[0] | 1;
    }
    return argField;
}

/*
 * Scan the argField to find the index of the next argument that has an
 * each-proxy set.
 */
static inline NSUInteger nextSlotIDWithEachProxy(argField_t *slots, NSUInteger slotID)
{
    while (!(slots->fields[(slotID / 8)] & (1 << (slotID % 8))) && (slotID < MAX_ARGS))
    {
        slotID++;
    }
    return slotID;
}
/*
 * Recursive map function to fill the slots in an invocation
 * that are marked with an ETEachProxy and invoke it afterwards.
 */
static void recursiveMapWithInvocationAndContext(NSInvocation *inv, // the invocation, target and arguments < slotID set
                                                 argField_t *slots, // a bitfield of the arguments that need to be replaced
                                                 NSUInteger slotID, // the slotId for the present level of recursion
                                                 ETMapContext *ctx) // the context
{
    // Scan the slots array for the next argument-slot that has a proxy.
    slotID = nextSlotIDWithEachProxy(slots, slotID);

    /*
     * Also find the argument-slot after that. (Needed to determine whether we
     * should fire the invocation.)
     */
    NSUInteger nextSlotID = nextSlotIDWithEachProxy(slots, (slotID + 1));


    id eachProxy = nil;
    if (slotID < MAX_ARGS)
    {
        [inv getArgument: &eachProxy atIndex: slotID];
    }
    id theObject;
    int count = 0;
    while (nil != (theObject = [eachProxy nextObjectFromContents]))
    {
        // Set the present argument:
        [inv setArgument: &theObject atIndex: slotID];
        if (MAX_ARGS == nextSlotID)
        {
            // If there are no more arguments to be set, the invocation is
            // properly set up, otherwise there are proxies left in the
            // invocation that need to be replaced first.
            id mapped = nil;
            [inv invoke];
            [inv getReturnValue: &mapped];

            if (nil == mapped)
            {
                mapped = ctx->theNull;
            }
            if (ctx->modifiesSelf)
            {
                [ctx->alreadyMapped addObject: mapped];
            }

            // We only want to use the handler the first time we run for this
            // target element. Otherwise it might overwrite the result from the
            // previous run(s).
            BOOL isFirstRun = (0 == count);

            if ((ctx->elementHandler != NULL) && isFirstRun)
            {
                // The elementHandler is an IMP for the -placeObject:... method
                // of the collection class. Hence the first to arguments are
                // receiver and selector.
                ctx->elementHandler(ctx->source, ctx->handlerSelector, mapped,
                                    &ctx->target, [inv target], ctx->objIndex,
                                    ctx->alreadyMapped, ctx->mapInfo);
            }
            else
            {
                // Also check the count, cf. note above.
                if (ctx->modifiesSelf && isFirstRun)
                {
                    [(NSMutableArray*)ctx->target replaceObjectAtIndex: ctx->objIndex
                                                            withObject: mapped];
                }
                else
                {
                    [ctx->target addObject: mapped];
                }
            }
            count++;
        }
        else
        {
            recursiveMapWithInvocationAndContext(inv, slots, nextSlotID, ctx);
        }

    }
    // Before we return, we must put the proxy back into the invocation so that
    // it can be used again when the invocation is invoked again with a
    // different combination of target and arguments.
    [inv setArgument: &eachProxy atIndex: slotID];
}


/*
 * Recursively evaluating the predicate is easier because the handling of
 * adding/removing elements can be done in the caller.
 * NOTE: The results are ORed.
 */
static BOOL recursiveFilterWithInvocation(NSInvocation *inv, // The invocation, target and arguments < slotID set
                                          argField_t *slots, // A bitfield marking the argument-slots to be replaced
                                          NSUInteger slotID) // The slotId for the present level of recursion
{
    // Scan the slots array for the next slot that has a proxy. 127 marks the
    // end of the array.
    slotID = nextSlotIDWithEachProxy(slots, slotID);

    // Repeat to find the next slot (we need this to determine whether we should
    // fire the invocation.)
    NSUInteger nextSlotID = nextSlotIDWithEachProxy(slots, (slotID + 1));

    id eachProxy = nil;
    if (slotID < MAX_ARGS)
    {
        [inv getArgument: &eachProxy atIndex: slotID];
    }
    BOOL result = NO;
    id theObject;
    while (nil != (theObject = [eachProxy nextObjectFromContents]))
    {
        // Set the present argument:
        [inv setArgument: &theObject atIndex: slotID];
        if (MAX_ARGS == nextSlotID)
        {
            // Now the invocation is set up properly. (127 is no "real" slot)
            long long filterResult = (long long)NO;
            [inv invoke];
            [inv getReturnValue: &filterResult];
            result = (result || (BOOL)filterResult);
            // In theory, we could escape the loop once the we get a positive
            // result, but the application might rely on the side-effects of the
            // invocation.
        }
        else
        {
            result = (result || recursiveFilterWithInvocation(inv, slots, nextSlotID));
        }

    }
    [inv setArgument: &eachProxy atIndex: slotID];
    return result;
}

/*
 * The following functions will be used by both the ETCollectionHOM categories
 * and the corresponding proxies.
 */
static inline void ETHOMMapCollectionWithBlockOrInvocationToTargetAsArray(
                                const id<ETCollectionObject> *aCollection,
                                                     id blockOrInvocation,
                                                            BOOL useBlock,
                             const id<ETMutableCollectionObject> *aTarget,
                                                       BOOL isArrayTarget)
{
    if ([*aCollection isEmpty])
    {
        return;
    }

    BOOL modifiesSelf = ((void*)aCollection == (void*)aTarget);
    id<ETCollectionObject> theCollection = *aCollection;
    id<ETMutableCollectionObject> theTarget = *aTarget;
    NSInvocation *anInvocation = nil;
    SEL selector = NULL;

    //Prefetch some stuff to avoid doing it repeatedly in the loop.

    if (NO == useBlock)
    {
        anInvocation = (NSInvocation*)blockOrInvocation;
        selector = [anInvocation selector];
    }

    SEL handlerSelector =
     @selector(placeObject:inCollection:insteadOfObject:atIndex:havingAlreadyMapped:info:);
    MapPlaceObjectFunction elementHandler = NULL;
    if ([theCollection respondsToSelector:handlerSelector]
      && (NO == isArrayTarget))
    {
        elementHandler = (MapPlaceObjectFunction)[(NSObject *)theCollection methodForSelector: handlerSelector];
    }

    SEL valueSelector = @selector(value:);
    Value1Function invokeBlock = NULL;
    BOOL invocationHasObjectReturnType = YES;
    if (useBlock)
    {
        if ([blockOrInvocation respondsToSelector: valueSelector])
        {
            invokeBlock = (Value1Function)[(NSObject *)blockOrInvocation methodForSelector: valueSelector];
        }
        //FIXME: Determine the return type of the block
    }
    else
    {
        // Check whether the invocation is supposed to return objects:
        const char* returnType = [[anInvocation methodSignature] methodReturnType];
        invocationHasObjectReturnType = ((0 == strcmp(@encode(id), returnType))
                                         || (0 == strcmp(@encode(Class), returnType)));
    }
    /*
     * For some collections (such as NSDictionary) the index of the object
     * needs to be tracked.
     */
    unsigned int objectIndex = 0;
    NSNull *nullObject = [NSNull null];
    id mapInfo = nil;
    NSArray *collectionArray = [(NSObject*)theCollection collectionArrayAndInfo: &mapInfo];
    NSMutableArray *alreadyMapped = nil;

    if (modifiesSelf)
    {
        /*
         * For collection ensuring uniqueness of elements, like
         * NS(Mutable|Index)Set, the objects that were already mapped need to be
         * tracked.
         * It is only useful if a mutable collection is changed.
         */
        alreadyMapped = [[NSMutableArray alloc] init];
    }

    // If we are using an invocation, fetch a table of the argument slots that
    // contain proxy created with -each and create a context to be passed to
    // the function that will setup and fire the invocation.
    argField_t eachedSlots;
    // Zeroing out the first byte of the field is enough to indicate that it has
    // not been filled.
    eachedSlots.fields[0] = '\0';
    ETMapContext ctx;
    if (NO == useBlock)
    {
        eachedSlots = eachedArgumentsFromInvocation(blockOrInvocation);
        ctx.source = theCollection;
        ctx.target = theTarget;
        ctx.alreadyMapped = alreadyMapped;
        ctx.mapInfo = mapInfo;
        ctx.theNull = nullObject;
        ctx.modifiesSelf = modifiesSelf;
        ctx.elementHandler = elementHandler;
        ctx.handlerSelector = handlerSelector;
        ctx.objIndex = objectIndex;
    }
    FOREACHI(collectionArray, object)
    {
        id mapped = nil;
        if (NO == useBlock)
        {
            if (NO == [object respondsToSelector: selector])
            {
                // Don't operate on this element:
                objectIndex++;
                continue;
            }
            BOOL useEachProxy = (eachedSlots.fields[0] & 1);
            if (useEachProxy)
            {
                ctx.objIndex = objectIndex;
                [anInvocation setTarget: object];
                recursiveMapWithInvocationAndContext(anInvocation, &eachedSlots,
                                                     2, &ctx);
                objectIndex++;
                continue;
            }
            else
            {
                [anInvocation invokeWithTarget: object];
                if (invocationHasObjectReturnType)
                {
                    [anInvocation getReturnValue: &mapped];
                }
            }
        }
        else
        {
            mapped = invokeBlock(blockOrInvocation, valueSelector, object);
        }
        if (nil == mapped)
        {
            mapped = nullObject;
        }
        if (modifiesSelf)
        {
            [alreadyMapped addObject: mapped];
        }

        if (elementHandler != NULL)
        {
            elementHandler(theCollection, handlerSelector, mapped, (id<ETCollectionMutation> *)aTarget,
                           object, objectIndex, alreadyMapped, mapInfo);
        }
        else
        {
            if (modifiesSelf)
            {
                [(NSMutableArray*)theTarget replaceObjectAtIndex: objectIndex
                                                      withObject: mapped];
            }
            else
            {
                [theTarget addObject: mapped];
            }
        }
        objectIndex++;
    }

    // Cleanup:
    if (modifiesSelf)
    {
        [alreadyMapped release];
    }
    if (mapInfo != nil)
    {
        [mapInfo release];
    }
}

static inline void ETHOMMapCollectionWithBlockOrInvocationToTarget(
                         const id<ETCollectionObject> *aCollection,
                                              id blockOrInvocation,
                                                     BOOL useBlock,
                       const id<ETMutableCollectionObject> *aTarget)
{
    ETHOMMapCollectionWithBlockOrInvocationToTargetAsArray(aCollection,
                                                           blockOrInvocation,
                                                           useBlock,
                                                           aTarget,
                                                           NO);
}

static inline id ETHOMFoldCollectionWithBlockOrInvocationAndInitialValueAndInvert(
                                       const id<ETCollectionObject>*aCollection,
                                                           id blockOrInvocation,
                                                                  BOOL useBlock,
                                                                id initialValue,
                                                               BOOL shallInvert)
{
    if ([*aCollection isEmpty])
    {
        return initialValue;
    }

    id accumulator = initialValue;
    NSInvocation *anInvocation = nil;
    SEL selector = NULL;

    if (NO == useBlock)
    {
        anInvocation = (NSInvocation*)blockOrInvocation;
        selector = [anInvocation selector];
    }

    SEL valueSelector = @selector(value:value:);
    Value2Function invokeBlock = NULL;
    if (useBlock)
    {
        NSCAssert([blockOrInvocation respondsToSelector: valueSelector],
                @"Block does not respond to the correct selector!");
        invokeBlock = (Value2Function)[(NSObject *)blockOrInvocation methodForSelector: valueSelector];
    }

    /*
     * For folding we can safely consider only the content as an array.
     */
    NSArray *content = [[(NSObject*)*aCollection collectionArray] retain];
    NSEnumerator *contentEnumerator;
    if (NO == shallInvert)
    {
        contentEnumerator = [content objectEnumerator];
    }
    else
    {
        contentEnumerator = [content reverseObjectEnumerator];
    }

    FOREACHE(content, element, id, contentEnumerator)
    {
        id target;
        id argument;
        if (NO == shallInvert)
        {
            target = accumulator;
            argument = element;
        }
        else
        {
            target = element;
            argument = accumulator;
        }

        if (NO == useBlock)
        {
            if ([target respondsToSelector:selector])
            {
                [anInvocation setArgument: &argument
                                  atIndex: 2];
                [anInvocation invokeWithTarget: target];
                [anInvocation getReturnValue: &accumulator];
            }
        }
        else
        {
            accumulator = invokeBlock(blockOrInvocation, valueSelector, target, argument);
        }
    }
    [content release];
    return accumulator;
}

static inline void ETHOMFilterCollectionWithBlockOrInvocationAndTargetAndOriginalAndInvert(
                                      const id<ETCollectionObject> *aCollection,
                                                           id blockOrInvocation,
                                                                  BOOL useBlock,
                                    const id<ETMutableCollectionObject> *target,
                                         const id<ETCollectionObject> *original,
                                                                    BOOL invert)
{
    if ([*aCollection isEmpty])
    {
        return;
    }

    id<ETCollectionObject> theCollection = (id<ETCollectionObject>)*aCollection;
    id<ETMutableCollectionObject> theTarget = (id<ETMutableCollectionObject>)*target;
    NSInvocation *anInvocation = nil;
    SEL selector = NULL;
    argField_t eachedSlots;
    // Zeroing out the first byte of the field is enough to indicate that the
    // field has not been filled.
    eachedSlots.fields[0] = '\0';

    if (NO == useBlock)
    {
        anInvocation = (NSInvocation*)blockOrInvocation;
        selector = [anInvocation selector];
        eachedSlots = eachedArgumentsFromInvocation(blockOrInvocation);
    }

    /*
     * A snapshot of the object is needed at least for NSDictionary. It needs
     * to know about the key for which the original object was set in order to
     * remove/add objects correctly. Also other collections might rely on
     * additional information about the original collection. Still, we don't
     * want to bother with creating the snapshot if the collection does not
     * implement the -placeObject... method.
     */
    id info = nil;
    NSArray *content = nil;
    NSEnumerator *originalEnum = nil;
    if (*original == nil)
    {
        content = [[(NSObject*)theCollection collectionArrayAndInfo: &info] retain];
    }
    else
    {
        content = [[(NSObject*)theCollection collectionArray] retain];
        originalEnum = [[(NSObject*)*original collectionArrayAndInfo: &info] objectEnumerator];
    }

    SEL handlerSelector =
       @selector(placeObject:atIndex:inCollection:basedOnFilter:info:);
    FilterPlaceObjectFunction elementHandler = NULL;
    unsigned int objectIndex = 0;
    FOREACHI(content, object)
    {
        id originalObject = [originalEnum nextObject];
        long long filterResult = (long long)NO;
        if (NO == useBlock)
        {
            if (NO == [object respondsToSelector: selector])
            {
                // Don't operate on this element:
                objectIndex++;
                continue;
            }
            BOOL usesEachProxy = (eachedSlots.fields[0] & 1);
            if (usesEachProxy)
            {
                [anInvocation setTarget: object];
                filterResult = recursiveFilterWithInvocation(anInvocation, &eachedSlots, 2);
            }
            else
            {
                [anInvocation invokeWithTarget: object];
                [anInvocation getReturnValue: &filterResult];
            }
        }
        #if __has_feature(blocks)
        else
        {
            BOOL(^theBlock)(id) = (BOOL(^)(id))blockOrInvocation;
            filterResult = (long long)theBlock(object);
        }
        #endif
        if (invert)
        {
            filterResult = !(BOOL)filterResult;
        }
        if (elementHandler != NULL)
        {
            elementHandler(*original, handlerSelector, originalObject,
                           objectIndex, (id<ETCollectionMutation> *)target, (BOOL)filterResult, info);
        }
        else
        {
            if (((id)theTarget == (id)*original) && (NO == (BOOL)filterResult))
            {
                [theTarget removeObject: originalObject];
            }
            else if (((id)theTarget!=(id)*original) && (BOOL)filterResult)
            {
                [theTarget addObject: originalObject];
            }
        }
        objectIndex++;
    }
    [content release];
    if (info != nil)
    {
        [info release];
    }
}

static inline void ETHOMFilterCollectionWithBlockOrInvocationAndTargetAndInvert(
                                      const id<ETCollectionObject> *aCollection,
                                                          id  blockOrInvocation,
                                                                  BOOL useBlock,
                                    const id<ETMutableCollectionObject> *target,
                                                                    BOOL invert)
{
    ETHOMFilterCollectionWithBlockOrInvocationAndTargetAndOriginalAndInvert(
                                                          aCollection,
                                                          blockOrInvocation,
                                                          useBlock,
                                                          target,
                                                          aCollection,
                                                          invert);
}

static inline id ETHOMFilteredCollectionWithBlockOrInvocationAndInvert(
                                      const id<ETCollectionObject> *aCollection,
                                                           id blockOrInvocation,
                                                                  BOOL useBlock,
                                                                    BOOL invert)
{
    id<ETMutableCollectionObject> mutableCollection = [[[[*aCollection class] mutableClass] alloc] init];
    ETHOMFilterCollectionWithBlockOrInvocationAndTargetAndInvert(aCollection,
                                                           blockOrInvocation,
                                                                    useBlock,
                                                          &mutableCollection,
                                                                      invert);
    return [mutableCollection autorelease];
}

static inline void ETHOMFilterMutableCollectionWithBlockOrInvocationAndInvert(
                               const id<ETMutableCollectionObject> *aCollection,
                                                           id blockOrInvocation,
                                                                  BOOL useBlock,
                                                                    BOOL invert)
{
    ETHOMFilterCollectionWithBlockOrInvocationAndTargetAndOriginalAndInvert(
                                                                 aCollection,
                                                           blockOrInvocation,
                                                                    useBlock,
                                                                 aCollection,
                                                                 aCollection,
                                                                      invert);
}


static inline void ETHOMZipCollectionsWithBlockOrInvocationAndTarget(
                    const id<ETCollectionObject> *firstCollection,
                   const id<ETCollectionObject> *secondCollection,
                                                id blockOrInvocation,
                                                       BOOL useBlock,
        const id<ETMutableCollectionObject> *target)
{
    if ([*firstCollection isEmpty])
    {
        return;
    }

    BOOL modifiesSelf = ((void*)firstCollection == (void*)target);
    NSInvocation *invocation = nil;
    SEL selector = NULL;
    id mapInfo = nil;
    NSArray *contentsFirst = [(NSObject*)*firstCollection collectionArrayAndInfo: &mapInfo];
    NSArray *contentsSecond = [(NSObject*)*secondCollection collectionArray];
    if (NO == useBlock)
    {
        invocation = (NSInvocation*)blockOrInvocation;
        selector = [invocation selector];
    }

    SEL handlerSelector =
     @selector(placeObject:inCollection:insteadOfObject:atIndex:havingAlreadyMapped:info:);
    MapPlaceObjectFunction elementHandler = NULL;

    if ([*firstCollection respondsToSelector: handlerSelector])
    {
        elementHandler = (MapPlaceObjectFunction)[(NSObject *)*firstCollection methodForSelector: handlerSelector];
    }

    SEL valueSelector = @selector(value:value:);
    Value2Function invokeBlock = NULL;
    if (useBlock)
    {
        NSCAssert([blockOrInvocation respondsToSelector: valueSelector],
                @"Block does not respond to the correct selector!");
        invokeBlock = (Value2Function)[(NSObject *)blockOrInvocation methodForSelector: valueSelector];
    }

    NSMutableArray *alreadyMapped = (modifiesSelf ? [[NSMutableArray alloc] init] : nil);
    NSUInteger objectIndex = 0;
    NSUInteger objectMax = MIN([contentsFirst count], [contentsSecond count]);
    NSNull *nullObject = [NSNull null];

    FOREACHI(contentsFirst, firstObject)
    {
        if (objectIndex >= objectMax)
        {
            break;
        }
        id secondObject = [contentsSecond objectAtIndex: objectIndex];
        id mapped = nil;
        if (NO == useBlock)
        {
            if (NO == [firstObject respondsToSelector: selector])
            {
                objectIndex++;
                continue;
            }

            [invocation setArgument: &secondObject
                            atIndex: 2];
            [invocation invokeWithTarget: firstObject];
            [invocation getReturnValue: &mapped];
        }
        else
        {
            mapped = invokeBlock(blockOrInvocation, valueSelector, firstObject,
                                 secondObject);
        }

        if (nil == mapped)
        {
            mapped = nullObject;
        }

        if (modifiesSelf)
        {
            [alreadyMapped addObject: mapped];
        }

        if (elementHandler != NULL)
        {
            elementHandler(*firstCollection, handlerSelector, mapped, (id<ETCollectionMutation> *)target,
                           firstObject, objectIndex, alreadyMapped, mapInfo);
        }
        else
        {
            if (modifiesSelf)
            {
                [(NSMutableArray*)*target replaceObjectAtIndex: objectIndex
                                                    withObject: mapped];
            }
            else
            {
                [*target addObject: mapped];
            }
        }
        objectIndex++;
    }

    if (modifiesSelf)
    {
        [alreadyMapped release];
    }
    if (mapInfo != nil)
    {
        [mapInfo release];
    }
}

/*
 * Proxies for higher-order messaging via forwardInvocation.
 */
@interface ETCollectionHOMProxy: NSProxy
{
    id<ETCollectionObject> collection;
}
@end

@interface ETCollectionMapProxy: ETCollectionHOMProxy
@end

@interface ETCollectionMutationMapProxy: ETCollectionHOMProxy
@end

@interface ETCollectionFoldProxy: ETCollectionHOMProxy
{
    BOOL inverse;
}
@end

@interface ETCollectionMutationFilterProxy: ETCollectionHOMProxy
{
    // Stores a reference to the original collection, even if the actual filter
    // operates on a modified one.
    id<ETMutableCollectionObject> originalCollection;
    BOOL invert;
    BOOL selectorIncompatibleWithCollectionElements;

}
@end

@interface ETCollectionZipProxy: ETCollectionHOMProxy
{
    id<ETCollectionObject> secondCollection;
}
@end


@interface ETCollectionMutationZipProxy: ETCollectionZipProxy
@end

@implementation ETCollectionHOMProxy
- (id)initWithCollection: (id<ETCollectionObject>)aCollection
{
    collection = [aCollection retain];
    return self;
}

- (void)dealloc
{
    [collection release];
    [super dealloc];
}

- (BOOL)respondsToSelector: (SEL)aSelector
{
    if ([collection isEmpty])
    {
        return YES;
    }

    NSEnumerator *collectionEnumerator = [(NSArray*)collection objectEnumerator];
    FOREACHE(collection, object, id, collectionEnumerator)
    {
        if ([object respondsToSelector: aSelector])
        {
            return YES;
        }
    }
    return [NSObject instancesRespondToSelector: aSelector];
}

- (NSMethodSignature*)primitiveMethodSignatureForSelector: (SEL)aSelector
{
    return [NSObject instanceMethodSignatureForSelector: aSelector];
}

/* You can override this method to return a custom method signature as
ETCollectionMutationFilterProxy does.
You can call -primitiveMethodSignatureForSelector: in the overriden version, but
not -[super methodSignatureForSelector:]. */
- (NSMethodSignature*)methodSignatureForEmptyCollection
{
    /*
     * Returns any arbitrary NSObject selector whose return type is id.
     */
    return [NSObject instanceMethodSignatureForSelector: @selector(self)];
}

- (NSMethodSignature*)methodSignatureForSelector: (SEL)aSelector
{
    if ([collection isEmpty])
    {
        return [self methodSignatureForEmptyCollection];
    }

    /*
     * The collection is cast to NSArray because even though all classes
     * adopting ETCollection provide -objectEnumerator this is not declared.
     * (See ETCollection.h)
     */
    NSEnumerator *collectionEnumerator = [(NSArray*)collection objectEnumerator];
    FOREACHE(collection, object, id, collectionEnumerator)
    {
        if ([object respondsToSelector:aSelector])
        {
            return [object methodSignatureForSelector:aSelector];
        }
    }
    return [NSObject instanceMethodSignatureForSelector:aSelector];
}

// TODO: Intercept all messages from the NSObject protocol except -autorelease,
// -retain, -release, -isProxy and implement a special -proxyDescription for
// debugging supposing -description gets overriden for forwarding purpose.

/* Intercepted NSObject Protocol Messages as Normal HOM Argument Messages */

- (Class)class
{
    /* For this check, see -isEqual: */
    if ([collection isEmpty])
        return nil;

    NSInvocation *inv = [NSInvocation invocationWithTarget: self selector: _cmd arguments: nil];
    Class retValue = Nil;

    [self forwardInvocation: inv];
    [inv getReturnValue: &retValue];
    return retValue;
}

- (BOOL)isEqual: (id)obj
{
    /* Discard the message, we cannot construct the invocation because
       -methodSignatureForEmptyCollection would be called and returns the
       same constant method signature per HOM proxy type.
       We could tweak -methodSignatureForEmptyCollection to accept a
       selector in argument and look up the right signature on NSObject, but
       that's useless given that we are going to ignore the message anyway. */
    if ([collection isEmpty])
        return NO;

    NSInvocation *inv = [NSInvocation invocationWithTarget: self selector: _cmd arguments: nil];
    BOOL retValue = NO;

    [inv setArgument: &obj atIndex: 2];
    [self forwardInvocation: inv];
    [inv getReturnValue: &retValue];
    return retValue;
}

@end

@implementation ETCollectionMapProxy
- (void)forwardInvocation: (NSInvocation*)anInvocation
{
    Class mutableClass = [[collection class] mutableClass];
    id<ETMutableCollectionObject> mappedCollection = [[[mutableClass alloc] init] autorelease];
    ETHOMMapCollectionWithBlockOrInvocationToTarget(
                                  (const id<ETCollectionObject>*) &collection,
                                                                 anInvocation,
                                                                           NO,
                                                            &mappedCollection);

    if ([[anInvocation methodSignature] methodReturnLength] > 0)
    {
        [anInvocation setReturnValue: &mappedCollection];
    }
}
@end

@implementation ETCollectionMutationMapProxy
- (void)forwardInvocation: (NSInvocation*)anInvocation
{

    ETHOMMapCollectionWithBlockOrInvocationToTarget(
                                  (const id<ETCollectionObject>*)&collection,
                                                                anInvocation,
                                                                          NO,
                           (const id<ETMutableCollectionObject>*)&collection);
    //Actually, we don't care for the return value.
    [anInvocation setReturnValue:&collection];
}
@end


@implementation ETCollectionFoldProxy
- (id)initWithCollection: (id<ETCollectionObject>)aCollection
              forInverse: (BOOL)shallInvert
{

    if (nil == (self = [super initWithCollection: aCollection]))
    {
        return nil;
    }
    inverse = shallInvert;
    return self;
}

- (void)forwardInvocation: (NSInvocation*)anInvocation
{

    id initialValue = nil;
    if ([collection isEmpty] == NO)
    {
        [anInvocation getArgument: &initialValue atIndex: 2];
    }
    id foldedValue =
    ETHOMFoldCollectionWithBlockOrInvocationAndInitialValueAndInvert(&collection,
                                                                     anInvocation,
                                                                     NO,
                                                                     initialValue,
                                                                     inverse);
    [anInvocation setReturnValue:&foldedValue];
}
@end

/* NSProxy has no methods to retrieve the method signatures e.g.
   -methodSignatureForSelector:, so -methodSignatureForEmptyCollection must
   invoke -primitiveMethodSignatureForSelector: on a class whose kind is
   NSObject to get a method signature. */
@interface NSObject (PointerSizedProxyNull)
- (uintptr_t)pointerSizedProxyNull;
@end
@implementation NSObject (PointerSizedProxyNull)
- (uintptr_t)pointerSizedProxyNull
{
    return 0;
}
@end

@implementation ETCollectionMutationFilterProxy
- (id)initWithCollection: (id<ETCollectionObject>) aCollection
             andOriginal: (id<ETCollectionObject>) theOriginal
               andInvert: (BOOL)shallInvert
{
    if (nil == (self = [super initWithCollection: aCollection]))
    {
        return nil;
    }
    originalCollection = (id<ETMutableCollectionObject>)[theOriginal retain];
    invert = shallInvert;
    return self;
}

- (id)initWithCollection: (id<ETCollectionObject>) aCollection
               andInvert: (BOOL)aFlag
{
    self = [self initWithCollection: aCollection
                        andOriginal: aCollection
                          andInvert: aFlag];
    return self;
}
- (id)initWithCollection: (id<ETCollectionObject>) aCollection
{
    self = [self initWithCollection: aCollection
                        andOriginal: aCollection
                          andInvert: NO];
    return self;
}

- (id)initWithCollection: (id<ETCollectionObject>) aCollection
             andOriginal: (id<ETCollectionObject>) theOriginal
{
    self = [self initWithCollection: aCollection
                        andOriginal: theOriginal
                          andInvert: NO];
    return self;
}

- (uintptr_t)pointerSizedProxyNull
{
    if ([collection isEmpty])
    {
        return 0;
    }
    NSInvocation *inv = [NSInvocation invocationWithTarget: self selector: _cmd arguments: nil];
    uintptr_t retValue = 0;

    [self forwardInvocation: inv];
    [inv getReturnValue: &retValue];
    return retValue;
}
- (NSMethodSignature*)methodSignatureForEmptyCollection
{
    /*
     * Returns any arbitrary NSObject selector whose return type is BOOL.
     *
     * When the collection is empty, if we have two chained messages like
     * [[[collection filter] name] isEqualToString: @"blabla"], the proxy cannot
     * infer the return types of -name and -isEqualToString: (not exactly true
     * in the GNU runtime case which supports typed selectors). Hence we cannot
     * know whether we have one or two messages in arguments.
     * The solution is to pretend we have only one message whose signature is
     * -(uintptr_t)xxx and use 0 as the return value. This will cause subsequent
     * messages be ignored.
     * We cannot use BOOL because the compiler might have allocated enough space
     * for the return value to store a pointer, and when sizeof(BOOL)<
     * sizeof(uintptr_t) we would not be setting the value to nil.
     *
     * An alternative which doesn't require -primitiveMethodSignatureForSelector
     * would be to pretend we have two messages. With [[x filter] isXYZ], -isXYZ
     * would be treated as -(id)isXYZ. A secondary proxy would be created and
     * its adress put into the BOOL return value. This secondary proxy would
     * never receive a message and the returned boolean would be random.
     */
    return [self primitiveMethodSignatureForSelector: @selector(pointerSizedProxyNull)];
}

- (BOOL)respondsToSelector: (SEL)aSelector
{
    /* For -filter, we accept any argument message. More explanations below, in
       -methodSignatureForSelector: code comment. */
    return YES;
}

- (NSMethodSignature*)methodSignatureForSelector: (SEL)aSelector
{
    NSMethodSignature *sig = [super methodSignatureForSelector: aSelector];

    /* When no elements in the collection responds to the argument message, then
       we return the same marker we use to denote an empty collection, and set
       a boolean flag to be checked in -forwardInvocation:.
       This ensures that [[collection filter] isEqualToString: @"bla"] works
       even when the collection contains no NSString objects.
       Another example would be [[[collection] filter] name] isEqualToString: @"bla"]
       where [[collection] map] name] would return ( [NSNull null], [NSNull null] ... )
       because -name on a element returns nil. */
    if (sig == nil)
    {
        selectorIncompatibleWithCollectionElements = YES;
        return [self methodSignatureForEmptyCollection];
    }
    return sig;
}

- (void)forwardInvocation: (NSInvocation*)anInvocation
{
    const char *returnType = [[anInvocation methodSignature] methodReturnType];
    if (0 == strcmp(@encode(BOOL), returnType))
    {
        ETHOMFilterCollectionWithBlockOrInvocationAndTargetAndOriginalAndInvert(
                                                                    &collection,
                                                                   anInvocation,
                                                                             NO,
                                                            &originalCollection,
                                                            &originalCollection,
                                                                         invert);
        BOOL result = NO;
        [anInvocation setReturnValue: &result];
    }
    else if ((0 == strcmp(@encode(id), returnType))
      || (0 == strcmp(@encode(Class), returnType)))
    {
        id<ETMutableCollectionObject> nextCollection = [NSMutableArray array];
        ETHOMMapCollectionWithBlockOrInvocationToTargetAsArray(&collection,
                                                              anInvocation,
                                                                        NO,
                     (const id<ETMutableCollectionObject>*)&nextCollection,
                                                                      YES);
        id nextProxy = [[[ETCollectionMutationFilterProxy alloc]
                                      initWithCollection: nextCollection
                                             andOriginal: originalCollection
                                               andInvert: invert] autorelease];
        [anInvocation setReturnValue: &nextProxy];
    }
    else if ((0 == strcmp(@encode(uintptr_t), returnType))
        && [collection isEmpty])
    {
        // This special case is used when the collection is empty and we were
        // passed a phony method signature.
        uintptr_t theNull = 0;
        [anInvocation setReturnValue: &theNull];

    }
    else if ((0 == strcmp(@encode(uintptr_t), returnType))
        && selectorIncompatibleWithCollectionElements)
    {
        // This special case is used when no elements respond to the argument
        // message and we were passed a phony method signature.
        // TODO: Add -removeAllObjects to ETCollectionMutation to support
        // NSMutableIndexSet.
        [(id)originalCollection removeAllObjects];
        uintptr_t theNull = 0;
        [anInvocation setReturnValue: &theNull];

    }
    else
    {
        [super forwardInvocation: anInvocation];
    }
}

- (void)dealloc
{
    [originalCollection release];
    [super dealloc];
}
@end

@implementation ETCollectionZipProxy
- (id)initWithCollection: (id<ETCollectionObject>)aCollection
           andCollection: (id<ETCollectionObject>)anotherCollection
{
    if (nil == (self = [super initWithCollection: aCollection]))
    {
        return nil;
    }
    secondCollection = [anotherCollection retain];
    return self;
}

- (void)forwardInvocation: (NSInvocation*)anInvocation
{
    Class mutableClass = [[collection class] mutableClass];
    id<ETMutableCollectionObject> result = [[[mutableClass alloc] init] autorelease];
    ETHOMZipCollectionsWithBlockOrInvocationAndTarget(&collection,
                                                      &secondCollection,
                                                      anInvocation,
                                                      NO,
                                                      &result);
    [anInvocation setReturnValue: &result];
}

- (void)dealloc
{
    [secondCollection release];
    [super dealloc];
}
@end

@implementation ETCollectionMutationZipProxy
- (void)forwardInvocation: (NSInvocation*)anInvocation
{
    ETHOMZipCollectionsWithBlockOrInvocationAndTarget(&collection,
                                                &secondCollection,
                                                     anInvocation,
                                                               NO,
                                           (const id*)&collection);
    [anInvocation setReturnValue: &collection];
}
@end

@implementation NSArray (ETCollectionHOM)
#include "ETCollection+HOMMethods.m"

- (NSArray *)collectionArrayAndInfo: (id *)info
{
    return [self contentArray];
}

@end

@implementation NSDictionary (ETCollectionHOM)

- (NSArray*)collectionArrayAndInfo: (id *)info
{
    // FIXME: Accessing objects returned by -getObjects:forKeys: causes a crash 
    // on GNUstep e.g. objects[i] in NSLog.
#ifdef GNUSTEP
    NSMutableArray *keys = [[NSMutableArray alloc] initWithCapacity: [self count]];
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity: [self count]];

    [self enumerateKeysAndObjectsUsingBlock: ^(id key, id object, BOOL *stop)
    {
        [keys addObject: key];
        [objects addObject: object];
    }];

    if (info != NULL)
    {
        *info = keys;
    }
    return objects;
#else
    NSUInteger count = [self count];
    id __unsafe_unretained objects[count];
    id __unsafe_unretained keys[count];

    [self getObjects: objects andKeys: keys count: count];

    if (info != NULL)
    {
        *info = [[NSArray alloc] initWithObjects: keys count: count];
    }

    /*for (int i = 0; i < count; i++)
    {
        NSLog(@"Object: %@", objects[i]);
    }*/
    return [NSArray arrayWithObjects: objects count: count];
#endif
}

- (void)placeObject: (id)mappedObject
       inCollection: (id<ETCollectionMutation>*)aTarget
    insteadOfObject: (id)originalObject
            atIndex: (NSUInteger)index
havingAlreadyMapped: (NSArray*)alreadyMapped
               info: (id)info
{
    [(NSMutableDictionary*)*aTarget setObject: mappedObject
                                       forKey: [info objectAtIndex: index]];
}
- (void)placeObject: (id)anObject
            atIndex: (NSUInteger)index
       inCollection: (id<ETCollectionMutation>*)aTarget
      basedOnFilter: (BOOL)shallInclude
               info: (id)info
{
    NSString *key = [(NSArray*)info objectAtIndex: index];
    if (((id)self == (id)*aTarget) && (NO == shallInclude))
    {
        [(NSMutableDictionary*)*aTarget removeObjectForKey: key];
    }
    else if (((id)self != (id)*aTarget) && shallInclude)
    {
        [(NSMutableDictionary*)*aTarget setObject: anObject forKey: key];
    }
}
#include "ETCollection+HOMMethods.m"
@end

@implementation NSSet (ETCollectionHOM)
#include "ETCollection+HOMMethods.m"

- (NSArray *)collectionArrayAndInfo: (id *)info
{
    return [self contentArray];
}

@end

@implementation NSIndexSet (ETCollectionHOM)
#include "ETCollection+HOMMethods.m"

- (NSArray *)collectionArrayAndInfo: (id *)info
{
    return [self contentArray];
}

@end

@implementation NSMutableArray (ETCollectionHOM)
- (void)placeObject: (id)mappedObject
       inCollection: (id<NSObject,ETCollection,ETCollectionMutation>*)aTarget
    insteadOfObject: (id)originalObject
            atIndex: (NSUInteger)index
havingAlreadyMapped: (NSArray*)alreadyMapped
               info: (id)info
{
    if ((id)self == (id)*aTarget)
    {
        [(NSMutableArray*)*aTarget replaceObjectAtIndex: index
                                             withObject: mappedObject];
    }
    else
    {
        [*aTarget addObject: mappedObject];
    }
}
#include "ETCollectionMutation+HOMMethods.m"
@end

@implementation NSMutableDictionary (ETCollectionHOM)
#include "ETCollectionMutation+HOMMethods.m"
@end

@implementation NSMutableSet (ETCollectionHOM)
- (void)placeObject: (id)mappedObject
       inCollection: (id<ETCollectionMutation>*)aTarget
    insteadOfObject: (id)originalObject
            atIndex: (NSUInteger)index
havingAlreadyMapped: (NSArray*)alreadyMapped
               info: (id)info
{
    if (((id)self == (id)*aTarget)
     && (NO == [alreadyMapped containsObject: originalObject]))
    {
        [*aTarget removeObject: originalObject];
    }
    [*aTarget addObject: mappedObject];
}
#include "ETCollectionMutation+HOMMethods.m"
@end

/*
 * NSCountedSet does not implement the HOM-methods itself, but it does need to
 * override the -placeObject:... method of its superclass.
 */
@interface NSCountedSet (ETCollectionMapHandler)
@end

@implementation NSCountedSet (ETCOllectionMapHandler)
- (NSArray *)collectionArrayAndInfo: (id *)info
{
    NSArray *distinctObjects = [self allObjects];
    NSMutableArray *result = [NSMutableArray array];
    FOREACHI(distinctObjects,object)
    {
        for(int i = 0; i < [self countForObject:object]; i++)
        {
            [result addObject: object];
        }
    }
    return result;
}

// NOTE: These methods do nothing more than the default implementation. But they
// are needed to override the implementation in NSMutableSet.
- (void)placeObject: (id)mappedObject
       inCollection: (id<ETCollectionMutation>*)aTarget
    insteadOfObject: (id)originalObject
            atIndex: (NSUInteger)index
havingAlreadyMapped: (NSArray*)alreadyMapped
               info: (id)info
{
    if ((id)self == (id)*aTarget)
    {
        [*aTarget removeObject: originalObject];
    }
    [*aTarget addObject: mappedObject];
}

@end

@implementation NSMutableIndexSet (ETCollectionHOM)
- (void)placeObject: (id)mappedObject
       inCollection: (id<ETCollectionMutation>*)aTarget
    insteadOfObject: (id)originalObject
            atIndex: (NSUInteger)index
havingAlreadyMapped: (NSArray*)alreadyMapped
            info: (id)info
{
    if (((id)self == (id)*aTarget)
     && (NO == [alreadyMapped containsObject: originalObject]))
    {
        [*aTarget removeObject: originalObject];
    }
    [*aTarget addObject: mappedObject];
}

#include "ETCollectionMutation+HOMMethods.m"
@end
