/** <title>ETModelDescriptionPackage</title>

	<abstract>A model description framework inspired by FAME 
	(http://scg.unibe.ch/wiki/projects/fame)</abstract>
 
	Copyright (C) 2010 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  March 2010
	License:  Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#import <EtoileFoundation/ETModelElementDescription.h>

@class ETEntityDescription, ETPropertyDescription;

/** Collection of related entity descriptions, usually equivalent to a data model.

A package can also include extensions to other entity descriptions. An extension 
is a property description whose owner doesn't belong to the package it gets 
added to.<br />
For example, a category can be described with a property description array, and 
these property descriptions packaged as extensions to be resolved later (usually 
when the package is imported/deserialized).

From a Model Builder perspective, a package is the document you work on to 
specify a data model.  */
@interface ETPackageDescription : ETModelElementDescription
{

}

/** Self-description (aka meta-metamodel). */
+ (ETEntityDescription *) newEntityDescription;

/* Runtime Consistency Check */

/** Checks the receiver conforms to the FM3 constraint spec and adds a short 
warning to the given array for each failure. */
- (void) checkConstraints: (NSMutableArray *)warnings;

@end
