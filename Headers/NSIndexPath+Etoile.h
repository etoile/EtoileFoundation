/**
    Copyright (C) 2007 Quentin Mathe

    Date:  September 2007
    License:  Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>

/** @group Collection Additions
@abstract Additions to NSIndexPath. */
@interface NSIndexPath (Etoile)
+ (NSIndexPath *) indexPath;
+ (NSIndexPath *) indexPathWithString: (NSString *)aPath;
- (NSUInteger) firstIndex;
- (NSUInteger) lastIndex;
- (NSIndexPath *) indexPathByRemovingFirstIndex;
- (NSString *) stringByJoiningIndexPathWithSeparator: (NSString *)separator;
- (NSString *) stringValue;
@end
