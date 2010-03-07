#import <UnitKit/UnitKit.h>
#import <EtoileFoundation/EtoileFoundation.h>

#define SA(x) [NSSet setWithArray: x]

@interface TestEntityDescription : NSObject <UKTest>
{
}
@end

@implementation TestEntityDescription

- (void) testBasic
{
	id book = [ETEntityDescription descriptionWithName: @"Book"];
	id title = [ETPropertyDescription descriptionWithName: @"title"];
	id authors = [ETPropertyDescription descriptionWithName: @"authors"];
	[authors setMultivalued: YES];
	[book setPropertyDescriptions: A(title, authors)];
	
	id person = [ETEntityDescription descriptionWithName: @"Person"];
	id name = [ETPropertyDescription descriptionWithName: @"name"];
	id personBooks = [ETPropertyDescription descriptionWithName: @"books"];
	[personBooks setMultivalued: YES];
	[person setPropertyDescriptions: A(name, personBooks)];

	id library = [ETEntityDescription descriptionWithName: @"Library"];
	id librarian = [ETPropertyDescription descriptionWithName: @"librarian"];
	id libraryBooks = [ETPropertyDescription descriptionWithName: @"books"];
	[libraryBooks setMultivalued: YES];
	[library setPropertyDescriptions: A(librarian, libraryBooks)];

	[authors setOpposite: personBooks];

	UKObjectsEqual(SA([book propertyDescriptions]), S(title, authors));
	UKObjectsEqual(SA([person propertyDescriptions]), S(name, personBooks));	
	UKObjectsEqual(SA([library propertyDescriptions]), S(librarian, libraryBooks));
	
	// Test that the opposite relationship is bidirectional
	UKObjectsEqual([personBooks opposite], authors);

	NSMutableArray *warnings = [NSMutableArray array];

	[book checkConstraints: warnings];
	[person checkConstraints: warnings];
	[library checkConstraints: warnings];
	ETLog(@"Check contraint warnings: %@", warnings);
	
	// FIXME: UKTrue([warnings isEmpty]);
}

@end
