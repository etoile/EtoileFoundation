/*
	Copyright (C) 2007 Quentin Mathe

	Author:  Quentin Mathe <qmathe@club-internet.fr>
	Date:  November 2007
	License:  Modified BSD (see COPYING)
 */

#import <EtoileFoundation/ETTransform.h>
#import <EtoileFoundation/NSString+Etoile.h>


@implementation ETTransform

- (id) render: (id)object
{
	NSString *typeName = [object className];
	NSString *renderMethodName = [[@"render" stringByAppendingString: typeName] 
		stringByAppendingString: @":"];
	SEL renderSelector = NSSelectorFromString(renderMethodName);
	BOOL *performed = malloc(sizeof(BOOL));
	id item = nil;

	*performed = NO;
	item = [self tryToPerformSelector: renderSelector withObject: object result: performed];

	if (*performed == NO && ([typeName hasPrefix: @"ET"] || [typeName hasPrefix: @"NS"]))
	{
		typeName = [typeName substringFromIndex: 2];
		renderMethodName = [[@"render" stringByAppendingString: typeName] 
			stringByAppendingString: @":"];
		renderSelector = NSSelectorFromString(renderMethodName);

		item = [self tryToPerformSelector: renderSelector withObject: object result: performed];
	}
	
	free(performed);

	return item;
}

- (id) tryToPerformSelector: (SEL)selector withObject: (id)object result: (BOOL *)performed
{
	if ([self respondsToSelector: selector])
	{
		*performed = YES;
		return [self performSelector: selector withObject: object];
	}
	else
	{
		*performed = NO;
		return nil;
	}
}

@end
