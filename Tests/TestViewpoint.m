/*
	Copyright (C) 2013 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  May 2013
	License: Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#import <UnitKit/UnitKit.h>
#import "Macros.h"
#import "ETCollectionViewpoint.h"
#import "ETKeyValuePair.h"
#import "NSObject+Model.h"
#import "EtoileCompatibility.h"

@interface Person : NSObject
{
	NSString *_name;
	NSDictionary *_emails;
	NSArray *_groupNames;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, copy) NSDictionary *emails;
@property (nonatomic, retain) NSArray *groupNames;
@end

@implementation Person

@synthesize name = _name, emails = _emails, groupNames = _groupNames;

- (id) init
{
	SUPERINIT;
	ASSIGN(_name, @"John");
	ASSIGN(_emails, D(@"john@etoile.com", @"Work", @"john@nowhere.org", @"Home"));
	ASSIGN(_groupNames, A(@"Somebody", @"Nobody"));
	return self;
}

- (void) dealloc
{
	DESTROY(_name);
	DESTROY(_emails);
	DESTROY(_groupNames);
	[super dealloc];
}

// TODO: ETCollectionViewpoint should report missing names in -propertyNames
- (NSArray *) propertyNames
{
	return [[super propertyNames]
		arrayByAddingObjectsFromArray: A(@"name", @"emails", @"groupNames")];
}

@end

@interface TestCollectionViewpoint : NSObject <UKTest>
{
	Person *person;
	id emails;
	id groupNames;
}

@end

@implementation TestCollectionViewpoint

- (id) init
{
	SUPERINIT;
	person = [Person new];
	emails = [[ETCollectionViewpoint alloc] initWithName: @"emails" representedObject: person];
	groupNames = [[ETCollectionViewpoint alloc] initWithName: @"groupNames" representedObject: person];
	return self;
}

- (void) dealloc
{
	DESTROY(person);
	DESTROY(emails);
	DESTROY(groupNames);
	[super dealloc];
}

- (void) testPropertyNames
{
	UKObjectsEqual([[NSDictionary dictionary] propertyNames], [emails propertyNames]);
	UKObjectsEqual([[NSArray array] propertyNames], [groupNames propertyNames]);
}

- (void) testValueForProperty
{
	UKIntsEqual([[person emails] count], [[emails valueForProperty: @"count"] unsignedIntegerValue]);
	UKIntsEqual([[person groupNames] count], [[groupNames valueForProperty: @"count"] unsignedIntegerValue]);
	UKObjectsSame([[person groupNames] lastObject], [groupNames valueForProperty: @"lastObject"]);
}

- (void) testContent
{
	UKObjectsEqual([person emails], [emails content]);
	UKObjectsEqual([person groupNames], [groupNames content]);
}

- (void) testAddition
{
	[emails addObject: @"john@random.co.uk"];
	[groupNames addObject: @"Elsewhere"];
	
	UKTrue([[person emails] containsObject: @"john@random.co.uk"]);
	UKObjectsEqual(@"Elsewhere", [[person groupNames] lastObject]);
}

- (void) testInsertion
{
	NSUInteger oldEmailCount = [emails count];
	ETKeyValuePair *pair =  [ETKeyValuePair pairWithKey: @"Personal" value: @"john@random.co.uk"];

	[emails insertObject: [pair value] atIndex: 1 hint: pair];
	[groupNames insertObject: @"Elsewhere" atIndex: 1 hint: nil];
	
	UKTrue([[[person emails] arrayRepresentation] containsObject: pair]);
	UKIntsEqual(oldEmailCount + 1, [[person emails] count]);
	UKObjectsEqual(A(@"Somebody", @"Elsewhere", @"Nobody"), [person groupNames]);
}

- (void) testRemoval
{
	NSUInteger oldEmailCount = [emails count];
	ETKeyValuePair *pair =  [ETKeyValuePair pairWithKey: @"Work" value: nil];
	
	[emails removeObject: [pair value] atIndex: 1 hint: pair];
	[groupNames removeObject: nil atIndex: 1 hint: nil];
	
	UKNil([[person emails] objectForKey: [pair key]]);
	UKIntsEqual(oldEmailCount - 1, [[person emails] count]);
	UKObjectsEqual(A(@"Somebody"), [person groupNames]);
}
		   
- (void) testValueRemoval
{
	[emails removeObject: @"john@etoile.com"];
	[groupNames removeObject: @"Somebody"];
	
	UKNil([[person emails] objectForKey: @"Work"]);
	UKObjectsEqual(A(@"Nobody"), [person groupNames]);
}

@end
