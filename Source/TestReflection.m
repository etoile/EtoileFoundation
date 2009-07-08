#import <UnitKit/UnitKit.h>
#import <EtoileFoundation/EtoileFoundation.h>

@interface TestReflection : NSObject <UKTest>
{
}
@end

@implementation TestReflection

- (void) testBasic
{
	id objMirror = [ETReflection reflectObject: [[NSObject alloc] init]];
	
	UKStringsEqual([[objMirror classMirror] name], @"NSObject");
	
	UKNil([[objMirror classMirror] superclassMirror]);
	
	/**
	 * Test that subclassMirrors/allSubclassMirrors works (roughly).
	 * Also test that two different class mirrors on the same class compare
	 * as equal.
	 */
	UKTrue([[[objMirror classMirror] allSubclassMirrors] containsObject:
			[ETReflection reflectClass: [NSMutableDictionary class]]]);
	
	UKFalse([[[objMirror classMirror] subclassMirrors] containsObject:
			[ETReflection reflectClass: [NSMutableDictionary class]]]);

	UKTrue([[[objMirror classMirror] subclassMirrors] containsObject:
			[ETReflection reflectClassWithName: @"NSDictionary"]]);
}

- (void) testProtocols
{
	id classMirror = [ETReflection reflectClassWithName: @"NSSet"];	
	UKTrue([[classMirror adoptedProtocolMirrors] containsObject: 
			[ETReflection reflectProtocolWithName: @"NSCoding"]]);

	UKFalse([[classMirror adoptedProtocolMirrors] containsObject: 
			[ETReflection reflectProtocolWithName: @"ThisProtocolDoesNotExist"]]);


}

@end
