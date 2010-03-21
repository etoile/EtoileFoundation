/*
	Copyright (C) 2010 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  March 2010
	License: Modified BSD (see COPYING)
 */

#import <UnitKit/UnitKit.h>
#import <EtoileFoundation/EtoileFoundation.h>

#define SA(x) [NSSet setWithArray: x]

@interface TestModelDescriptionRepository : NSObject <UKTest>
{
	ETModelDescriptionRepository *repo;
	ETPackageDescription *anonymousPackage;
}

@end

@implementation TestModelDescriptionRepository

- (id) init
{
	SUPERINIT;
	repo = [[ETModelDescriptionRepository alloc] init];
	anonymousPackage = [repo anonymousPackageDescription];
	return self;
}

- (void) dealloc
{
	DESTROY(repo);
	[super dealloc];
}

- (void) testResolveObjectRefsWithMetaMetaModel
{
	ETEntityDescription *root = [NSObject newEntityDescription];

	[repo addUnresolvedDescription: root];
	[repo setEntityDescription: root forClass: [NSObject class]];

	[repo collectEntityDescriptionsFromClass: [ETModelElementDescription class] 
	                              resolveNow: YES];

	ETEntityDescription *element = [repo entityDescriptionForClass: [ETModelElementDescription class]];
	ETEntityDescription *entity = [repo entityDescriptionForClass: [ETEntityDescription class]];
	ETEntityDescription *property = [repo entityDescriptionForClass: [ETPropertyDescription class]];
	ETEntityDescription *package = [repo entityDescriptionForClass: [ETPackageDescription class]];

	UKNotNil(element);
	UKNotNil(entity);
	UKNotNil(property);
	UKNotNil(package);

	UKObjectsEqual(SA([repo entityDescriptions]), S(root, element, entity, property, package));

	UKObjectsEqual(anonymousPackage, [element owner]);
	UKObjectsEqual(anonymousPackage, [entity owner]);
	UKObjectsEqual(anonymousPackage, [property owner]);
	UKObjectsEqual(anonymousPackage, [package owner]);

	UKObjectsEqual(root, [element parent]);
	UKObjectsEqual(element, [entity parent]);
	UKObjectsEqual(element, [property parent]);
	UKObjectsEqual(element, [package parent]);

	UKObjectsEqual(root, [element parent]);
	UKObjectsEqual(element, [entity parent]);
	UKObjectsEqual(element, [property parent]);
	UKObjectsEqual(element, [package parent]);

	UKObjectsEqual([entity propertyDescriptionForName: @"owner"], 
		[[package propertyDescriptionForName: @"entityDescriptions"] opposite]);
	UKObjectsEqual([property propertyDescriptionForName: @"package"], 
		[[package propertyDescriptionForName: @"propertyDescriptions"] opposite]);
}

@end
