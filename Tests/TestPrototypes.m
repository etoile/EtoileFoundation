#import <objc/runtime.h>
// Prototypes are only supported with the GNUstep runtime currently.
#ifdef __GNUSTEP_RUNTIME__
#import <objc/blocks_runtime.h>
#import <objc/capabilities.h>
#ifdef OBJC_CAP_PROTOTYPES
#import <UnitKit/UnitKit.h>
#import <EtoileFoundation/EtoileFoundation.h>

struct big
{
	int a, b, c, d, e;
};

@interface Foo : NSObject @end
@implementation Foo @end
@interface Foo (Dynamic)
+(int)count: (int)i;
+(struct big)sret;
-(int)count: (int)i;
-(struct big)sret;
@end

@interface TestPrototypes : NSObject <UKTest> @end
@implementation TestPrototypes
- (void)testPrototypes
{
	__block int b = 0;
	void* blk = ^(id self, int a) {
		b += a; 
		return b; };
	blk = Block_copy(blk);
	[Foo addInstanceMethod: @selector(count:) fromBlock: blk];
	[Foo addClassMethod: @selector(count:) fromBlock: blk];
	id foo = [Foo new];
	// Check that the block is really used as a method
	UKTrue(2 == [foo count: 2]);
	UKTrue(4 == [foo count: 2]);
	UKTrue(6 == [foo count: 2]);
	UKTrue(8 == [Foo count: 2]);
	blk = ^(id self) {
		struct big b = {1, 2, 3, 4, 5};
		return b;
	};
	// Check that things returning big structures work
	[Foo addInstanceMethod: @selector(sret) fromBlock: blk];
	struct big s = [foo sret];
	UKTrue(s.a == 1);
	UKTrue(s.b == 2);
	UKTrue(s.c == 3);
	UKTrue(s.d == 4);
	UKTrue(s.e == 5);
	// Check that blocks can be added to single objects.
	UKTrue([foo addMethod: @selector(count:) fromBlock: ^(id self, int a) { return a; } ]);
	UKTrue([foo count: 32] == 32);
	UKTrue([[Foo new] count: 14] == 22);
}
@end

#else 
#warning You Objective-C runtime does not support prototypes
#endif
#else 
#warning You Objective-C runtime does not support prototypes
#endif
