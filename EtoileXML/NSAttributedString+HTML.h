//
//  NSAttributedString+HTML.h
//  Jabber
//
//  Created by David Chisnall on 04/09/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>


@interface NSAttributedString (HTML)
+ (NSAttributedString*) attributedStringWithHTML:(NSString*)aString;
@end
