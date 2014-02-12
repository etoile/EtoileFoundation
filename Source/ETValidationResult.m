/*
 ETValidationResult.m
 
 Copyright (C) 2009 Eric Wasylishen
 
 Author:  Eric Wasylishen <ewasylishen@gmail.com>
 Date:  July 2009
 License:  Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#import "ETValidationResult.h"
#import "Macros.h"
#import "EtoileCompatibility.h"


@implementation ETValidationResult

@synthesize value = _value, isValid = _isValid, error = _error;

+ (id) validResult: (id)value
{
	return [[[ETValidationResult alloc] initWithValue: value
											  isValid: YES
												error: nil] autorelease];
}
+ (id) invalidResultWithError: (NSString *)error
{
	return [[[ETValidationResult alloc] initWithValue: nil
											  isValid: NO
												error: error] autorelease];
}
+ (id) validationResultWithValue: (id)value
                         isValid: (BOOL)isValid
                           error: (NSString *)error
{
	return [[[ETValidationResult alloc] initWithValue: value
											  isValid: isValid
												error: error] autorelease];
}
- (id) initWithValue: (id)value
             isValid: (BOOL)isValid
               error: (NSString *)error
{
	SUPERINIT;
	ASSIGN(_value, value);
	_isValid = isValid;
	ASSIGNCOPY(_error, error);
	return self;
}
- (void) dealloc
{
	DESTROY(_value);
	DESTROY(_error);
	[super dealloc];
}

@end
