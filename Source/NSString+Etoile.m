/*
	NSString+Etoile.h
	
	Description forthcoming.
 
	Copyright (C) 2007 Quentin Mathe
 
	Author:  Quentin Mathe <qmathe@club-internet.fr>
	Date:  September 2007
 
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:

	* Redistributions of source code must retain the above copyright notice,
	  this list of conditions and the following disclaimer.
	* Redistributions in binary form must reproduce the above copyright notice,
	  this list of conditions and the following disclaimer in the documentation
	  and/or other materials provided with the distribution.
	* Neither the name of the Etoile project nor the names of its contributors
	  may be used to endorse or promote products derived from this software
	  without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
	THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <EtoileFoundation/NSString+Etoile.h>


@implementation NSString (Etoile)

/** Returns the first path component of the receiver. If the receiver isn't a 
	path, returns the a new instance of the entire string. 
	If the path is '/', returns '/'.
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

// FIXME: Implement
- (NSIndexPath *) indexPathBySplittingPathWithSeparator: (NSString *)separator
{
	return nil;
}

/* Deprecated */

/** Deprecated... Do not use.
	Shortcut for -stringByAppendingString:. 
	Take note this method doesn't follow GNUstep/Cocoa naming style. */
- (NSString *) append: (NSString *)aString
{
	return [self stringByAppendingString: aString];
}

/** Deprecated... Do not use.
	Shortcut for -stringByAppendingPathComponent:. 
	Take note this method doesn't follow GNUstep/Cocoa naming style. */
- (NSString *) appendPath: (NSString *)aPath
{
	return [self stringByAppendingPathComponent: aPath];
}

@end

