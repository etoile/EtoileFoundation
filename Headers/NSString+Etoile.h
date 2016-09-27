/**
    Copyright (C) 2007 Quentin Mathe

    Date:  September 2007
    License: Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>

/** @group String Manipulation and Formatting
@abstract NSString additions. */
@interface NSString (Etoile)

- (NSString *) substringFromIndex: (NSUInteger)startIndex toIndex: (NSUInteger)endIndex;
- (NSString *) firstPathComponent;
- (NSString *) stringByDeletingFirstPathComponent;
- (NSString *) stringByStandardizingIntoAbsolutePath;
- (NSString *) stringBySpacingCapitalizedWords;
- (NSString *) stringByCapitalizingFirstLetter;
- (NSString *) stringByLowercasingFirstLetter;
- (NSIndexPath *) indexPathBySplittingPathWithSeparator: (NSString *)separator;

@end
