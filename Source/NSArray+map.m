#import "NSArray+map.h"
#import "Macros.h"

@interface NSArrayMapProxy : NSObject {
	NSArray * array;
}
- (id) initWithArray:(NSArray*)anArray;
@end

@implementation NSArrayMapProxy
- (id) initWithArray:(NSArray*)anArray
{
	SELFINIT;
	array = [anArray retain];
	return self;
}
- (id) methodSignatureForSelector:(SEL)aSelector
{
	FOREACHI(array, object)
	{
		if([object respondsToSelector:aSelector])
		{
			return [object methodSignatureForSelector:aSelector];
		}
	}
	return [super methodSignatureForSelector:aSelector];
}
- (void) forwardInvocation:(NSInvocation*)anInvocation
{
	SEL selector = [anInvocation selector];
	NSMutableArray * mappedArray = [NSMutableArray array];
	FOREACHI(array, object)
	{
		if([object respondsToSelector:selector])
		{
			[anInvocation invokeWithTarget:object];
			id mapped;
			[anInvocation getReturnValue:&mapped];
			[mappedArray addObject:mapped];
		}
	}
	[anInvocation setReturnValue:mappedArray];
}
DEALLOC(
	[array release];
)
@end

@implementation NSArray (AllElements)
- (id) map
{
	return [[[NSArrayMapProxy alloc] initWithArray:self] autorelease];
}
@end
