/**
	Copyright (C) 2009 David Chisnall

	Author:  David Chisnall <csdavec@swan.ac.uk>
	Date:  July 2009
	License:  Modified BSD (see COPYING)
  */

#import <Foundation/Foundation.h>

/**
 * @group Network and Communication
 * @abstract Category on NSFileHandle which adds support for creating 
 * protocol-agnostic sockets.
 */
@interface  NSFileHandle (SocketAdditions)
/**
 * Returns a new file handle object wrapping a connection-oriented stream
 * socket to the specified host on the named service.  
 */
+ (NSFileHandle*) fileHandleConnectedToRemoteHost: (NSString*)aHost
                                       forService: (NSString*)aService;
@end
