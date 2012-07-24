/**
	Copyright (C) 2012 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  June 2012
	License: Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>

@interface ETCFMapTable : NSObject
{
	@private
	CFMutableDictionaryRef dict;
}

+ (id)mapTableWithWeakToStrongObjects;
+ (id)mapTableWithStrongToStrongObjects;

- (id)objectForKey: (id)aKey;
- (void)setObject: (id)anObject forKey: (id)aKey;
- (void)removeObjectForKey: (id)aKey;

@end
