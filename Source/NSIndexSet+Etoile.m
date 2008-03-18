/*
	NSIndexSet+Etoile.h
	
	Additions to index set classes.
 
	Copyright (C) 2007 Quentin Mathe
 
	Author:  Quentin Mathe <qmathe@club-internet.fr>
	Date:  August 2007
 
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
 
#import <EtoileFoundation/NSIndexSet+Etoile.h>

@implementation NSIndexSet (Etoile)

/** Returns an array of index paths by creating a new index path for each index
	stored in the receiver. 
	Each resulting index path only contains a single index. */
- (NSArray *) indexPaths
{
	NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity: [self count]];
	/* Will set lastIndex to 0 or NSNotFound */
	unsigned int lastIndex = [self indexGreaterThanOrEqualToIndex: 0];

	if (lastIndex == NSNotFound)
		return nil;

	do
	{
		[indexPaths addObject: [NSIndexPath indexPathWithIndex: lastIndex]];
	} while ((lastIndex = [self indexGreaterThanIndex: lastIndex]) != NSNotFound);
	
	return indexPaths;
}

@end


@implementation NSMutableIndexSet (Etoile)

/** Inverts whether an index is present or not in the index set. If the 
	receiver contains index, this index gets removed, else this index gets 
	added. */
- (void) invertIndex: (unsigned int)index
{
	if ([self containsIndex: index])
	{
		[self removeIndex: index];
	}
	else
	{
		[self addIndex: index];
	}
}

@end
