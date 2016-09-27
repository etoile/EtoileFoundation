/**
    Copyright (C) 2008 Günther Noack

    Date:  November 2008
    License:  Modified BSD (see COPYING)
 */

#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <EtoileFoundation/Macros.h>

/**
 * Key used to identify the transcript delegate for this thread.
 */
EMIT_STRING(kTranscriptDelegate);

/**
 * @group Logging
 * @abstract A Smalltalk-80 like Transcript implementation.
 *
 * Protocol for transcript delegates.  Store an object implementing the methods
 * in this protocol in the thread's dictionary with the kTranscriptDelegate key
 * and transcript messages will be sent to it instead of the standard output.
 */
@protocol ETTranscriptDelegate
/**
 * Append the string to the transcript.
 */
- (void)appendTranscriptString: (NSString*)aString;
@end

/**
 * @group Logging
 * @abstract A simple logging class designed for compatibility with
 * Smalltalkers' expectations.
 *
 * In the future, it may become possible to change the
 * standard transcripts destination. ETTranscript will
 * then take the role of an additional level of indirection.
 */
@interface ETTranscript : NSObject
/**
 * Writes the object's description to the standard transcript.
 */
+ (void) show: (NSObject*) anObject;

/**
 * Writes the given string to the standard transcript.
 */
+ (void) appendString: (NSString*) aString;

/**
 * Writes a carriage return to the standard transcript.
 */
+ (void) cr;
@end

