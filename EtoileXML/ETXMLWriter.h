#import "ETXMLParserDelegate.h"

@interface ETXMLWriter : NSObject <ETXMLWriting> {
	BOOL autoindent;
	NSMutableString *buffer;
	NSMutableArray *tagStack;
	NSMutableString *indentString;
	BOOL inOpenTag;
}
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

extern NSString *ETXMLMismatchedTagException;
