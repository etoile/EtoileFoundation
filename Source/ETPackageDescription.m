/*
	Copyright (C) 2010 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  March 2010
	License:  Modified BSD (see COPYING)
 */

#import "ETPackageDescription.h"
#import "ETEntityDescription.h"
#import "ETPropertyDescription.h"
#import "Macros.h"
#import "EtoileCompatibility.h"


@implementation ETPackageDescription

+ (ETEntityDescription *) newEntityDescription
{
	ETEntityDescription *selfDesc = [[ETEntityDescription alloc] initWithName: [self className]];

	// TODO: Add property descriptions...
	[selfDesc setParent: (id)NSStringFromClass([self superclass])];

	return selfDesc;
}


- (void) checkConstraints: (NSMutableArray *)warnings
{

}

@end
