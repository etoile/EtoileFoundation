/*
	NSIndexPath+Etoile.h
	
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
 
#import <EtoileFoundation/NSIndexPath+Etoile.h>
#import <EtoileFoundation/EtoileCompatibility.h>

@implementation NSIndexPath (Etoile)

+ (NSIndexPath *) indexPath
{
	return AUTORELEASE([[NSIndexPath alloc] init]);
}

- (unsigned int) firstIndex
{
	return [self indexAtPosition: 0];
}

- (unsigned int) lastIndex
{
	return [self indexAtPosition: [self length] - 1];
}

- (NSIndexPath *) indexPathByRemovingFirstIndex
{
	/*unsigned int *indexes = NSZoneMalloc(NSDefaultMallocZone(), sizeof(unsigned int) * [self length]);
	unsigned int *buffer = NSZoneMalloc(NSDefaultMallocZone(), sizeof(unsigned int) * ([self length] - 1));*/
	unsigned int *indexes = calloc(sizeof(unsigned int), [self length]);
	unsigned int *buffer = calloc(sizeof(unsigned int), [self length] - 1);
	
	[self getIndexes: indexes];
	buffer = memcpy(buffer, &indexes[1], sizeof(unsigned int) * ([self length] -1));
	//NSZoneFree(NSDefaultMallocZone(), indexes);
	free(indexes);
	
	return [NSIndexPath indexPathWithIndexes: buffer length: [self length] - 1];
}

/** NOTE: This method currently ignores separator paremeter because there is no
	built-in path separator support in NSString path API. To fix the issue,
	implements path separator support in NSString or a new clean path API to be
	named ETPath. The only supported separator is '/'. */
- (NSString *) stringByJoiningIndexPathWithSeparator: (NSString *)separator
{
	NSString *path = @"/";
	int indexCount = [self length];
	
	for (int i = 0; i < indexCount; i++)
	{
		path = [path stringByAppendingPathComponent: 
			[NSString stringWithFormat: @"%d", [self indexAtPosition: i]]];
	}
	
	return path;
}

/** Returns a string representation of the receiver which can be used as a key
	path (with KVC). 
	NOTE: This method doesn't yet return a key path using dot separator because
	-stringByJoiningIndexPathWithSeparator isn't fully implemented yet. */
- (NSString *) keyPath
{
	return [self stringByJoiningIndexPathWithSeparator: @"."];
}

@end
