#import <Foundation/Foundation.h>
#import <EtoileFoundation/EtoileFoundation.h>

@interface MyObject : NSObject
@end

@implementation MyObject

- (id) copy
{
	id x = [super copy];
	NSLog(@"%@ copied, retain count: %d", self, [self retainCount]);
	return x;
}
- (id) retain
{
	id x = [super retain];
	NSLog(@"%@ retained, retain count: %d", self, [self retainCount]);
	return x;
}
- (void) release
{
	NSLog(@"%@ released, retain count before release: %d",self, [self retainCount]);
	[super release];
}
- (id) autorelease
{
	id x = [super autorelease];
	NSLog(@"%@ autoreleased, retain count: %d", self, [self retainCount]);
	return x;
}

@end



@interface ThreadTestClass : NSObject
{
	MyObject *test;
}

- (id) init;
- (MyObject *) test;

@end

@implementation ThreadTestClass

- (id) init
{
	SUPERINIT;
	test = [[MyObject alloc] init];
	return self;
}

- (void) dealloc
{
	[test release];
	[super dealloc];
}

- (MyObject *) test
{
	return test;
}

@end



int main()
{
	id pool = [[NSAutoreleasePool alloc] init];
	
	ThreadTestClass *object =[[[ThreadTestClass alloc] init] inNewThread];

	
	NSLog(@"calling [object test]: %@", [object test]);
	NSLog(@"calling [object test]:%@", [object test]);
	NSLog(@"calling [object test]:%@", [object test]);

	NSLog(@"Releasing autorelease pool..");
	[pool release];
	return 0;
}

