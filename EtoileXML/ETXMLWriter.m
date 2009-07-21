#import "ETXMLWriter.h"
#import <EtoileFoundation/EtoileFoundation.h>

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
{
	[self startElement: aName
	        attributes: nil];
}
- (void)startAndEndElement: (NSString*)aName
{
	[self startAndEndElement: aName
	              attributes: nil];
}
- (void)startAndEndElement: (NSString*)aName
                attributes: (NSDictionary*)attributes
{
	[self startElement: aName
	        attributes: attributes];
	[self endElement];
}
- (void)startAndEndElement: (NSString*)aName
                attributes: (NSDictionary*)attributes
                     cdata: (NSString*)chars
{
	[self startElement: aName
	        attributes: attributes];
	[self characters: chars];
	[self endElement];
}
- (void)startAndEndElement: (NSString*)aName
                     cdata: (NSString*)chars
{
	[self startAndEndElement: aName
	              attributes: nil
	                   cdata: chars];
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
- (void)endElement
{
	NSString *aName = [tagStack lastObject];
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
	[tagStack removeLastObject];
	inOpenTag = NO;
}
- (void)endElement: (NSString*)aName
{
	if (![aName isEqualToString: [tagStack lastObject]])
	{
		[NSException raise: ETXMLMismatchedTagException
		            format: @"Attempting to close %@ inside %@",
			aName, [tagStack lastObject]];
	}
	[self endElement];
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
@implementation ETXMLSocketWriter : ETXMLWriter 
- (void)sendBuffer
{
	[socket sendData: [buffer dataUsingEncoding: NSUTF8StringEncoding]];
	[buffer setString: @""];
}
- (void)characters: (NSString*)chars
{
	[super characters: chars];
	[self sendBuffer];
}
- (void)startElement: (NSString*)aName
          attributes: (NSDictionary*)attributes
{
	[super startElement: aName attributes: attributes];
	[self sendBuffer];
}
- (void)endElement
{
	[super endElement];
	[self sendBuffer];
}
- (void)setSocket: (ETSocket*)aSocket
{
	ASSIGN(socket, aSocket);
}
- (void)dealloc
{
	[socket release];
	[super dealloc];
}
@end
