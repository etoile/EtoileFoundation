/**
    Copyright (C) 2009 David Chisnall

    Date:  July 2009
    License:  Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>

/**
 * @group Network and Communication
 * @abstract Category on NSFileHandle which adds support for creating 
 * protocol-agnostic sockets.
 */
@interface  NSFileHandle (ETSocketAdditions)
/**
 * Returns a new file handle object wrapping a connection-oriented stream
 * socket to the specified host on the named service.  
 */
+ (NSFileHandle*) fileHandleConnectedToRemoteHost: (NSString*)aHost
                                       forService: (NSString*)aService;
@end
