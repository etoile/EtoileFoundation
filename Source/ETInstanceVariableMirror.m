/*
	Mirror-based reflection API for Etoile.
 
	Copyright (C) 2009 Eric Wasylishen
 
	Author:  Eric Wasylishen <ewasylishen@gmail.com>
	Date:  June 2009
	License: Modified BSD (see COPYING)
 */

#import <EtoileFoundation/EtoileFoundation.h>
#import "ETInstanceVariableMirror.h"


@implementation ETInstanceVariableMirror
- (id) initWithIvar: (Ivar)ivar
{
	SUPERINIT;
	_ivar = ivar;
	return self;
}
+ (id) mirrorWithIvar: (Ivar)ivar
{
	return [[[ETInstanceVariableMirror alloc] initWithIvar: ivar] autorelease];
}
- (NSString *) name
{
	return [NSString stringWithUTF8String: ivar_getName(_ivar)];
}
- (NSArray *) properties
{
	return [[super properties] arrayByAddingObjectsFromArray: 
			A(@"name")];
}
- (ETUTI *) type
{
	// FIXME: map ivar type to a UTI
	return [ETUTI typeWithClass: [NSObject class]];
}
- (NSString *) description
{
	return [NSString stringWithFormat:
			@"ETInstanceVariableMirror %@", [self name]];
}
@end
