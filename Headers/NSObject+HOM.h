/**
    Copyright (C) 2009 Quentin Mathe

    Date:  June 2009
    License: Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#import "NSObject+HOM.h"

/** @group High Order Messaging and Blocks
@abstract High-order messaging additions to NSObject. */
@interface NSObject (ETHOM)

/** Returns the receiver itself when it can respond to the next message that 
follows -ifResponds, otherwise returns nil.

If we suppose the Cat class doesn't implement -bark, then -ifResponds would 
return nil and thereby -bark be discarded:
<code>
[[cat ifResponds] bark];
</code>

Now let's say the Dog class implement -bark, the -ifResponds will return 'dog' 
and -bark be executed:
<code>
[[dog ifResponds] bark];
</code> */
- (id) ifResponds;

@end
