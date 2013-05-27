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
#import "ETMutableObjectViewpoint.h"
#import "ETKeyValuePair.h"
#import "NSObject+Model.h"
#import "EtoileCompatibility.h"

@interface ETMutableImmutableObjectViewpoint : ETMutableObjectViewpoint
@end

@interface ImmutableObject : NSObject <ETViewpointMutation>
{
	NSNumber *characteristic;
}
+ (Class) mutableViewpointClass;
- (id) initWithCharacteristic: (NSNumber *)aCharacteristic;
@property (nonatomic, readonly) NSNumber *characteristic;
@end

@implementation ImmutableObject

+ (Class) mutableViewpointClass
{
	return [ETMutableImmutableObjectViewpoint class];
}

- (id) initWithCharacteristic: (NSNumber *)aCharacteristic
{
	SUPERINIT;
	ASSIGN(characteristic, aCharacteristic);
	return self;
}

- (void) dealloc
{
	DESTROY(characteristic);
	[super dealloc];
}

- (NSNumber *) characteristic
{
	return characteristic;
}

- (NSArray *) propertyNames
{
	return [[super propertyNames] arrayByAddingObject: @"characteristic"];
}

@end

@interface Person : NSObject
{
	NSString *_name;
	NSDictionary *_emails;
	NSArray *_groupNames;
	ImmutableObject *_object;
}
@property (nonatomic, retain) NSString *name;
@property (nonatomic, copy) NSDictionary *emails;
@property (nonatomic, retain) NSArray *groupNames;
@property (nonatomic, retain) ImmutableObject *object;
@end

@implementation Person

@synthesize name = _name, emails = _emails, groupNames = _groupNames, object = _object;

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
		arrayByAddingObjectsFromArray: A(@"name", @"emails", @"groupNames", @"object")];
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


@interface TestMutableObjectViewpoint : NSObject <UKTest>
{
	Person *person;
	ETMutableObjectViewpoint *object;
}

@end

@implementation TestMutableObjectViewpoint

- (id) init
{
	SUPERINIT;
	person = [Person new];
	[person setObject: AUTORELEASE([[ImmutableObject alloc]
		initWithCharacteristic: [NSNumber numberWithInt: 10]])];
	Class viewpointClass = [[[person object] class] mutableViewpointClass];
	object = [[viewpointClass alloc] initWithName: @"object" representedObject: person];
	return self;
}

- (void) dealloc
{
	DESTROY(person);
	DESTROY(object);
	[super dealloc];
}

- (void) testViewpointClass
{
	UKObjectKindOf(object, ETMutableImmutableObjectViewpoint);
}

- (void) testPropertyNames
{
	UKObjectsEqual([[person object] propertyNames], [object propertyNames]);
}

- (void) testValueForProperty
{
	UKObjectsEqual([[person object] characteristic], [object valueForProperty: @"characteristic"]);
	UKNil([object valueForProperty: @"missing"]);

	/* For now, class is not included among -[NSObject propertyNames] */
	UKNil([object valueForProperty: @"class"]);
	UKStringsEqual(@"ImmutableObject", [object valueForProperty: @"className"]);
}

- (void) testSetValueForProperty
{
	NSNumber *characteristic = [NSNumber numberWithInt: 3];

	UKObjectsNotEqual(characteristic, [[person object] characteristic]);

	[object setValue: characteristic forProperty: @"characteristic"];

	UKObjectsEqual(characteristic, [[person object] characteristic]);
	UKObjectsEqual([object value], [person object]);

	[object setValue: characteristic forProperty: @"missing"];
	
	UKNil([[person object] valueForProperty: @"missing"]);
	UKObjectsEqual([object value], [person object]);
}

@end

@implementation ETMutableImmutableObjectViewpoint

- (void) setCharacteristic: (NSNumber *)aCharacteristic
{
	ImmutableObject *newObject =
		AUTORELEASE([[ImmutableObject alloc] initWithCharacteristic: aCharacteristic]);
	[self setValue: newObject];
}

@end
