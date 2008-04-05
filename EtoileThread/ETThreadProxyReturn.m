/*
	ETThreadProxyReturn.m

	Copyright (C) 2007 David Chisnall

	Author:  David Chisnall <csdavec@swan.ac.uk>
	Date:  January 2007

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

#import "ETThreadProxyReturn.h"

@implementation ETThreadProxyReturn
- (id) init
{
	object = nil;
	pthread_cond_init(&conditionVariable, NULL);
	pthread_mutex_init(&mutex, NULL);
	return self;
}

- (void) dealloc
{
	pthread_cond_destroy(&conditionVariable);
	pthread_mutex_destroy(&mutex);
	[object release];
	[super dealloc];
}

- (void) setProxyObject:(id)anObject
{
	pthread_mutex_lock(&mutex);
	object = [anObject retain];
	pthread_cond_signal(&conditionVariable);
	pthread_mutex_unlock(&mutex);
}

- (id) value
{
	if(object == nil)
	{
		pthread_mutex_lock(&mutex);
		if(nil == object)
		{
			pthread_cond_wait(&conditionVariable, &mutex);
		}
		pthread_mutex_unlock(&mutex);
	}
	return object;
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	//If we haven't yet got the object, then block until we have, otherwise do this quickly
	if(object == nil)
	{
		[self value];
	}
	return [object methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	if(nil == object)
	{
		[self value];
	}
	[anInvocation invokeWithTarget:object];
}
- (BOOL) isFuture
{
	return YES;
}
@end
