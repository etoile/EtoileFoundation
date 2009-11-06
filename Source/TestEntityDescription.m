#import <UnitKit/UnitKit.h>
#import <EtoileFoundation/EtoileFoundation.h>

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

	UKObjectsEqual([book propertyDescriptions], A(title, authors));
	UKObjectsEqual([person propertyDescriptions], A(name, personBooks));	
	UKObjectsEqual([library propertyDescriptions], A(librarian, libraryBooks));
	
	// Test that the opposite relationship is bidirectional
	UKObjectsEqual([personBooks opposite], authors);
}

@end
