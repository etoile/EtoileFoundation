#import <UnitKit/UnitKit.h>
#import <EtoileFoundation/EtoileFoundation.h>

#define SA(x) [NSSet setWithArray: x]

@interface TestModelElementDescription : NSObject <UKTest>
@end

@interface TestPropertyDescription : NSObject <UKTest>
@end

@interface TestPackageDescription : NSObject <UKTest>
{
	ETPackageDescription *package;
	ETPackageDescription *otherPackage;
	ETEntityDescription *book;
}
@end

@interface TestEntityDescription : NSObject <UKTest>
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

@implementation TestPropertyDescription

- (void) testOpposite
{

}

@end

@implementation TestPackageDescription

- (id) init
{
	SUPERINIT;
	package = [[ETPackageDescription alloc] initWithName: @"test"];
	otherPackage = [[ETPackageDescription alloc] initWithName: @"other"];
	book = [[ETEntityDescription alloc] initWithName: @"book"];
	return self;
}

- (void) dealloc
{
	DESTROY(package);
	DESTROY(otherPackage);
	DESTROY(book);
	[super dealloc];
}

- (void) testEntityDescriptions
{
	ETEntityDescription	*authors = [ETEntityDescription descriptionWithName: @"author"];

	UKNotNil([package entityDescriptions]);
	UKTrue([[package entityDescriptions] isEmpty]);

	[package setEntityDescriptions: S(book, authors)];

	UKObjectsEqual(S(book, authors), [package entityDescriptions]);
}

- (void) testAddPropertyDescription
{
	ETPropertyDescription *title = [ETPropertyDescription descriptionWithName: @"title"];
	ETPropertyDescription *isbn = [ETPropertyDescription descriptionWithName: @"isbn"];

	[book addPropertyDescription: title];
	[otherPackage addPropertyDescription: isbn];

	UKObjectsEqual(S(isbn), [otherPackage propertyDescriptions]);
	UKObjectsNotEqual(otherPackage, [isbn owner]);
	UKObjectsEqual(otherPackage, [isbn package]);

	[package addPropertyDescription: title];
	[package addPropertyDescription: isbn];

	UKObjectsEqual(S(title, isbn), [package propertyDescriptions]);
	UKObjectsEqual(book, [title owner]);
	UKObjectsEqual(package, [title package]);	
	UKObjectsNotEqual(package, [isbn owner]);
	UKObjectsEqual(package, [isbn package]);	
}

- (void) testBasicAddEntityDescription
{
	ETEntityDescription	*authors = [ETEntityDescription descriptionWithName: @"author"];

	[otherPackage addEntityDescription: authors];

	UKObjectsEqual(S(authors), [otherPackage entityDescriptions]);
	UKObjectsEqual(otherPackage, [authors owner]);

	[package addEntityDescription: book];
	[package addEntityDescription: authors];

	UKObjectsEqual(S(book, authors), [package entityDescriptions]);
	UKObjectsEqual(package, [book owner]);
	UKObjectsEqual(package, [authors owner]);
	UKTrue([[otherPackage entityDescriptions] isEmpty]);
}

- (void) testExtensionConflictForAddEntityDescription
{
	ETPropertyDescription *title = [ETPropertyDescription descriptionWithName: @"title"];
	[book addPropertyDescription: title];

	[package addPropertyDescription: title];

	UKObjectsEqual(S(title), [package propertyDescriptions]);

	[package addEntityDescription: book];

	UKObjectsEqual(S(book), [package entityDescriptions]);
	UKObjectsEqual(package, [book owner]);
	UKObjectsEqual(book, [title owner]);
	UKObjectsEqual(package, [title package]);
	UKTrue([[package propertyDescriptions] isEmpty]);
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
