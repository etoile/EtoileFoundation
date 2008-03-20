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

/** Shortcut for -stringByAppendingString:. 
	Take note this method doesn't follow GNUstep/Cocoa naming style. */
- (NSString *) append: (NSString *)aString
{
	return [self stringByAppendingString: aString];
}

/** Shortcut for -stringByAppendingPathComponent:. 
	Take note this method doesn't follow GNUstep/Cocoa naming style. */
- (NSString *) appendPath: (NSString *)aPath
{
	return [self stringByAppendingPathComponent: aPath];
}

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

// FIXME: Implement
- (NSIndexPath *) indexPathBySplittingPathWithSeparator: (NSString *)separator
{
	return nil;
}

@end

