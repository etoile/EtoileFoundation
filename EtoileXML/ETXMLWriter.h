#import "ETXMLParserDelegate.h"

@interface ETXMLWriter : NSObject <ETXMLWriting> 
{
	BOOL autoindent;
	NSMutableString *buffer;
	NSMutableArray *tagStack;
	NSMutableString *indentString;
	BOOL inOpenTag;
}
/**
 * Convenience method for starting a tag with no attributes.
 */
- (void)startElement: (NSString*)aName;
/**
 * Generates a start and end tag in a single operation.
 */
- (void)startAndEndElement: (NSString*)aName;
/**
 * Generates a start and end tag in a single operation.
 */
- (void)startAndEndElement: (NSString*)aName
                attributes: (NSDictionary*)attributes;
/**
 * Generates a start and end tag for aName with the specified attributes and
 * cdata as character data between.
 */
- (void)startAndEndElement: (NSString*)aName
                attributes: (NSDictionary*)attributes
                     cdata: (NSString*)chars;
/**
 * Generates a start and end tag for aName with cdata as character data
 * between.
 */
- (void)startAndEndElement: (NSString*)aName
                     cdata: (NSString*)chars;
/**
 * Sets whether the output will be automatically indented.  Default is NO.
 */
- (void)setAutoindent: (BOOL)aFlag;
/**
 * Returns whether the output is automatically indents.
 */
- (BOOL)autoindent;
/**
 * Returns the generated string. 
 */
- (NSString*)stringValue;
/**
 * Returns the string value and places the object in a state where it can not
 * respond to any more writing events.  Use this in preference to -stringValue
 * if you know you will not use this writer object again.  
 */
- (NSString*)endDocument;
/**
 * Resets the receiver to begin a new document.  Can be called after -endDocument.
 */
- (void)reset;
/**
 * Closes the most-recently-opened tag.
 */
- (void)endElement;
@end

@class ETSocket;

/**
 * An XML writer that outputs to a socket.  This sends the data directly after
 * each method call, so may be mixed with other forms of access to the socket.
 */
@interface ETXMLSocketWriter : ETXMLWriter 
{
	ETSocket *socket;	
}
- (void)setSocket: (ETSocket*)aSocket;
@end

extern NSString *ETXMLMismatchedTagException;
