#include <openssl/ssl.h>
#include <openssl/err.h>
#include <fcntl.h>
#include <unistd.h>

#import "EtoileFoundation.h"

NSString *ETSocketException = @"ETSocketException";

/**
 * Private subclass handling sockets with SSL enabled.
 */
@interface ETSSLSocket : ETSocket
@end

@interface ETSocket (Private)
- (void)receiveData: (NSNotification*)aNotification;
@end

@implementation ETSocket
+ (void)initialize
{
	SSL_library_init();
}
- (id)initConnectedToRemoteHost: (NSString*)aHost
					 forService: (NSString*)aService
{
	SUPERINIT;
	handle = [[NSFileHandle fileHandleConnectedToRemoteHost: aHost
												 forService: aService] retain];
	if (nil == handle)
	{
		[self release];
		return nil;
	}

	return self;
}
+ (id)socketConnectedToRemoteHost: (NSString*)aHost
					   forService: (NSString*)aService
{
	return [[[self alloc] initConnectedToRemoteHost: aHost
										 forService: aService] autorelease];
}
- (BOOL)negotiateSSL
{
	// Put the file descriptor in blocking mode so that the SSL_connect call
	// will complete synchronously.
	fcntl([handle fileDescriptor], F_SETFL, 0);
	sslContext = SSL_CTX_new(SSLv23_client_method());
	ssl = SSL_new(sslContext);
	SSL_set_fd(ssl, [handle fileDescriptor]);
	int ret = SSL_connect(ssl);
	fcntl([handle fileDescriptor], F_SETFL, O_NONBLOCK);
	isa = [ETSSLSocket class];
	return ret == 1;
}

- (void)setDelegate: (id)aDelegate
{
	delegate = aDelegate;
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	if (nil != delegate)
	{
		[center addObserver: self
				   selector: @selector(receiveData:)
					   name: NSFileHandleDataAvailableNotification
					 object: handle];
		[handle waitForDataInBackgroundAndNotify];
	}
	else
	{
		[center removeObserver: self];
	}
}
- (NSMutableData*)readDataFromSocket
{
	NSMutableData *data = [NSMutableData data];
	int s = [handle fileDescriptor];
	int count = 0;
	while (0 < (count = read(s, buffer, 512)))
	{
		[data appendBytes: buffer length: count];
	}
	return data;
}
- (void)receiveData: (NSNotification*)aNotification
{
	NSMutableData *data = [self readDataFromSocket];
	FOREACH(inFilters, filter, id<ETSocketFilter>)
	{
		data = [filter filterData: data];
	}
	if (nil != data)
	{
		[delegate receivedData: data fromSocket: self];
	}
	[handle waitForDataInBackgroundAndNotify];
}
- (void)sendDataToSocket: (NSData*)data
{
	int s = [handle fileDescriptor];
	const char *bytes = [data bytes];
	unsigned len = [data length];

	int sent;
	while(len > 0)
	{
		sent = write(s, bytes, len);
		if (sent < 0)
		{
			if (errno != EAGAIN && 
				errno != EINTR && 
				errno != EAGAIN && 
				errno != EWOULDBLOCK)
			{
				[NSException raise: ETSocketException
							format: @"Sending failed"];
			}
			sent = 0;
		}
		len -= sent;
		bytes += sent;
	}
}
- (void)sendData: (NSData*)data
{
	if ([outFilters count] > 0)
	{
		data = [data mutableCopy];
		FOREACH(outFilters, filter, id<ETSocketFilter>)
		{
			data = [filter filterData: (NSMutableData*)data];
		}
	}
	[self sendDataToSocket: data];
}
- (void)dealloc
{
	[inFilters release];
	[outFilters release];
	[handle release];
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver: self];
	[super dealloc];
}
@end

@implementation ETSSLSocket
- (NSMutableData*)readDataFromSocket
{
	NSMutableData *data = [NSMutableData data];
	int count = 0;
	while (0 < (count = SSL_read(ssl, buffer, 512)))
	{
		[data appendBytes: buffer length: count];
	}
	return data;
}
- (void)sendDataToSocket: (NSData*)data
{
	const char *bytes = [data bytes];
	unsigned len = [data length];

	int sent;
	int error;
	while(len > 0)
	{
		sent = SSL_write(ssl, bytes, len);
		if (sent <= 0)
		{
			error = SSL_get_error(ssl, sent);
			while(error == SSL_ERROR_WANT_WRITE || error == SSL_ERROR_WANT_READ)
			{
				sent = SSL_write(ssl, bytes, len);
				if(sent <= 0)
				{
					error = SSL_get_error(ssl, sent);
				}
				else
				{
					error = SSL_ERROR_NONE;
				}
			}
			if(error != SSL_ERROR_NONE)
			{
				[NSException raise: ETSocketException
							format: @"Sending failed"];
			}
		}
		len -= sent;
		bytes += sent;
	}
}
- (void)dealloc
{
	SSL_free(ssl);
	SSL_CTX_free(sslContext);
	[super dealloc];
}
@end
