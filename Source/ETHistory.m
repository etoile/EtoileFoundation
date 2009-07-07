/*
   ETHistory.m

   Copyright (C) 2008 Truls Becken <truls.becken@gmail.com>
 
   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in
   all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
   THE SOFTWARE.
*/

#import "ETHistory.h"
#import "EtoileCompatibility.h"
#import "Macros.h"

#define INCREMENT_HISTORY_INDEX\
	if (max_size < 1 || index < max_size) { ++index; }\
	else { [history removeObjectAtIndex: 0]; }

@implementation ETHistory

+ (id) manager
{
	return AUTORELEASE([[self alloc] init]);
}

- (id) init
{
	SUPERINIT;
	ASSIGN(history, [[NSMutableArray alloc] init]);
	DESTROY(future);
	max_size = 0;
	index = -1;
	return self;
}

- (void) addObject: (id)object
{
	[self setFuture: nil];
	INCREMENT_HISTORY_INDEX;
	[history addObject: object];
}

- (id) currentObject
{
	if (index < 0)
	{
		return nil;
	}
	return [history objectAtIndex: index];
}

- (void) back
{
	if (index > 0)
	{
		--index;
	}
}

- (id) previousObject
{
	if (index > 0)
	{
		--index;
		return [history objectAtIndex: index];
	}
	return nil;
}

- (BOOL) hasPrevious
{
	return index > 0;
}

- (void) forward
{
	if ([self hasNext] == YES)
	{
		INCREMENT_HISTORY_INDEX;
	}
}

- (id) nextObject
{
	if ([self hasNext] == YES)
	{
		INCREMENT_HISTORY_INDEX;
		return [history objectAtIndex: index];
	}
	return nil;
}

- (BOOL) hasNext
{
	if (index < (int)[history count] - 1)
	{
		return YES;
	}

	id object = [future nextObject];

 	if (object != nil)
	{
		[history addObject: object];
		return YES;
	}
	else
	{
		DESTROY(future);
		return NO;
	}
}

- (id) peek: (int)relativeIndex
{
	int peekIndex = index + relativeIndex;

	if (peekIndex < 0)
	{
		return nil;
	}

	for (int i = peekIndex - [history count] + 1; i > 0; i--)
	{
		id object = [future nextObject];

		if (object != nil)
		{
			[history addObject: object];
		}
		else
		{
			DESTROY(future);
			return nil;
		}
	}

	return [history objectAtIndex: peekIndex];
}

- (void) clear
{
	[history removeAllObjects];
	DESTROY(future);
	index = -1;
}

- (void) setFuture: (NSEnumerator *)enumerator
{
	NSRange toEnd = NSMakeRange(index + 1, [history count]);
	[history removeObjectsInRange: toEnd];
	ASSIGN(future, enumerator);
}

- (void) setMaxHistorySize: (int)maxSize
{
	max_size = maxSize;

	if (maxSize > 0 && index > maxSize)
	{
		NSRange range = NSMakeRange(0, index - maxSize);
		[history removeObjectsInRange: range];
		index = maxSize;
	}
}

- (int) maxHistorySize
{
	return max_size;
}

- (void) dealloc
{
	DESTROY(history);
	DESTROY(future);
	[super dealloc];
}

@end
