//
//  ETXMLParser.h
//  Jabber
//
//  Created by David Chisnall on Wed Apr 28 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EtoileXML/ETXMLParserDelegate.h>

/**
 * An XML stream parse class.  This parser is statefull, and will cache any 
 * unparsed data.  Messages are fired off to the delegate for start and end tags
 * as well as character data.  
 *
 * This class might more accurately be called ETXMLScanner or ETXMLTokeniser
 * since the actual parsing is handled by the delegate.
 */
@interface ETXMLParser : NSObject {
	NSMutableString * buffer;
	id <NSObject, ETXMLParserDelegate> delegate;
	int depth;
	NSMutableArray * openTags;
	enum {notag, intag, inattribute, incdata, instupidcdata, incomment, broken} state;
	enum MarkupLanguage {PARSER_MODE_XML, PARSER_MODE_SGML}  mode;
}
/**
 * Create a new parser with the specified delegate.
 */
+ (id) parserWithContentHandler:(id <NSObject, ETXMLParserDelegate>) _contentHandler;
/**
 * Initialise a new parser with the specified delegate.
 */
- (id) initWithContentHandler:(id <NSObject, ETXMLParserDelegate>) _contentHandler;
/**
 * Set the class to receive messages from input data.  Commonly used to delegate
 * handling child elements to other classes, or to pass control back to the 
 * parent afterwards.
 */
- (id) setContentHandler:(id <NSObject, ETXMLParserDelegate>) _contentHandler;
/**
 * Parse the given input string.  This, appended to any data previously supplied
 * using this method, must form a (partial) XML document.  This function returns
 * NO if an error occurs while parsing.
 */
- (BOOL) parseFromSource:(NSString*) data;
/**
 * Switch between parsing modes.  Acceptable values are PARSER_MODE_XML and 
 * PARSER_MODE_SGML.  When in SGML mode, open tags do not have to have 
 * corresponding closing tags, allowing things like &lt;br&gt; to exist.  XML
 * is the default.
 */
- (void) setMode:(enum MarkupLanguage)aMode;
@end
