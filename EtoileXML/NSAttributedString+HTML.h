//
//  NSAttributedString+HTML.h
//  Jabber
//
//  Created by David Chisnall on 04/09/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSAttributedString (HTML)
+ (NSAttributedString*) attributedStringWithHTML:(NSString*)aString;
@end
