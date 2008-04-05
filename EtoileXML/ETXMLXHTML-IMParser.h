//
//  ETXMLXHTML-IMParser.h
//  Jabber
//
//  Created by David Chisnall on 16/05/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <EtoileXML/ETXMLNullHandler.h>

/**
 * The ETXMLXHTML_IMParser class constructs an NSAttributedString from a series
 * of XHTML-IM tags handed to the parser.  
 *
 * Not yet finished.
 */
@interface ETXMLXHTML_IMParser : ETXMLNullHandler {
	NSMutableDictionary * currentAttributes;
	NSMutableArray * attributeStack;
	NSMutableAttributedString * string;

	NSMutableDictionary * stylesForTags;
	NSSet * lineBreakBeforeTags;
	NSSet * lineBreakAfterTags;
	NSDictionary * FONT_SIZES;
}

@end
