#import "ETXMLWriter.h"
#import <EtoileFoundation/Macros.h>

NSString *ETXMLMismatchedTagException = @"ETXMLMismatchedTagException";

@implementation ETXMLWriter
- (void)setAutoindent: (BOOL)aFlag
{
	autoindent = aFlag;
}
- (BOOL)autoindent
{
	return autoindent;
}
- (NSString*)stringValue
{
	return [[buffer copy] autorelease];
}
- (NSString*)endDocument
{
	id ret = [buffer autorelease];
	buffer = nil;
	return ret;
}
- (void)characters: (NSString*)chars
{
	if (inOpenTag)
	{
		[buffer appendString:@">"];
		inOpenTag = NO;
	}
	[buffer appendString: escapeXMLCData(chars)];
}
- (void)startElement: (NSString*)aName
          attributes: (NSDictionary*)attributes
{
	if (inOpenTag)
	{
		[buffer appendString: @">"];
		inOpenTag = NO;
	}
	if (autoindent)
	{
		if (0 != [tagStack count])
		{
			[buffer appendString: indentString];
		}
		[indentString appendString: @"\t"];
	}
	//Open tag
	[buffer appendFormat: @"<%@",aName];
	
	//Add attributes
	if(attributes != nil)
	{
		NSEnumerator *enumerator = [attributes keyEnumerator];		
		NSString* key;
		while (nil != (key = [enumerator nextObject])) 
		{
			[buffer appendFormat: @" %@=\"%@\"", key,
					escapeXMLCData([attributes objectForKey:key])];
		}
	}
	[tagStack addObject: aName];
	inOpenTag = YES;
}
- (void)endElement: (NSString*)aName
{
	if (![aName isEqualToString: [tagStack lastObject]])
	{
		[NSException raise: ETXMLMismatchedTagException
		            format: @"Attempting to close %@ inside %@",
			aName, [tagStack lastObject]];
	}
	[tagStack removeLastObject];
	if (autoindent)
	{
		int length = [indentString length];
		if (length > 0)
		{
			[indentString deleteCharactersInRange: NSMakeRange(length-1, 1)];
		}
	}
	if (inOpenTag)
	{
		[buffer appendString: @" />"];
	}
	else
	{
		if (autoindent)
		{
			[buffer appendString: indentString];
		}
		[buffer appendFormat: @"</%@>", aName];
	}
	inOpenTag = NO;
}
- (void)endElement
{
	[self endElement: [tagStack lastObject]];
}
- (void)reset
{
	[buffer release];
	[tagStack release];
	[indentString release];
	buffer = [NSMutableString new];
	indentString = [@"\n" mutableCopy];
	tagStack = [NSMutableArray new];
}
- (id)init
{
	SUPERINIT;
	buffer = [NSMutableString new];
	indentString = [@"\n" mutableCopy];
	tagStack = [NSMutableArray new];
	return self;
}
- (void)dealloc
{
	[buffer release];
	[tagStack release];
	[indentString release];
	[super dealloc];
}
@end	
