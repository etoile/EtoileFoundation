/**	
	<abstract>Additions to map table class</abstract>

	Copyright (C) 2011 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  July 2011
	License:  Modified BSD (see COPYING)
 */
 
#import <Foundation/Foundation.h>
#if !(TARGET_OS_IPHONE)

/** @group Collection Additions

For now, this category is limited to NSDictionary-compatibility methods. */
@interface NSMapTable (Etoile)

- (NSArray *) allKeys;
- (NSArray *) allValues;

@end

#endif
