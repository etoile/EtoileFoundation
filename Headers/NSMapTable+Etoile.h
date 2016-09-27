/**
    Copyright (C) 2011 Quentin Mathe

    Date:  July 2011
    License:  Modified BSD (see COPYING)
 */
 
#import <Foundation/Foundation.h>
#if !(TARGET_OS_IPHONE)

/** @group Collection Additions
@abstract Additions to NSMapTable.

For now, this category is limited to NSDictionary-compatibility methods. */
@interface NSMapTable (Etoile)

- (NSArray *) allKeys;
- (NSArray *) allValues;

@end

#endif
