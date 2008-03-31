/*
Copyright (c) 2007, David Chisnall

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

* Neither the name of the Étoilé project, nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.


THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
#import "NSObject+Futures.h"
#import "NSObject+Threaded.h"
#import "ETThreadProxyReturn.h"
#include <unistd.h>

@interface ThreadTest : NSObject {
}
@end
@implementation ThreadTest 
- (void) log:(NSString*)aString
{
	/* 
	 * Delay to ensure that this logs a while after it is called.
	 * This makes it obvious that it is completing asynchronously.
	 */
	sleep(2);
	NSLog(@"%@", aString);
}
- (id) getFoo
{
	sleep(2);
	return @"foo";
}
@end

int main(void)
{
	NSAutoreleasePool * pool = [NSAutoreleasePool new];
	/*
	 * Create an object with its own thread and run loop
	 */
	id proxy = [ThreadTest threadedNew];
	/* 
	 * Test a method that doesn't return a value
	 */
	[proxy log:@"1) Logging in another thread"];
	/*
	 * Try a method that returns a value
	 */
	NSString * foo = [proxy getFoo];
	/*
	 * Log something to show that we are continuing and not waiting for
	 * the method to return
	 */
	NSLog(@"2) [proxy getFoo] called.  Attempting to capitalize the return...");

	/* This line will block until [proxy getFoo] actually returns.
	 * Note that we can interact with wibble as though it were the real
	 * string value.
	 */
	NSLog(@"3) [proxy getFoo] is capitalized as %@", [foo capitalizedString]);

	/*
	 * If we know what we are doing, we can get the real object and get rid of 
	 * the layer of indirection.
	 */
	if([foo isFuture])
	{
		NSLog(@"4) Real object returned by future: %@", 
				[(ETThreadProxyReturn*)foo value]);
	}
	/*
	 * Clean up
	 */
	[pool release];
	return 0;
}
