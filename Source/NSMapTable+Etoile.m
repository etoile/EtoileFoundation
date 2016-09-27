/*
    Copyright (C) 2011 Quentin Mathe

    Date:  July 2011
    License:  Modified BSD (see COPYING)
 */
 
#import "NSMapTable+Etoile.h"
#if !(TARGET_OS_IPHONE)

@implementation NSMapTable (Etoile)

/** Returns the keys used in the map table. */
- (NSArray *) allKeys
{
    return NSAllMapTableKeys(self);
}

/** Returns the objects stored in the map table. */
- (NSArray *) allValues
{
    return NSAllMapTableValues(self);
}

@end

#endif
