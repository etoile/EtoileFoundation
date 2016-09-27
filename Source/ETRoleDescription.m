/*
    Copyright (C) 2009 Eric Wasylishen

    Date:  July 2009
    License:  Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#import "ETRoleDescription.h"
#import "ETCollection+HOM.h"
#import "ETKeyValuePair.h"
#import "ETValidationResult.h"
#import "Macros.h"
#import "EtoileCompatibility.h"


@implementation ETRoleDescription 

- (ETPropertyDescription *) parent
{
    return nil;
}

- (ETValidationResult *) validateValue: (id)value forKey: (NSString *)key
{
    return [ETValidationResult validResult: value];
}

@end


@implementation ETRelationshipRole

@synthesize mandatory = _mandatory, deletionRule = _deletionRule;

- (void) dealloc
{
    DESTROY(_deletionRule);
    [super dealloc];
}

- (void) setMandatory: (BOOL)isMandatory
{
    [[self parent] checkNotFrozen];
    _mandatory = isMandatory;
}

- (void) setDeletionRule: (NSString *)deletionRule
{
    [[self parent] checkNotFrozen];
    ASSIGNCOPY(_deletionRule, deletionRule);
}

@end


@implementation ETMultiOptionsRole

@synthesize allowedOptions = _allowedOptions;

- (void) dealloc
{
    DESTROY(_allowedOptions);
    [super dealloc];
}

- (void) setAllowedOptions: (NSArray *)options
{
    [[self parent] checkNotFrozen];
    ASSIGNCOPY(_allowedOptions, options);
}

- (ETValidationResult *) validateValue: (id)value forKey: (NSString *)key
{
    if ([(id)[(ETKeyValuePair *)[_allowedOptions mappedCollection] value] containsObject: value])
    {
        return [ETValidationResult validResult: value];
    }
    else
    {
        return [ETValidationResult validationResultWithValue: nil
                                                     isValid: NO
                                                       error: @"Value not in the allowable set"];
    }
}

@end


@implementation ETNumberRole

@synthesize  minimum = _minimum, maximum = _maximum;

- (void)setMinimum: (NSInteger)min
{
    [[self parent] checkNotFrozen];
    _minimum = min;
}

- (void)setMaximum: (NSInteger)max
{
    [[self parent] checkNotFrozen];
    _maximum = max;
}

- (ETValidationResult *) validateValue: (id)value forKey: (NSString *)key
{
    NSInteger intValue = [value integerValue];

    if (intValue <= _maximum && intValue >= _minimum)
    {
        return [ETValidationResult validResult: value];
    }
    else
    {
        NSNumber *invalidValue =
            [NSNumber numberWithInt: MAX(_minimum, MIN(_maximum, intValue))];

        return [ETValidationResult validationResultWithValue: invalidValue
                                                     isValid: NO
                                                       error: @"Value outside the allowable range"];
    }
}

@end
