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
	id title = [ETPropertyDescription descriptionWithName: @"title" owner: book];
	id authors = [ETPropertyDescription descriptionWithName: @"authors" owner: book];
	[authors setMultivalued: YES];
	
	id person = [ETEntityDescription descriptionWithName: @"Person"];
	id name = [ETPropertyDescription descriptionWithName: @"name" owner: person];
	id personBooks = [ETPropertyDescription descriptionWithName: @"books" owner: person];
	[personBooks setMultivalued: YES];

	id library = [ETEntityDescription descriptionWithName: @"Library"];
	id librarian = [ETPropertyDescription descriptionWithName: @"librarian" owner: library];
	id libraryBooks = [ETPropertyDescription descriptionWithName: @"books" owner: library];
	[libraryBooks setMultivalued: YES];

	[authors setOpposite: personBooks];

	UKObjectsEqual(SA([book propertyDescriptions]), S(title, authors));
	UKObjectsEqual(SA([person propertyDescriptions]), S(name, personBooks));	
	UKObjectsEqual(SA([library propertyDescriptions]), S(librarian, libraryBooks));
	
	// Test that the opposite relationship is bidirectional
	UKObjectsEqual([personBooks opposite], authors);
}

@end
