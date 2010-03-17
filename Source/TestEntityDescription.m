#import <UnitKit/UnitKit.h>
#import <EtoileFoundation/EtoileFoundation.h>

#define SA(x) [NSSet setWithArray: x]

@interface TestModelElementDescription : NSObject <UKTest>
@end

@implementation TestModelElementDescription

- (void) testFullName
{
	id litterature = [ETPackageDescription descriptionWithName: @"litterature"];
	id book = [ETEntityDescription descriptionWithName: @"book"];
	id title = [ETPropertyDescription descriptionWithName: @"title"];
	id authors = [ETPropertyDescription descriptionWithName: @"authors"];
	id isbn = [ETPropertyDescription descriptionWithName: @"isbn"];

	UKStringsEqual(@"litterature", [litterature fullName]);
	UKStringsEqual(@"book", [book fullName]);
	UKStringsEqual(@"title", [title fullName]);

	[book setPropertyDescriptions: A(title, authors)];

	UKStringsEqual(@"book.title", [title fullName]);

	[litterature addEntityDescription: book];
	[litterature addPropertyDescription: isbn];

	UKStringsEqual(@"litterature.book.title", [title fullName]);
	UKStringsEqual(@"litterature.book.authors", [authors fullName]);
	UKStringsEqual(@"litterature.isbn", [isbn fullName]);

	[book removePropertyDescription: title];
	[litterature removeEntityDescription: book];
	[litterature removePropertyDescription: isbn];

	UKStringsEqual(@"title", [title fullName]);
	UKStringsEqual(@"book.authors", [authors fullName]);
	UKStringsEqual(@"isbn", [isbn fullName]);

}

@end

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
