/*
	Copyright (C) 2007 Quentin Mathe

	Author:  Quentin Mathe <qmathe@club-internet.fr>
	Date:  September 2007
	License: Modified BSD (see COPYING)
 */

#import "NSString+Etoile.h"

#pragma GCC diagnostic ignored "-Wobjc-protocol-method-implementation"

#ifdef GNUSTEP
@interface GSString : NSString
+ (void)reinitialize;
@end
#endif

@implementation NSString (Etoile)

#ifdef GNUSTEP
+ (void)load
{
	if ([GSString respondsToSelector: @selector(reinitialize)])
	{
		[GSString reinitialize];
	}
}
#endif

/** Returns the substring that starts at the first index and ends at the second 
index. 

The character located at the start index is included in the returned string, 
unlike the character located at the end index which isn't included.
 
This is a convenient alternative to -substringWithRange: which tends to be 
error-prone for most use cases. */
- (NSString *) substringFromIndex: (NSUInteger)startIndex toIndex: (NSUInteger)endIndex
{
	NSParameterAssert(startIndex <= endIndex);
	return [self substringWithRange: NSMakeRange(startIndex, endIndex - startIndex)];
}

/** Returns the first path component of the receiver. If the receiver isn't a 
path, returns the a new instance of the entire string. 

If the path is '/', returns '/'.<br />
If the path is '/where/who' or 'where/who', returns 'where'. */
- (NSString *) firstPathComponent
{
	NSArray *pathComponents = [self pathComponents];
	NSString *firstPathComp = nil;
	
	if ([pathComponents count] > 0)
		firstPathComp = [pathComponents objectAtIndex: 0];

	return firstPathComp;
}

/** Returns a new string instance by stripping the first path component as 
defined by -firstPathComponent. */
- (NSString *) stringByDeletingFirstPathComponent
{
	NSArray *pathComponents = [self pathComponents];
	
	pathComponents = [pathComponents subarrayWithRange: NSMakeRange(1, [pathComponents count] - 1)];
	
	return [NSString pathWithComponents: pathComponents];
}

/** Returns a new string instance by first standardizing the path, then 
resolving remaining relative path components against the current directory to 
ensure the first path component is a '/' (the resulting path returns YES to 
-[NSString isAbsolutePath]).

See also -[NSString stringByStandardizingPath] and 
-[NSFileManager currentDirectoryPath].

For a current directory <em>/home/john/documents</em>, <em>../beach.jpg</em> 
is resolved to <em>/home/john/beach.jpg</em>, and <em>beach.jpg</em> is 
resolved to <em>/home/john/documents/beach.jpg</em>.   */
- (NSString *) stringByStandardizingIntoAbsolutePath
{
	NSString *path = [self stringByStandardizingPath];

	if (![path isAbsolutePath])
	{
		path = [[[NSFileManager defaultManager] currentDirectoryPath] 
			stringByAppendingPathComponent: path];
		/* For paths such as ../../beach.jpg where '/../' cannot be resolved 
		   the first time -stringByStandardizingPath is used */
		path = [path stringByStandardizingPath];
	}
	return path;
}
/** Returns a string where all words are separated by spaces for a given string 
of capitalized words with no spaces at all. 

Useful to convert a name in camel case into a more user friendly name. */
- (NSString *) stringBySpacingCapitalizedWords
{
	NSScanner *scanner = [NSScanner scannerWithString: self];
	NSCharacterSet *charset = [NSCharacterSet uppercaseLetterCharacterSet];
	NSString *word = nil;
	NSMutableString *displayName = [NSMutableString stringWithCapacity: 40];
	BOOL beforeLastLetter = NO;

	do
	{
		/* Scan a first capital or an uppercase word */
		BOOL hasScannedCapitals = [scanner scanCharactersFromSet: charset
	                                                  intoString: &word];
		if (hasScannedCapitals)
		{
			beforeLastLetter = ([scanner isAtEnd] == NO);
			BOOL hasFoundUppercaseWord = ([word length] > 1);
			if (hasFoundUppercaseWord && beforeLastLetter)
			{
				[displayName appendString: [word substringToIndex: [word length] - 1]];
				[displayName appendString: @" "]; /* Add a space between each words */
				[displayName appendString: [word substringFromIndex: [word length] - 1]];
			}
			else /* single capital or uppercase word at the end */
			{
				[displayName appendString: word];
			}
		}

		/* Scan lowercase characters, either a full word or what follows the 
		   a capital until the next one */
		BOOL hasFoundNextCapitalOrEnd = [scanner scanUpToCharactersFromSet: charset
	                                                            intoString: &word];
		if (hasFoundNextCapitalOrEnd)
		{
			[displayName appendString: word];

			/* Add a space between each words */
			beforeLastLetter = ([scanner isAtEnd] == NO);
			BOOL beyondFirstCapital = ([scanner scanLocation] > 0);
			if (beyondFirstCapital && beforeLastLetter)
			{
				[displayName appendString: @" "];
			}
		}
	} while (beforeLastLetter);

	return displayName;
}

/** Returns a string where the first letter is capitalized and the other letter 
case remains the same (unlike -capitalizedString).
 
Useful to create accessor names from Key-Value-Coding keys. */
- (NSString *) stringByCapitalizingFirstLetter
{
	// TODO: Probably a bit slow, rewrite in C a bit
	NSString *suffix = [[self substringToIndex: 1] uppercaseString];
	return [self stringByReplacingCharactersInRange: NSMakeRange(0, 1)
	                                     withString: suffix];
}

/** Returns a string where the first letter is lowercased and the other letter 
case remains the same.
 
Useful to create accessor names from Key-Value-Coding keys.
 
See also -stringByCapitalizingFirstLetter. */
- (NSString *) stringByLowercasingFirstLetter
{
	// TODO: Probably a bit slow, rewrite in C a bit
	NSString *suffix = [[self substringToIndex: 1] lowercaseString];
	return [self stringByReplacingCharactersInRange: NSMakeRange(0, 1)
	                                     withString: suffix];
}

// FIXME: Implement
- (NSIndexPath *) indexPathBySplittingPathWithSeparator: (NSString *)separator
{
	return nil;
}

- (BOOL)isEqualToString: (NSString*)aString
{
	NSUInteger length = [self length];
	if ([aString length] != length) { return NO; }

	NSRange range = { 0, 30 };
	while (range.location < length)
	{
		unichar buffer[30];
		unichar buffer2[30];
		if (range.location + range.length > length)
		{
			range.length = length - range.location;
		}
		[aString getCharacters: buffer range: range];
		[self getCharacters: buffer2 range: range];
		range.location += 30;
		for (unsigned i=0 ; i<range.length ; i++)
		{
			if (buffer[i] != buffer2[i]) { return NO; }
		}
	}

	return YES;
}

@end

