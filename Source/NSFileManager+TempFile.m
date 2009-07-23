#import "NSFileManager+TempFile.h"
#include <unistd.h>
#include <string.h>

static char * makeTempPattern(void)
{
	NSString * patternString = NSTemporaryDirectory();
	patternString = 
		[patternString stringByAppendingPathComponent:[[NSProcessInfo processInfo] processName]];
	// Make sure that this application's temporary directory exists.
	[[NSFileManager defaultManager] createDirectoryAtPath: patternString 
	                                           attributes: nil];
	patternString = [patternString stringByAppendingPathComponent:@"tmpXXXXXXXX"];
	return strdup([patternString UTF8String]);
}

@implementation NSFileManager (TempFile)
- (NSFileHandle*) tempFile
{
	char * pattern = makeTempPattern();
	int fd = mkstemp(pattern);
	free(pattern);
	return [[[NSFileHandle alloc] initWithFileDescriptor:fd] autorelease];
}
- (NSString*) tempDirectory
{
	char * pattern = makeTempPattern();
	NSString * dirName = nil;
	if (NULL != mkdtemp(pattern))
	{
		dirName = [NSString stringWithUTF8String:pattern];
		free(pattern);
	}
	return dirName;
}
@end
