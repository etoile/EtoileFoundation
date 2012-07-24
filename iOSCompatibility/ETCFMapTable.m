/**
	Copyright (C) 2012 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  June 2012
	License: Modified BSD (see COPYING)
 */

#import "ETCFMapTable.h"
#import "Macros.h"
#import "EtoileCompatibility.h"

const void *Retain(CFAllocatorRef allocator, const void *value)
{
	[(id)value retain];
	return value;
}

void Release(CFAllocatorRef allocator, const void *value)
{
	[(id)value release];
}

Boolean Equal(const void *value1, const void *value2)
{
	return [(id)value1 isEqual: (id)value2];
}

CFStringRef CopyDescription(const void *value)
{
	return (CFStringRef)[(id)value description];
}

CFDictionaryKeyCallBacks weakKeyCallBacks = 
{
	0,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
};

CFDictionaryKeyCallBacks strongKeyCallBacks = 
{
	0,
	Retain,
	Release,
	CopyDescription,
	Equal,
};

CFDictionaryValueCallBacks strongValueCallBacks =
{
	0,
	Retain,
	Release,
	CopyDescription,
	Equal,
};

@implementation ETCFMapTable

- (id)initWithWeakToStrongObjects 
{
	SUPERINIT;
	dict = CFDictionaryCreateMutable(NULL, 0, &weakKeyCallBacks, &strongValueCallBacks);
	return self;
}

- (id)initWithStrongToStrongObjects 
{
	SUPERINIT;
	dict = CFDictionaryCreateMutable(NULL, 0, &strongKeyCallBacks, &strongValueCallBacks);
	return self;
}

+ (id)mapTableWithWeakToStrongObjects 
{
	return [[[self alloc] initWithWeakToStrongObjects] autorelease];
}

+ (id)mapTableWithStrongToStrongObjects
{
	return [[[self alloc] initWithStrongToStrongObjects] autorelease];
}

- (void)dealloc
{
	CFRelease(dict);
	[super dealloc];
}

- (id)objectForKey: (id)aKey
{
	return (id)CFDictionaryGetValue(dict, aKey);
}

- (void)setObject: (id)anObject forKey: (id)aKey
{
	CFDictionarySetValue(dict, aKey, anObject);
}

- (void)removeObjectForKey: (id)aKey
{
	CFDictionaryRemoveValue(dict, aKey);
}

@end
