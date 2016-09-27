/**
    Copyright (C) 2007 Quentin Mathe

    Date:  August 2007
    License:  Modified BSD (see COPYING)
 */
 
#import <Foundation/Foundation.h>

/** @group Collection Additions
@abstract Additions to NSIndexSet. */
@interface NSIndexSet (Etoile)

- (NSArray *) indexPaths;

@end

/** @group Collection Additions
@abstract Additions to NSMutableIndexSet. */
@interface NSMutableIndexSet (Etoile)

- (void) invertIndex: (unsigned int)index;

@end
