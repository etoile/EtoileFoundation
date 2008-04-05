//
//  ETXMLParserDelegate.h
//  Jabber
//
//  Created by David Chisnall on Wed Apr 28 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Helper function for escaping XML character data.
 */
static inline NSMutableString* escapeXMLCData(NSString* _XMLString)
{
	if(_XMLString == nil)
	{
		return [NSMutableString stringWithString:@""];
	}
	NSMutableString * XMLString = [NSMutableString stringWithString:_XMLString];
	[XMLString replaceOccurrencesOfString:@"&" withString:@"&amp;" options:0 range:NSMakeRange(0,[XMLString length])];
	[XMLString replaceOccurrencesOfString:@"<" withString:@"&lt;" options:0 range:NSMakeRange(0,[XMLString length])];
	[XMLString replaceOccurrencesOfString:@">" withString:@"&gt;" options:0 range:NSMakeRange(0,[XMLString length])];
	[XMLString replaceOccurrencesOfString:@"'" withString:@"&apos;" options:0 range:NSMakeRange(0,[XMLString length])];
	[XMLString replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:0 range:NSMakeRange(0,[XMLString length])];
	return XMLString;
}

/**
 * Helper function for unescaping XML character data.
 */
static inline NSMutableString* unescapeXMLCData(NSString* _XMLString)
{
	if(_XMLString == nil)
	{
		return [NSMutableString stringWithString:@""];
	}
	NSMutableString * XMLString = [NSMutableString stringWithString:_XMLString];
	[XMLString replaceOccurrencesOfString:@"&lt;" withString:@"<" options:0 range:NSMakeRange(0,[XMLString length])];
	[XMLString replaceOccurrencesOfString:@"&gt;" withString:@">" options:0 range:NSMakeRange(0,[XMLString length])];
	[XMLString replaceOccurrencesOfString:@"&amp;" withString:@"&" options:0 range:NSMakeRange(0,[XMLString length])];
	[XMLString replaceOccurrencesOfString:@"&apos;" withString:@"'" options:0 range:NSMakeRange(0,[XMLString length])];
	[XMLString replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:0 range:NSMakeRange(0,[XMLString length])];
	return XMLString;
}
/**
 * The ETXMLParserDelegate protocol is a formal protocol that must be 
 * implemented by classes used as delegates for XML parsing.  
 */
@protocol ETXMLParserDelegate
/**
 * Called by the parser whenever character data is parsed.  The parser will 
 * attempt to compromise between getting the data to the handler as soon as 
 * possible, and avoiding calling this too frequently.  Typically, this will 
 * either be passed a complete CDATA run in one go, or it will be passed the 
 * longest available CDATA section in the current parse buffer.
 */
- (void)characters:(NSString *)_chars;
/**
 * Called whenever a new XML element is started.  Attributes are passed in a 
 * dictionary in the same key-value pairs in the XML source.
 */
- (void)startElement:(NSString *)_Name
          attributes:(NSDictionary*)_attributes;
/**
 * Called whenever an XML element is terminated.  Short form XML elements
 * (e.g.  &lt;br /&gt;) will cause immediate calls to the start and end element
 * methods in the delegate.
 */
- (void)endElement:(NSString *)_Name;
/**
 * Used to set the associated parser.  
 *
 * Note: It might be better to parse the parser in to the other methods as an 
 * argument (e.g. characters:fromParser:).  Anyone wishing to make this change
 * should be aware that it will require a significant amount of refactoring in
 * the XMPP code.
 */
- (void) setParser:(id) XMLParser;
/**
 * Sets the parent.  When the delegate has finished parsing it should return 
 * control to the parent by setting the delegate in the associated parser.
 */
- (void) setParent:(id) newParent;
@end
