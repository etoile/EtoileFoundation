/**
    Copyright (C) 2008 David Chisnall
 
    Date:  March 2008
    License:  Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>

/**
 * @group File Management
 * @abstract NSFileManager additions for creating temporary files and directories.
 */
@interface NSFileManager (ETTempFile)
/**
 * Safely returns a temporary file.
 */
- (NSFileHandle*) tempFile;
/**
 * Creates a new temporary directory and returns its name.
 */
- (NSString*) tempDirectory;
@end
