/*  <title>NSInvocation(Etoile)</title>

	NSInvocation+Etoile.m

	<abstract>NSInvocation additions.</abstract>

	Copyright (C) 2008 Quentin Mathe

	Author:  Quentin Mathe <qmathe@club-internet.fr>
	Date:  April 2008

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

#import "NSInvocation+Etoile.h"
#import "Macros.h"


@implementation NSInvocation (Etoile)

/** Creates and returns a new invocation ready to be invoked by taking in 
	input all mandatory parameters.
	This method is only usable for selector for which the method signature 
	doesn't declare arguments with C-intrisic types. In other words, the method 
	to be invoked has to take only objects in parameter.
	TODO: May be implement support of the C-intrisic types that can be boxed 
	into NSValue instances, by handling the unboxing of the NSValue instances if 
	needed. The code should still work well if the method takes an NSValue 
	object in argument. */
+ (id) invocationWithTarget: (id)target 
                   selector: (SEL)selector 
                  arguments: (NSArray *)args
{
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature: 
		[target methodSignatureForSelector: selector]];
	int i = 2;

	[inv setTarget: target];
	FOREACHI(args, object)
	{
		[inv setArgument: &object atIndex: i];
		i++;
	}

	return inv;
}

@end
