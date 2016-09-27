/**
    Copyright (C) 2008 Quentin Mathe

    Date:  April 2008
    Licence:  Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>

/** @group Language Extensions
@abstract NSInvocation additions. */
@interface NSInvocation (Etoile)
+ (id) invocationWithTarget: (id)target
                   selector: (SEL)selector
                  arguments: (NSArray *)args;
@end

