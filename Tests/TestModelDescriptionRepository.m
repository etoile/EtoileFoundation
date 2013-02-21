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
}

@end

@implementation TestModelDescriptionRepository

- (id) init
{
	SUPERINIT;
	ASSIGN(repo, [ETModelDescriptionRepository mainRepository]);
	return self;
}

- (void) dealloc
{
	DESTROY(repo);
	[super dealloc];
}

- (void) testDescriptionLookUp
{
	ETEntityDescription *string = [repo descriptionForName: @"Anonymous.NSString"];
	ETEntityDescription *package = [repo descriptionForName: @"Anonymous.ETPackageDescription"];
	ETPropertyDescription *packageProperty = [package propertyDescriptionForName: @"entityDescriptions"];

	UKObjectsSame(string, [repo descriptionForName: @"NSString"]);
	UKObjectsSame(package, [repo descriptionForName: @"ETPackageDescription"]);
	UKObjectsSame(packageProperty, [repo descriptionForName: @"Anonymous.ETPackageDescription.entityDescriptions"]);
	UKObjectsSame(packageProperty, [repo descriptionForName: @"ETPackageDescription.entityDescriptions"]);
}

- (void) testEntityDescriptionForClass
{
	/* We use a pristine repository to collect the entity descriptions
	   explicitly and exclude some classes. */
	ASSIGN(repo, [[[ETModelDescriptionRepository alloc] init] autorelease]);

	/* For testing purpose, we just exclude NSMutableString class but
	   it is not the expected way to set up a repository (see +mainRepository). */
	NSSet *excludedClasses = [S([NSMutableString class])
		setByAddingObjectsFromArray: [NSMutableString allSubclasses]];
	[repo collectEntityDescriptionsFromClass: [NSObject class]
	                         excludedClasses: excludedClasses
	                              resolveNow: YES];

	ETEntityDescription *root = [repo descriptionForName: @"NSObject"];
	ETEntityDescription *string = [repo descriptionForName: @"NSString"];

	UKObjectsSame(root, [repo entityDescriptionForClass: [NSObject class]]);
	UKObjectsSame(string, [repo entityDescriptionForClass: [NSString class]]);
	UKObjectsSame(string, [repo entityDescriptionForClass: [NSMutableString class]]);
}

/* On Mac OS X, [@"" class] and NSClassFromString( @"__NSCFConstantString")
   are or can be two distinct class objects. So in other words, we have
   multiple class objects using the same class name. This means only a single 
   class among these classes is going to be collected in the model description 
   repository when -collectEntityDescriptionsFromClass:excludedClasses:resolveNow: is called. */
- (void) testMultipleClassObjectsUsingSameName
{
	ETEntityDescription *constantString = [repo entityDescriptionForClass: [@"" class]];

	UKNotNil(constantString);
#ifndef GNUSTEP
	UKObjectsSame(constantString, [repo entityDescriptionForClass: NSClassFromString( @"__NSCFConstantString")]);
#endif
}

- (void) testClassForEntityDescription
{
	ETEntityDescription *root = [repo descriptionForName: @"NSObject"];
	ETEntityDescription *string = [repo descriptionForName: @"NSString"];
	ETEntityDescription *customString = [ETEntityDescription descriptionWithName: @"CustomString"];

	[customString setParent: string];
	[repo addDescription: customString];

	UKObjectsSame([NSObject class], [repo classForEntityDescription: root]);
	UKObjectsSame([NSString class], [repo classForEntityDescription: string]);
	UKObjectsSame([NSString class], [repo classForEntityDescription: customString]);
}

- (void) testResolveObjectRefsWithMetaMetaModel
{
	/* We use a pristine repository to collect the entity descriptions 
	   explicitly and check class exclusion behavior. */
	ASSIGN(repo, [[[ETModelDescriptionRepository alloc] init] autorelease]);

	ETPackageDescription *anonymousPackage = [repo anonymousPackageDescription];
	ETEntityDescription *root = [repo descriptionForName: @"Object"];
	NSSet *primitiveDescClasses = 
		S([ETPrimitiveEntityDescription class], [ETCPrimitiveEntityDescription class]);
	
	/* For testing purpose, we just exclude the primitive entity classes but 
	   it is not the expected way to set up a repository (see +mainRepository). */		
	[repo collectEntityDescriptionsFromClass: [ETModelElementDescription class]
	                         excludedClasses: primitiveDescClasses
	                              resolveNow: YES];

	ETEntityDescription *element = [repo entityDescriptionForClass: [ETModelElementDescription class]];
	ETEntityDescription *entity = [repo entityDescriptionForClass: [ETEntityDescription class]];
	ETEntityDescription *property = [repo entityDescriptionForClass: [ETPropertyDescription class]];
	ETEntityDescription *package = [repo entityDescriptionForClass: [ETPackageDescription class]];

	UKNotNil(element);
	UKNotNil(entity);
	UKNotNil(property);
	UKNotNil(package);

	UKTrue([S(root, element, entity, property, package) isSubsetOfSet: SA([repo entityDescriptions])]);

	UKObjectsEqual(root, [repo entityDescriptionForClass: [NSObject class]]);
	UKObjectsEqual(element, [repo entityDescriptionForClass: [ETModelElementDescription class]]);
	UKObjectsEqual(entity, [repo entityDescriptionForClass: [ETEntityDescription class]]);
	UKObjectsEqual(property, [repo entityDescriptionForClass: [ETPropertyDescription class]]);
	UKObjectsEqual(package, [repo entityDescriptionForClass: [ETPackageDescription class]]);

	UKObjectsEqual(anonymousPackage, [element owner]);
	UKObjectsEqual(anonymousPackage, [entity owner]);
	UKObjectsEqual(anonymousPackage, [property owner]);
	UKObjectsEqual(anonymousPackage, [package owner]);

	UKObjectsEqual(root, [element parent]);
	UKObjectsEqual(element, [entity parent]);
	UKObjectsEqual(element, [property parent]);
	UKObjectsEqual(element, [package parent]);

	UKObjectsEqual(entity, [[property propertyDescriptionForName: @"type"] type]);

	UKObjectsEqual([entity propertyDescriptionForName: @"owner"], 
		[[package propertyDescriptionForName: @"entityDescriptions"] opposite]);
	UKObjectsEqual([package propertyDescriptionForName: @"entityDescriptions"], 
		[[entity propertyDescriptionForName: @"owner"] opposite]);

	UKObjectsEqual([property propertyDescriptionForName: @"owner"], 
		[[entity propertyDescriptionForName: @"propertyDescriptions"] opposite]);
	UKObjectsEqual([entity propertyDescriptionForName: @"propertyDescriptions"], 
		[[property propertyDescriptionForName: @"owner"] opposite]);

	UKObjectsEqual([property propertyDescriptionForName: @"package"], 
		[[package propertyDescriptionForName: @"propertyDescriptions"] opposite]);
	UKObjectsEqual([package propertyDescriptionForName: @"propertyDescriptions"], 
		[[property propertyDescriptionForName: @"package"] opposite]);

	NSMutableArray *warnings = [NSMutableArray array];
	[repo checkConstraints: warnings];
	UKTrue([warnings isEmpty]);
	if ([warnings isEmpty] == NO)
	{
		ETLog(@"Constraint Warnings: %@", warnings);
	}
	
}

- (void) testPrimitiveEntityDescriptions
{
	/* All Object primitives */
	ETEntityDescription *object = [repo descriptionForName: @"NSObject"];
	ETEntityDescription *string = [repo descriptionForName: @"NSString"];
	ETEntityDescription *date = [repo descriptionForName: @"NSDate"];
	ETEntityDescription *value = [repo descriptionForName: @"NSValue"];
	ETEntityDescription *number = [repo descriptionForName: @"NSNumber"];
	ETEntityDescription *booleanNumber = [repo descriptionForName: @"Boolean"];
	/* Some C primitives */
	ETEntityDescription *boolean = [repo descriptionForName: @"BOOL"];
	ETEntityDescription *integer = [repo descriptionForName: @"NSInteger"];
	ETEntityDescription *rect = [repo descriptionForName: @"NSRect"];
	ETEntityDescription *sel = [repo descriptionForName: @"SEL"];

	UKObjectKindOf(object, ETPrimitiveEntityDescription);
	UKObjectKindOf(string, ETPrimitiveEntityDescription);
	UKObjectKindOf(date, ETPrimitiveEntityDescription);
	UKObjectKindOf(value, ETPrimitiveEntityDescription);
	UKObjectKindOf(number, ETPrimitiveEntityDescription);
	UKObjectKindOf(booleanNumber, ETPrimitiveEntityDescription);

	UKObjectKindOf(boolean, ETPrimitiveEntityDescription);
	UKObjectKindOf(integer, ETCPrimitiveEntityDescription);
	UKObjectKindOf(rect, ETCPrimitiveEntityDescription);
	UKObjectKindOf(sel, ETCPrimitiveEntityDescription);

	UKTrue([object isPrimitive]);
	UKTrue([string isPrimitive]);
	UKTrue([date isPrimitive]);
	UKTrue([value isPrimitive]);
	UKTrue([number isPrimitive]);
	UKTrue([booleanNumber isPrimitive]);
	UKTrue([boolean isPrimitive]);
	UKTrue([integer isPrimitive]);
	UKTrue([rect isPrimitive]);
	UKTrue([sel isPrimitive]);

	UKFalse([booleanNumber isCPrimitive]);
	UKTrue([boolean isCPrimitive]);
	UKTrue([integer isCPrimitive]);
	UKTrue([rect isCPrimitive]);
	UKTrue([sel isCPrimitive]);

	/* Check FM 3 names are mapped to ObjC names */

	UKObjectsSame(object, [repo descriptionForName: @"Object"]);
	UKObjectsSame(string, [repo descriptionForName: @"String"]);
	UKObjectsSame(date, [repo descriptionForName: @"Date"]);
	UKObjectsSame(number, [repo descriptionForName: @"Number"]);
	UKObjectsSame(booleanNumber, [repo descriptionForName: @"Boolean"]);
	/* Full names are not the same Anonymous.NSNumber vs Anonymous.Boolean, 
	   although instantiated values are NSNumber in both cases. */
	UKObjectsNotEqual(number, booleanNumber);
	UKObjectsEqual([repo classForEntityDescription: number], [repo classForEntityDescription: booleanNumber]);

	/* Check ObjC names are mapped to ObjC clases */
	
	UKObjectsSame(object, [repo entityDescriptionForClass: [NSObject class]]);
	UKObjectsSame(string, [repo entityDescriptionForClass: [NSString class]]);
	UKObjectsSame(date, [repo entityDescriptionForClass: [NSDate class]]);
	UKObjectsSame(value, [repo entityDescriptionForClass: [NSValue class]]);
	UKObjectsSame(number, [repo entityDescriptionForClass: [NSNumber class]]);
}

- (void) testPropertyDescriptionType
{
	ETEntityDescription *package = [[ETModelDescriptionRepository mainRepository]
		descriptionForName: @"ETPackageDescription"];
	ETPropertyDescription *name = [package propertyDescriptionForName: @"name"];
	ETPropertyDescription *isMetaMetamodel = [package propertyDescriptionForName: @"isMetaMetamodel"];
	ETPropertyDescription *owner = [package propertyDescriptionForName: @"owner"];

	UKTrue([[name type] isPrimitive]);
	UKTrue([name isAttribute]);
	UKTrue([[isMetaMetamodel type] isPrimitive]);
	UKTrue([isMetaMetamodel isAttribute]);
	UKFalse([[owner type] isPrimitive]);
	UKTrue([owner isRelationship]);
}

@end
